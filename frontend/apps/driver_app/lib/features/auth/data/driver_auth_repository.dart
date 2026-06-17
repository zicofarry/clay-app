import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class RegistrationCache {
  RegistrationCache._();
  static String? email;
  static String? phone;
  static String? name;
  static void store({String? email, String? phone, String? name}) {
    if (email != null && email.isNotEmpty) RegistrationCache.email = email;
    if (phone != null && phone.isNotEmpty) RegistrationCache.phone = phone;
    if (name != null && name.isNotEmpty) RegistrationCache.name = name;
  }
  static void clear() {
    email = null;
    phone = null;
    name = null;
  }
}

class DriverAuthRepository {
  final ClayApi _api;
  DriverAuthRepository(this._api);

  Future<Map<String, dynamic>> fetchProfile({String? fallbackName, String? fallbackEmail, String? fallbackPhone, String? fallbackAvatar, String? fallbackId}) async {
    String name = fallbackName ?? '';
    String phoneNumber = fallbackPhone ?? '';
    String? email = fallbackEmail;
    String? avatarUrl = fallbackAvatar;
    String? id = fallbackId;

    Map<String, dynamic> driverProfile = {};
    try {
      final ur = await _api.dio.get(ApiEndpoints.getProfile);
      final ud = ur.data as Map<String, dynamic>;
      final inner = ud['data'] as Map<String, dynamic>? ?? ud;
      final apiName = inner['full_name']?.toString();
      if (apiName != null && apiName.isNotEmpty) name = apiName;
      final apiAvatar = inner['avatar_url']?.toString();
      if (apiAvatar != null && apiAvatar.isNotEmpty) avatarUrl = apiAvatar;
      final apiPhone = inner['phone_number']?.toString() ?? inner['phone']?.toString();
      if (apiPhone != null && apiPhone.isNotEmpty) phoneNumber = apiPhone;
      final apiEmail = inner['email']?.toString();
      if (apiEmail != null && apiEmail.isNotEmpty) email = apiEmail;
      final apiId = inner['user_id']?.toString() ?? inner['id']?.toString();
      if (apiId != null && apiId.isNotEmpty) id = apiId;
    } on DioException catch (e) {
      print('GET /users/me failed: ${e.response?.statusCode} ${e.response?.data}');
    } catch (e) {
      print('GET /users/me error: $e');
    }

    try {
      final pr = await _api.dio.get(ApiEndpoints.driverProfile);
      final pd = pr.data as Map<String, dynamic>;
      driverProfile = pd['data'] as Map<String, dynamic>? ?? pd;
    } on DioException catch (e) {
      print('GET /drivers/me failed: ${e.response?.statusCode} ${e.response?.data}');
    } catch (e) {
      print('GET /drivers/me error: $e');
    }

    return {
      'id': id,
      'name': name,
      'phone': phoneNumber,
      'email': email,
      'avatar_url': avatarUrl,
      'vehicle_type': driverProfile['vehicle_type']?.toString() ?? '',
      'vehicle_brand': driverProfile['vehicle_brand']?.toString() ?? '',
      'vehicle_model': driverProfile['vehicle_model']?.toString() ?? '',
      'vehicle_year': driverProfile['vehicle_year']?.toString() ?? '',
      'vehicle_color': driverProfile['vehicle_color']?.toString() ?? '',
      'vehicle': driverProfile['vehicle_type']?.toString() ?? '',
      'plate': driverProfile['plate_number']?.toString() ?? '',
      'status': (driverProfile['is_online'] == true) ? 'online' : 'offline',
      'rating': (driverProfile['rating_avg'] ?? 0.0),
      'total_orders': (driverProfile['total_trips'] ?? 0),
      'verification_status': driverProfile['verification_status']?.toString() ?? 'pending',
      'sim_number': driverProfile['sim_number']?.toString() ?? '',
      'ktp_number': driverProfile['ktp_number']?.toString() ?? '',
    };
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      return await _doLogin(phone, password);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code']?.toString() : null;

      if (e.response?.statusCode == 403 && code == 'ACCOUNT_NOT_VERIFIED') {
        print('Account not verified, attempting OTP verification...');
        try {
          final res = await _api.dio.post(ApiEndpoints.verifyOtp, data: {
            'phone': phone,
            'otp_code': '000000',
            'type': 'registration',
          });
          print('OTP verify success: ${res.data}');
          return await _doLogin(phone, password);
        } on DioException catch (otpErr) {
          print('OTP verify failed: ${otpErr.response?.statusCode} ${otpErr.response?.data}');
          final otpData = otpErr.response?.data;
          final otpMsg = otpData is Map
              ? (otpData['message']?.toString() ?? otpErr.message ?? 'Gagal verifikasi OTP')
              : (otpErr.message ?? 'Gagal verifikasi OTP');
          throw AppException('Akun belum terverifikasi. OTP: $otpMsg', statusCode: otpErr.response?.statusCode);
        }
      }

      final msg = data is Map ? (data['message']?.toString() ?? e.message ?? 'Login gagal') : (e.message ?? 'Login gagal');
      throw AppException(msg, statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> _doLogin(String phone, String password) async {
    final response = await _api.dio.post(
      ApiEndpoints.login,
      data: {'identifier': phone, 'password': password},
    );
    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    _api.setToken(auth.accessToken);

    final profile = await fetchProfile(
      fallbackName: auth.user.fullName.isNotEmpty ? auth.user.fullName : RegistrationCache.name,
      fallbackEmail: auth.user.email ?? RegistrationCache.email,
      fallbackPhone: RegistrationCache.phone,
      fallbackAvatar: auth.user.avatarUrl,
      fallbackId: auth.user.id,
    );
    return profile;
  }

  Future<void> logout() async {
    try {
      await _api.dio.post(ApiEndpoints.logout);
    } catch (_) {}
    _api.clearToken();
  }
}

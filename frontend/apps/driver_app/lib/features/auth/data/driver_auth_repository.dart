import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class DriverAuthRepository {
  final ClayApi _api;
  DriverAuthRepository(this._api);

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.login,
        data: {'identifier': phone, 'password': password},
      );
      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      _api.setToken(auth.accessToken);

      String name = auth.user.fullName;
      String phoneNumber = auth.user.phoneNumber;
      String? avatarUrl = auth.user.avatarUrl;

      Map<String, dynamic> driverProfile = {};
      Map<String, dynamic> userProfile = {};
      try {
        final pr = await _api.dio.get(ApiEndpoints.driverProfile);
        final pd = pr.data as Map<String, dynamic>;
        driverProfile = pd['data'] as Map<String, dynamic>? ?? pd;
      } catch (_) {}

      try {
        final ur = await _api.dio.get(ApiEndpoints.getProfile);
        final ud = ur.data as Map<String, dynamic>;
        userProfile = ud['data'] as Map<String, dynamic>? ?? ud;
        name = userProfile['full_name']?.toString() ?? name;
        avatarUrl = userProfile['avatar_url']?.toString() ?? avatarUrl;
        phoneNumber = userProfile['phone_number']?.toString() ?? phoneNumber;
      } catch (_) {}

      return {
        'id': auth.user.id,
        'name': name,
        'phone': phoneNumber,
        'email': auth.user.email,
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
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message']?.toString() ?? e.message ?? 'Login gagal') : (e.message ?? 'Login gagal');
      throw AppException(msg, statusCode: e.response?.statusCode);
    }
  }

  void logout() {
    _api.clearToken();
  }
}

import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class MerchantAuthRepository {
  final ClayApi _api;

  MerchantAuthRepository(this._api);

  String _normalizePhone(String phone) {
    var normalized = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (normalized.startsWith('0')) {
      normalized = '+62${normalized.substring(1)}';
    } else if (!normalized.startsWith('+')) {
      normalized = '+62$normalized';
    }
    return normalized;
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    var finalIdentifier = identifier.trim();

    // Check if the identifier is a phone number
    final isPhone = RegExp(r'^\+?[0-9\s\-\(\)]+$').hasMatch(finalIdentifier);
    if (isPhone) {
      finalIdentifier = _normalizePhone(finalIdentifier);
    }

    try {
      final response = await _api.dio.post(
        ApiEndpoints.login,
        data: {
          'identifier': finalIdentifier,
          'password': password,
        },
      );

      return _processAuthResponse(response.data as Map<String, dynamic>, finalIdentifier);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString() ?? e.response?.data?['error']?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal login: ${e.message}');
    }
  }



  /// Helper to process auth responses, check role and retrieve merchant profile
  Future<Map<String, dynamic>> _processAuthResponse(Map<String, dynamic> responseData, String phone) async {
    final authResponse = AuthResponse.fromJson(responseData);
    
    // Ensure the logged in user is actually a merchant
    if (authResponse.user.role != 'merchant') {
      throw AppException('Akun ini bukan akun merchant');
    }

    // Configure ClayApi token
    _api.setToken(authResponse.accessToken);

    // Fetch the merchant profile details
    final profileResponse = await _api.dio.get('${ApiEndpoints.merchants}/me');
    final profileData = profileResponse.data as Map<String, dynamic>;
    final merchantData = profileData['data'] as Map<String, dynamic>? ?? {};

    // Map backend model to legacy UI keys
    return {
      'id': merchantData['id'],
      'user_id': merchantData['user_id'],
      'name': merchantData['name'],
      'owner': authResponse.user.fullName.isNotEmpty ? authResponse.user.fullName : 'Pemilik Toko',
      'phone': merchantData['phone_number'] ?? phone,
      'category': merchantData['category'] ?? '',
      'address': merchantData['address'] ?? '',
      'rating': (merchantData['rating'] as num?)?.toDouble() ?? 4.5,
      'total_orders': merchantData['total_reviews'] ?? 0,
      'status': merchantData['status'] ?? 'active',
      ...merchantData,
    };
  }

  /// GET /auth/sessions — Fetch active login sessions
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      final response = await _api.dio.get(ApiEndpoints.sessions);
      final rawData = response.data as Map<String, dynamic>;
      final list = rawData['data'] as List? ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString() ?? e.response?.data?['error']?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil sesi aktif: ${e.message}');
    }
  }

  /// DELETE /auth/sessions/{sessionId} — Revoke a session
  Future<void> revokeSession(String sessionId) async {
    try {
      await _api.dio.delete(ApiEndpoints.revokeSession(sessionId));
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString() ?? e.response?.data?['error']?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal menghapus sesi: ${e.message}');
    }
  }

  /// POST /auth/sessions/revoke-all — Revoke all sessions (except current one)
  Future<void> revokeAllSessions() async {
    try {
      await _api.dio.post(ApiEndpoints.revokeAllSessions);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString() ?? e.response?.data?['error']?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal menghapus seluruh sesi: ${e.message}');
    }
  }

  void logout() {
    _api.clearToken();
  }

  /// Send forgot password request and then request verification OTP
  Future<void> sendForgotPasswordOtp(String phoneNumber) async {
    final phone = _normalizePhone(phoneNumber);
    try {
      await _api.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'phone': phone},
      );

      await _api.dio.post(
        ApiEndpoints.requestOtp,
        data: {
          'phone': phone,
          'type': 'reset',
        },
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString() ?? e.response?.data?['error']?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal memproses lupa sandi: ${e.message}');
    }
  }

  /// Verify OTP code for resetting password and retrieve reset token
  Future<String> verifyOtpForReset(String phoneNumber, String otpCode) async {
    final phone = _normalizePhone(phoneNumber);
    try {
      final response = await _api.dio.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phone,
          'otp_code': otpCode,
          'type': 'reset',
        },
      );

      final data = response.data;
      if (data is Map) {
        final innerData = data['data'];
        if (innerData is Map && innerData['reset_token'] != null) {
          return innerData['reset_token'].toString();
        }
        if (data['reset_token'] != null) {
          return data['reset_token'].toString();
        }
      }
      throw AppException('Gagal memverifikasi OTP: Token reset tidak ditemukan');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString() ?? e.response?.data?['error']?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal memverifikasi OTP: ${e.message}');
    }
  }

  /// Submit new password using phone number and reset token
  Future<void> resetPassword({
    required String phoneNumber,
    required String resetToken,
    required String newPassword,
  }) async {
    final phone = _normalizePhone(phoneNumber);
    try {
      await _api.dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'phone': phone,
          'reset_token': resetToken,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString() ?? e.response?.data?['error']?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mereset sandi: ${e.message}');
    }
  }
}

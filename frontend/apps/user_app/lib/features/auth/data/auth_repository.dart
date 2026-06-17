import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

String normalizePhone(String phone) {
  var normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  if (normalized.startsWith('0')) {
    normalized = '+62${normalized.substring(1)}';
  } else if (!normalized.startsWith('+')) {
    normalized = '+62$normalized';
  }
  return normalized;
}

class AuthRepository {
  final ClayApi _api;

  AuthRepository(this._api);

  Future<AuthResponse> login(String phoneNumber, String password) async {
    final phone = normalizePhone(phoneNumber);
    try {
      final response = await _api.dio.post(
        ApiEndpoints.login,
        data: {
          'identifier': phone,
          'password': password,
        },
      );
      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      
      // Save token for future API calls
      _api.setToken(authResponse.accessToken);
      
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> register({
    required String phoneNumber,
    required String fullName,
    required String password,
  }) async {
    final phone = normalizePhone(phoneNumber);
    try {
      // 1. Call Backend Register
      await _api.dio.post(
        ApiEndpoints.register,
        data: {
          'email': '${phone.replaceAll('+', '')}@clay.com',
          'phone': phone,
          'password': password,
          'role': 'user',
        },
      );
      
      // 2. Auto-Verify OTP (mock OTP is 123456)
      await _api.dio.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phone,
          'otp_code': '123456',
          'type': 'registration',
        },
      );

      // 3. Login to get token
      final loginResponse = await _api.dio.post(
        ApiEndpoints.login,
        data: {
          'identifier': phone,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(loginResponse.data as Map<String, dynamic>);
      
      // Save token for profile creation
      _api.setToken(authResponse.accessToken);

      // 4. Create Profile with full name
      await _api.dio.post(
        ApiEndpoints.getProfile,
        data: {
          'full_name': fullName,
        },
      );

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> sendForgotPasswordOtp(String phoneNumber) async {
    final phone = normalizePhone(phoneNumber);
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
      throw _handleError(e);
    }
  }

  Future<String> verifyOtpForReset(String phoneNumber, String otpCode) async {
    final phone = normalizePhone(phoneNumber);
    try {
      final verifyResponse = await _api.dio.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phone,
          'otp_code': otpCode,
          'type': 'reset',
        },
      );

      final data = verifyResponse.data;
      if (data is Map) {
        final innerData = data['data'];
        if (innerData is Map && innerData['reset_token'] != null) {
          return innerData['reset_token'].toString();
        }
        if (data['reset_token'] != null) {
          return data['reset_token'].toString();
        }
      }
      throw AppException('Gagal mendapatkan reset token');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword({
    required String phoneNumber,
    required String resetToken,
    required String newPassword,
  }) async {
    final phone = normalizePhone(phoneNumber);
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
      throw _handleError(e);
    }
  }

  Future<void> revokeAllSessions() async {
    try {
      await _api.dio.post(ApiEndpoints.revokeAllSessions);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> listSessions() async {
    try {
      final response = await _api.dio.get(ApiEndpoints.sessions);
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> revokeSession(String sessionId) async {
    try {
      await _api.dio.delete(ApiEndpoints.revokeSession(sessionId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    final errorMsg = e.response?.data?['message']?.toString();
    final message = errorMsg ?? (e.message ?? 'Unknown error');
    final code = e.response?.statusCode;
    if (code == 401) {
      return AuthException(message, statusCode: code);
    }
    return AppException(message, statusCode: code);
  }
}

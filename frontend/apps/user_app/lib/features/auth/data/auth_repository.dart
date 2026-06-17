import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

bool _isPhone(String value) {
  return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value.trim());
}

String normalizePhone(String phone) {
  var normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  if (normalized.startsWith('0')) {
    normalized = '+62${normalized.substring(1)}';
  } else if (!normalized.startsWith('+')) {
    normalized = '+62$normalized';
  }
  return normalized;
}

String? normalizeContact(String contact) {
  final trimmed = contact.trim();
  if (trimmed.isEmpty) return null;
  if (_isPhone(trimmed)) return normalizePhone(trimmed);
  return trimmed;
}

class AuthRepository {
  final ClayApi _api;

  AuthRepository(this._api);

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    String? email,
    String? phone,
    required String password,
  }) async {
    try {
      String? normalizedPhone;
      if (phone != null && phone.isNotEmpty) {
        normalizedPhone = normalizePhone(phone);
      }

      final response = await _api.dio.post(
        ApiEndpoints.register,
        data: {
          if (username.isNotEmpty) 'username': username,
          if (email != null && email.isNotEmpty) 'email': email,
          if (normalizedPhone != null) 'phone': normalizedPhone,
          'password': password,
          'role': 'user',
        },
      );

      return (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> requestOtp(String contact, String type) async {
    try {
      await _api.dio.post(
        ApiEndpoints.requestOtp,
        data: {
          'phone': contact,
          'type': type,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> verifyOtp(String contact, String otpCode, String type) async {
    try {
      await _api.dio.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': contact,
          'otp_code': otpCode,
          'type': type,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> login(String identifier, String password) async {
    final normalized = normalizeContact(identifier) ?? identifier;
    try {
      final response = await _api.dio.post(
        ApiEndpoints.login,
        data: {
          'identifier': normalized,
          'password': password,
        },
      );
      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      _api.setToken(authResponse.accessToken);
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> createProfile(String fullName) async {
    try {
      await _api.dio.post(
        ApiEndpoints.getProfile,
        data: {
          'full_name': fullName,
        },
      );
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

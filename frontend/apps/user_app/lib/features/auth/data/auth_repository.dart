import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ClayApi _api;

  AuthRepository(this._api);

  Future<AuthResponse> login(String phoneNumber, String password) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.login,
        data: {
          'identifier': phoneNumber,
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
    try {
      // 1. Call Backend Register
      await _api.dio.post(
        ApiEndpoints.register,
        data: {
          'email': '${phoneNumber.replaceAll('+', '')}@clay.com',
          'phone': phoneNumber,
          'password': password,
          'role': 'user',
        },
      );
      
      // 2. Auto-Verify OTP (mock OTP is 123456)
      await _api.dio.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phoneNumber,
          'otp_code': '123456',
          'type': 'registration',
        },
      );

      // 3. Login to get token
      final loginResponse = await _api.dio.post(
        ApiEndpoints.login,
        data: {
          'identifier': phoneNumber,
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

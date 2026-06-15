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
          'phone_number': phoneNumber,
          'password': password,
        },
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
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
      final response = await _api.dio.post(
        ApiEndpoints.register,
        data: {
          'phone_number': phoneNumber,
          'full_name': fullName,
          'password': password,
        },
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
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

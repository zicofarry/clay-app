import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/api_endpoints.dart';

class AdminAuthRepository {
  final AdminApiClient _client = AdminApiClient.instance;

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await _client.dio.post(
      ApiEndpoint.login,
      data: {'identifier': identifier, 'password': password},
    );

    final data = response.data;
    if (data is Map && data['success'] == true && data['data'] != null) {
      final result = data['data'] as Map<String, dynamic>;
      final token = result['access_token'] as String?;
      if (token != null) {
        _client.setToken(token);
      }
      return {
        'id': result['user_id'] ?? '',
        'name': result['full_name'] ?? identifier,
        'email': result['email'] ?? '',
        'role': result['role'] ?? 'admin',
        'token': token ?? '',
      };
    }
    throw Exception(data?['message'] ?? 'Login failed');
  }
}

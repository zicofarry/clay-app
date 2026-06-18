import '../../../core/api_client.dart';
import '../../../core/api_endpoints.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String status;
  final String? role;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['full_name'] ?? json['name'] ?? json['username'] ?? '',
      phone: json['phone_number'] ?? json['phone'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? json['is_active'] == true ? 'active' : 'inactive',
      role: json['role'],
    );
  }
}

class UsersRepository {
  final AdminApiClient _client = AdminApiClient.instance;

  Future<List<User>> getUsers() async {
    final response = await _client.dio.get(ApiEndpoint.userDetail);
    final data = response.data;
    final List<dynamic> items = data['data'] is List ? data['data'] : [];
    return items.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }
}

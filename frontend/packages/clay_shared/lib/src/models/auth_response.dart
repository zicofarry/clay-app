import 'user_model.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? (json['data'] as Map<String, dynamic>? ?? json) : json;
    
    final userMap = data['user'] as Map<String, dynamic>? ?? {
      'id': data['user_id']?.toString() ?? '',
      'full_name': data['full_name']?.toString() ?? '',
      'phone_number': data['phone']?.toString() ?? '',
      'email': data['email']?.toString() ?? '',
      'role': data['role']?.toString() ?? '',
    };

    return AuthResponse(
      accessToken: data['access_token']?.toString() ?? '',
      refreshToken: data['refresh_token']?.toString() ?? '',
      user: UserModel.fromJson(userMap),
    );
  }
}

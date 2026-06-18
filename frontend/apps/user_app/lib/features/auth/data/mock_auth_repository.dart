import 'package:clay_shared/clay_shared.dart';

class MockAuthRepository {
  Future<AuthResponse> login(String identifier, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (password.length < 3) {
      throw const AppException('Password salah');
    }
    return AuthResponse(
      accessToken: 'mock_access_token_123',
      refreshToken: 'mock_refresh_token_456',
      user: UserModel(
        id: 'user-001',
        fullName: 'Budi Santoso',
        phoneNumber: identifier,
        username: identifier,
        email: 'budi@clay.com',
        role: 'user',
      ),
    );
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    String? email,
    String? phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'user_id': 'user-002',
      'username': username,
      'email': email,
      'phone': phone,
      'role': 'user',
      'phone_verified': false,
    };
  }

  Future<void> requestOtp(String contact, String type) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> verifyOtp(String contact, String otpCode, String type) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> createProfile(String fullName, {String? phone}) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

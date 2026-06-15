import 'package:clay_shared/clay_shared.dart';

class MockAuthRepository {
  Future<AuthResponse> login(String phoneNumber, String password) async {
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
        phoneNumber: phoneNumber,
        email: 'budi@clay.com',
        role: 'user',
      ),
    );
  }

  Future<AuthResponse> register({
    required String phoneNumber,
    required String fullName,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return AuthResponse(
      accessToken: 'mock_access_token_789',
      refreshToken: 'mock_refresh_token_012',
      user: UserModel(
        id: 'user-002',
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: 'user',
      ),
    );
  }
}

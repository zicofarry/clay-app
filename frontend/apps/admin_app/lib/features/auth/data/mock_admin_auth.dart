class MockAdminAuthRepository {
  Future<Map<String, dynamic>> login(String phone, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (password != 'admin123') throw Exception('Password salah');
    return {'id': 'ADM-001', 'name': 'Admin Clay', 'email': 'admin@clay.com', 'role': 'super_admin'};
  }
}

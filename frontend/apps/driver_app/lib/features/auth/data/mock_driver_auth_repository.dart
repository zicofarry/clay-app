class MockDriverAuthRepository {
  Future<Map<String, dynamic>> login(String phone, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'id': 'DRV-001',
      'name': 'Ahmad Driver',
      'phone': phone,
      'vehicle': 'Toyota Avanza',
      'plate': 'B 1234 ABC',
      'status': 'offline',
      'rating': 4.8,
      'total_orders': 1250,
    };
  }
}

class MockMerchantAuthRepository {
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (password != 'merchant123') throw Exception('Password salah');
    return {
      'id': 'MCH-001',
      'name': 'Bakso Merdeka',
      'owner': 'Pak Budi',
      'phone': identifier,
      'category': 'Makanan',
      'address': 'Jl. Merdeka No. 123',
      'status': 'active',
      'rating': 4.5,
      'total_orders': 1280,
    };
  }
}

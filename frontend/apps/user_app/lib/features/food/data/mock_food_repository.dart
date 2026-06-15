class MockFoodRepository {
  Future<List<Map<String, dynamic>>> getMerchants() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'id': 'M001', 'name': 'Bakso Merdeka', 'rating': 4.5, 'distance': '0.8 km', 'image': '', 'category': 'Makanan', 'eta': '15-25 min'},
      {'id': 'M002', 'name': 'Sate Pak Edi', 'rating': 4.8, 'distance': '1.2 km', 'image': '', 'category': 'Sate', 'eta': '20-30 min'},
      {'id': 'M003', 'name': 'Nasi Goreng Mawar', 'rating': 4.3, 'distance': '0.5 km', 'image': '', 'category': 'Nasi', 'eta': '10-20 min'},
      {'id': 'M004', 'name': 'Ayam Geprek Joe', 'rating': 4.6, 'distance': '1.5 km', 'image': '', 'category': 'Ayam', 'eta': '25-35 min'},
      {'id': 'M005', 'name': 'Padang Sederhana', 'rating': 4.4, 'distance': '2.0 km', 'image': '', 'category': 'Padang', 'eta': '20-30 min'},
      {'id': 'M006', 'name': 'Es Teh Indonesia', 'rating': 4.7, 'distance': '0.3 km', 'image': '', 'category': 'Minuman', 'eta': '5-10 min'},
    ];
  }

  Future<List<Map<String, dynamic>>> getMenuItems(String merchantId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'id': 'I001', 'name': 'Bakso Besar', 'price': 18000, 'image': '', 'desc': 'Bakso sapi ukuran besar', 'category': 'Makanan'},
      {'id': 'I002', 'name': 'Bakso Kecil', 'price': 12000, 'image': '', 'desc': 'Bakso sapi ukuran kecil', 'category': 'Makanan'},
      {'id': 'I003', 'name': 'Mie Ayam', 'price': 15000, 'image': '', 'desc': 'Mie ayam pangsit', 'category': 'Makanan'},
      {'id': 'I004', 'name': 'Es Teh', 'price': 5000, 'image': '', 'desc': 'Es teh manis segar', 'category': 'Minuman'},
      {'id': 'I005', 'name': 'Jeruk Hangat', 'price': 7000, 'image': '', 'desc': 'Jeruk hangat manis', 'category': 'Minuman'},
    ];
  }

  Future<Map<String, dynamic>> createOrder({
    required String merchantId, required List<Map<String, dynamic>> items,
    required int total, required String address,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'order_id': 'FOOD-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'pending',
      'merchant_id': merchantId,
      'total': total,
      'items': items,
      'address': address,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'order_id': 'FOOD-100', 'date': '2026-06-15', 'merchant': 'Bakso Merdeka', 'total': 30000, 'status': 'completed'},
      {'order_id': 'FOOD-099', 'date': '2026-06-13', 'merchant': 'Sate Pak Edi', 'total': 45000, 'status': 'completed'},
    ];
  }
}

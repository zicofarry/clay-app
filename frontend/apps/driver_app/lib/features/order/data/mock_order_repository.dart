class MockOrderRepository {
  Future<List<Map<String, dynamic>>> getIncomingOrders() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'id': 'ORD-001', 'type': 'GoRide', 'pickup': 'Jl. Sudirman No.1', 'dest': 'Jl. Thamrin No.5', 'distance': '2.3 km', 'price': 25000, 'user': 'Budi', 'eta': '8 menit'},
      {'id': 'ORD-002', 'type': 'GoFood', 'pickup': 'Bakso Merdeka', 'dest': 'Jl. Gatot Subroto', 'distance': '1.5 km', 'price': 15000, 'user': 'Siti', 'eta': '5 menit', 'merchant': 'Bakso Merdeka'},
    ];
  }

  Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    await Future.delayed(const Duration(seconds: 1));
    return {'status': 'accepted', 'order_id': orderId};
  }

  Future<Map<String, dynamic>> rejectOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'status': 'rejected', 'order_id': orderId};
  }

  Future<Map<String, dynamic>> updateStatus(String orderId, String status) async {
    await Future.delayed(const Duration(seconds: 1));
    return {'status': status, 'order_id': orderId};
  }
}

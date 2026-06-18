class MockOrderRepository {
  final List<Map<String, dynamic>> _orders = [
    {'id': 'ORD-100', 'customer': 'Budi', 'items': 'Bakso Besar x2, Es Teh x1', 'total': 55000, 'status': 'pending', 'date': '2026-06-16 10:30'},
    {'id': 'ORD-101', 'customer': 'Siti', 'items': 'Mie Ayam x1, Es Jeruk x1', 'total': 27000, 'status': 'processing', 'date': '2026-06-16 10:15'},
    {'id': 'ORD-102', 'customer': 'Ahmad', 'items': 'Bakso Kecil x3, Pangsit x1', 'total': 66000, 'status': 'ready', 'date': '2026-06-16 09:50'},
    {'id': 'ORD-103', 'customer': 'Dewi', 'items': 'Es Teh x2', 'total': 10000, 'status': 'completed', 'date': '2026-06-16 09:20'},
    {'id': 'ORD-104', 'customer': 'Rudi', 'items': 'Bakso Besar x1, Mie Ayam x1', 'total': 45000, 'status': 'cancelled', 'date': '2026-06-16 08:45'},
  ];

  Future<List<Map<String, dynamic>>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_orders);
  }

  Future<Map<String, dynamic>?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _orders.firstWhere((o) => o['id'] == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _orders.indexWhere((o) => o['id'] == id);
    if (idx != -1) _orders[idx] = {..._orders[idx], 'status': status};
  }
}

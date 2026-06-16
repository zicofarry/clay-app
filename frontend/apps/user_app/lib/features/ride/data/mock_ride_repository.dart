class MockRideRepository {
  Future<Map<String, dynamic>> estimate({
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'services': [
        {'type': 'gocar', 'name': 'GoCar', 'price': 25000, 'eta': 8, 'icon': 'car'},
        {'type': 'gocarxl', 'name': 'GoCar XL', 'price': 45000, 'eta': 10, 'icon': 'car'},
        {'type': 'gojek', 'name': 'GoJek', 'price': 15000, 'eta': 5, 'icon': 'bike'},
      ]
    };
  }

  Future<Map<String, dynamic>> createOrder({
    required double pickupLat, required double pickupLng, required String pickupAddress,
    required double destLat, required double destLng, required String destAddress,
    required String serviceType, required int price,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'order_id': 'RIDE-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'looking_for_driver',
      'pickup_address': pickupAddress,
      'destination_address': destAddress,
      'price': price,
      'service_type': serviceType,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> getActiveOrder() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'order_id': 'RIDE-001',
      'status': 'driver_assigned',
      'pickup_address': 'Jl. Sudirman No. 1',
      'destination_address': 'Jl. Gatot Subroto No. 5',
      'price': 25000,
      'driver': {
        'name': 'Ahmad Driver',
        'phone': '08123456789',
        'plate': 'B 1234 ABC',
        'vehicle': 'Toyota Avanza',
        'rating': 4.8,
        'lat': -6.21,
        'lng': 106.84,
      },
    };
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'order_id': 'RIDE-100', 'date': '2026-06-15', 'pickup': 'Jl. Sudirman', 'dest': 'Jl. Thamrin', 'price': 25000, 'status': 'completed', 'driver': 'Ahmad'},
      {'order_id': 'RIDE-099', 'date': '2026-06-14', 'pickup': 'Jl. Kuningan', 'dest': 'Jl. Senayan', 'price': 35000, 'status': 'completed', 'driver': 'Budi'},
    ];
  }
}

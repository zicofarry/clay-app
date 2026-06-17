import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class MockFoodRepository {
  Future<List<Map<String, dynamic>>> getMerchants() async {
    try {
      final response = await ClayApi.instance.dio.get('/search/merchants?q=');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map<String, dynamic> && body['status'] == 'success') {
          final data = body['data'];
          if (data is Map<String, dynamic> && data['merchants'] is List) {
            final list = data['merchants'] as List;
            return list.map((m) {
              return {
                'id': m['merchant_id']?.toString() ?? m['id']?.toString() ?? '',
                'name': m['merchant_name']?.toString() ?? m['name']?.toString() ?? 'Merchant',
                'rating': double.tryParse(m['rating']?.toString() ?? '') ?? 4.5,
                'distance': '${m['distance_km'] ?? '0.5'} km',
                'image': m['logo_url']?.toString() ?? '',
                'category': m['category']?.toString() ?? 'Makanan',
                'eta': '${m['est_delivery_min'] ?? '15-25'} min',
              };
            }).toList();
          }
        }
      }
    } catch (e) {
      // Fail silent, fallback to mock
    }

    // Fallback to mock data
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'id': '11111111-1111-1111-1111-111111111111', 'name': 'Bakso Merdeka', 'rating': 4.5, 'distance': '0.8 km', 'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500', 'category': 'Makanan', 'eta': '15-25 min'},
      {'id': '22222222-2222-2222-2222-222222222222', 'name': 'Sate Pak Edi', 'rating': 4.8, 'distance': '1.2 km', 'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500', 'category': 'Sate', 'eta': '20-30 min'},
      {'id': '33333333-3333-3333-3333-333333333333', 'name': 'Nasi Goreng Mawar', 'rating': 4.3, 'distance': '0.5 km', 'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500', 'category': 'Nasi', 'eta': '10-20 min'},
      {'id': '44444444-4444-4444-4444-444444444444', 'name': 'Ayam Geprek Joe', 'rating': 4.6, 'distance': '1.5 km', 'image': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500', 'category': 'Ayam', 'eta': '25-35 min'},
      {'id': '55555555-5555-5555-5555-555555555555', 'name': 'Padang Sederhana', 'rating': 4.4, 'distance': '2.0 km', 'image': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500', 'category': 'Padang', 'eta': '20-30 min'},
      {'id': '66666666-6666-6666-6666-666666666666', 'name': 'Es Teh Indonesia', 'rating': 4.7, 'distance': '0.3 km', 'image': 'https://images.unsplash.com/photo-1497515114629-f71d768fd07c?w=500', 'category': 'Minuman', 'eta': '5-10 min'},
    ];
  }

  Future<List<Map<String, dynamic>>> getMenuItems(String merchantId) async {
    try {
      final response = await ClayApi.instance.dio.get('/merchants/$merchantId/menu/items');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        List<dynamic>? list;
        if (body is Map<String, dynamic> && body['status'] == 'success') {
          list = body['data'] as List?;
        } else if (body is List) {
          list = body;
        }

        if (list != null) {
          return list.map((item) {
            return {
              'id': item['id']?.toString() ?? '',
              'name': item['name']?.toString() ?? 'Menu Item',
              'price': item['price_cents'] ?? item['price'] ?? 15000,
              'image': item['image_url']?.toString() ?? '',
              'desc': item['description']?.toString() ?? item['desc']?.toString() ?? 'Menu description',
              'category': item['category_id']?.toString() ?? 'Makanan',
            };
          }).toList();
        }
      }
    } catch (e) {
      // Fail silent, fallback to mock
    }

    // Fallback to mock data
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'id': 'I001', 'name': 'Bakso Besar', 'price': 18000, 'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500', 'desc': 'Bakso sapi ukuran besar dengan mie kuning dan kuah gurih', 'category': 'Makanan'},
      {'id': 'I002', 'name': 'Bakso Kecil', 'price': 12000, 'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500', 'desc': 'Bakso sapi ukuran sedang gurih nikmat isi 5 pcs', 'category': 'Makanan'},
      {'id': 'I003', 'name': 'Mie Ayam Pangsit', 'price': 15000, 'image': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500', 'desc': 'Mie ayam khas dengan taburan daging ayam bumbu manis gurih dan pangsit basah', 'category': 'Makanan'},
      {'id': 'I004', 'name': 'Es Teh Manis', 'price': 5000, 'image': 'https://images.unsplash.com/photo-1497515114629-f71d768fd07c?w=500', 'desc': 'Es teh manis segar pelepas dahaga', 'category': 'Minuman'},
      {'id': 'I005', 'name': 'Es Jeruk', 'price': 7000, 'image': 'https://images.unsplash.com/photo-1497515114629-f71d768fd07c?w=500', 'desc': 'Es jeruk peras asli manis segar kaya vitamin C', 'category': 'Minuman'},
    ];
  }

  Future<Map<String, dynamic>> createOrder({
    required String merchantId,
    required List<Map<String, dynamic>> items,
    required int total,
    required String address,
    String paymentMethod = 'cash',
  }) async {
    try {
      final reqBody = {
        'merchant_id': merchantId,
        'items': items.map((i) => {
          'menu_item_id': i['item_id'],
          'quantity': i['qty'],
          'variants': [],
          'add_ons': [],
          'notes': '',
        }).toList(),
        'delivery_lat': -6.2088,
        'delivery_lng': 106.8456,
        'delivery_address': address,
        'payment_method': paymentMethod,
        'notes': 'Pesanan dari ClayFood App',
      };

      final response = await ClayApi.instance.dio.post('/food/orders', data: reqBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map<String, dynamic> && body['status'] == 'success') {
          final data = body['data'] as Map<String, dynamic>;
          return {
            'order_id': data['id']?.toString() ?? data['order_id']?.toString() ?? '',
            'status': data['status']?.toString() ?? 'pending',
            'merchant_id': data['merchant_id']?.toString() ?? merchantId,
            'total': data['total_cents'] ?? data['total'] ?? total,
            'items': items,
            'address': data['delivery_address']?.toString() ?? address,
            'created_at': data['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          };
        }
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      final message = errorMsg ?? (e.message ?? 'Unknown error');
      throw AppException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }

    throw AppException('Gagal memproses pesanan ke server');
  }

  Future<Map<String, dynamic>?> getActiveOrder() async {
    try {
      final response = await ClayApi.instance.dio.get('/food/orders/active');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map<String, dynamic> && body['status'] == 'success') {
          final data = body['data'];
          if (data is Map<String, dynamic>) {
            return {
              'order_id': data['id']?.toString() ?? data['order_id']?.toString() ?? '',
              'status': data['status']?.toString() ?? 'pending',
              'merchant_id': data['merchant_id']?.toString() ?? '',
              'total': data['total_cents'] ?? data['total'] ?? 0,
              'address': data['delivery_address']?.toString() ?? '',
              'created_at': data['created_at']?.toString() ?? '',
            };
          }
        }
      }
    } catch (e) {
      // Fail silent
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final response = await ClayApi.instance.dio.get('/food/orders/history');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map<String, dynamic> && body['status'] == 'success') {
          final data = body['data'];
          List? list;
          if (data is Map<String, dynamic>) {
            list = (data['items'] ?? data['orders']) as List?;
          } else if (data is List) {
            list = data;
          }

          if (list != null) {
            final merchantsMap = {
              '11111111-1111-1111-1111-111111111111': 'Bakso Merdeka',
              '22222222-2222-2222-2222-222222222222': 'Sate Pak Edi',
              '33333333-3333-3333-3333-333333333333': 'Nasi Goreng Mawar',
              '44444444-4444-4444-4444-444444444444': 'Ayam Geprek Joe',
              '55555555-5555-5555-5555-555555555555': 'Padang Sederhana',
              '66666666-6666-6666-6666-666666666666': 'Es Teh Indonesia',
            };

            return list.map((item) {
              final merchantId = item['merchant_id']?.toString() ?? '';
              final merchantName = merchantsMap[merchantId] ?? 'ClayFood Resto';
              return {
                'order_id': item['id']?.toString() ?? '',
                'date': item['created_at']?.toString() ?? '',
                'merchant': merchantName,
                'total': item['total_cents'] ?? item['total'] ?? 0,
                'status': item['status']?.toString() ?? 'completed',
              };
            }).toList();
          }
        }
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      final message = errorMsg ?? (e.message ?? 'Unknown error');
      throw AppException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }

    throw AppException('Gagal mengambil riwayat pesanan');
  }
}

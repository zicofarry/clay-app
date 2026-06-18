import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class FoodRepository {
  Future<List<Map<String, dynamic>>> getMerchants() async {
    try {
      final response = await ClayApi.instance.dio.get('/merchants');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map<String, dynamic> && (body['success'] == true || body['status'] == 'success' || body['data'] != null)) {
          final data = body['data'];
          if (data is Map<String, dynamic> && data['merchants'] is List) {
            final list = data['merchants'] as List;
            return list.map<Map<String, dynamic>>((m) {
              return <String, dynamic>{
                'id': m['id']?.toString() ?? m['merchant_id']?.toString() ?? '',
                'name': m['name']?.toString() ?? m['merchant_name']?.toString() ?? 'Merchant',
                'rating': double.tryParse(m['rating']?.toString() ?? '') ?? 4.5,
                'distance': '${m['distance_km'] ?? '0.5'} km',
                'image': m['logo_url']?.toString() ?? m['banner_url']?.toString() ?? '',
                'category': m['category']?.toString() ?? 'Makanan',
                'eta': '${m['est_delivery_min'] ?? '15-25'} min',
              };
            }).toList();
          }
        }
      }
      throw AppException('Gagal mengambil data merchant dari server');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      final message = errorMsg ?? (e.message ?? 'Unknown error');
      throw AppException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getMenuItems(String merchantId) async {
    try {
      final response = await ClayApi.instance.dio.get('/merchants/$merchantId/menu/items');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        List<dynamic>? list;
        if (body is Map<String, dynamic> && (body['success'] == true || body['status'] == 'success' || body['data'] != null)) {
          list = body['data'] as List?;
        } else if (body is List) {
          list = body;
        }

        if (list != null) {
          return list.map<Map<String, dynamic>>((item) {
            return <String, dynamic>{
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
      throw AppException('Gagal mengambil menu dari server');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      final message = errorMsg ?? (e.message ?? 'Unknown error');
      throw AppException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }
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
        if (body is Map<String, dynamic> && (body['success'] == true || body['status'] == 'success' || body['data'] != null)) {
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
        if (body is Map<String, dynamic> && (body['success'] == true || body['status'] == 'success' || body['data'] != null)) {
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
        if (body is Map<String, dynamic> && (body['success'] == true || body['status'] == 'success' || body['data'] != null)) {
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

            return list.map<Map<String, dynamic>>((item) {
              final merchantId = item['merchant_id']?.toString() ?? '';
              final merchantName = merchantsMap[merchantId] ?? 'ClayFood Resto';
              return <String, dynamic>{
                'order_id': item['id']?.toString() ?? '',
                'date': item['created_at']?.toString() ?? '',
                'merchant': merchantName,
                'merchant_id': merchantId,
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

  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      final response = await ClayApi.instance.dio.get('/food/orders/$orderId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map<String, dynamic> && (body['success'] == true || body['status'] == 'success' || body['data'] != null)) {
          return body['data'] as Map<String, dynamic>?;
        }
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      final message = errorMsg ?? (e.message ?? 'Unknown error');
      throw AppException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }
    return null;
  }

  Future<void> submitRating(String orderId, int driverRating, int merchantRating, String comment) async {
    try {
      await ClayApi.instance.dio.post('/food/orders/$orderId/rate', data: {
        'driver_rating': driverRating,
        'merchant_rating': merchantRating,
        'comment': comment,
      });
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      final message = errorMsg ?? (e.message ?? 'Unknown error');
      throw AppException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}

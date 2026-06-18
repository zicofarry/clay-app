import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class OrderRepository {
  final ClayApi _api;

  OrderRepository(this._api);

  String _formatDate(String? createdAtStr) {
    if (createdAtStr == null) return '';
    try {
      final dt = DateTime.parse(createdAtStr).toLocal();
      final year = dt.year;
      final month = dt.month.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$year-$month-$day $hour:$minute';
    } catch (_) {
      return createdAtStr;
    }
  }

  Map<String, dynamic> _mapOrder(Map<String, dynamic> o, [List<dynamic>? items]) {
    String itemsStr = '';
    if (items != null && items.isNotEmpty) {
      itemsStr = items.map((item) {
        final name = item['name'] ?? '';
        final qty = item['quantity'] ?? 1;
        
        final List<String> details = [];
        
        // Parse variants
        final List<dynamic>? vars = (item['selected_variants'] as List<dynamic>?) ?? (item['variants'] as List<dynamic>?);
        if (vars != null && vars.isNotEmpty) {
          for (var v in vars) {
            final vName = v['variant_name'] ?? '';
            final oName = v['option_label'] ?? v['option_name'] ?? '';
            if (vName.isNotEmpty && oName.isNotEmpty) {
              details.add('$vName: $oName');
            }
          }
        }
        
        // Parse addons
        final List<dynamic>? addons = (item['selected_addons'] as List<dynamic>?) ?? (item['add_ons'] as List<dynamic>?);
        if (addons != null && addons.isNotEmpty) {
          for (var a in addons) {
            final aName = a['addon_name'] ?? a['name'] ?? '';
            final aQty = a['quantity'] ?? 1;
            if (aName.isNotEmpty) {
              details.add('$aName (x$aQty)');
            }
          }
        }
        
        if (details.isNotEmpty) {
          return '$name x$qty (${details.join(", ")})';
        } else {
          return '$name x$qty';
        }
      }).join(', ');
    } else {
      itemsStr = 'Pesanan #${o['id']?.toString().substring(0, 8).toUpperCase() ?? ""}';
    }

    return {
      'id': o['id'] ?? '',
      'customer': 'Pelanggan #${(o['user_id'] ?? '').toString().substring(0, 8)}',
      'items': itemsStr,
      'total': o['total_cents'] ?? 0,
      'subtotal': o['subtotal_cents'] ?? 0,
      'delivery_fee': o['delivery_fee_cents'] ?? 0,
      'status': o['status'] ?? 'pending',
      'date': _formatDate(o['created_at']),
      'address': o['delivery_address'] ?? '',
      'notes': o['notes'] ?? '',
      'payment_method': o['payment_method'] ?? '',
      'driver_id': o['driver_id'],
      ...o,
      'raw_items': items,
    };
  }

  Future<List<Map<String, dynamic>>> getOrders(String merchantId, {String status = ''}) async {
    try {
      final response = await _api.dio.get(
        '/food/merchant/orders',
        queryParameters: status.isNotEmpty ? {'status': status} : null,
        options: Options(
          headers: {
            'X-Merchant-ID': merchantId,
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final rawOrders = (data['data'] as Map<String, dynamic>?)?['orders'] as List? ?? [];
      
      return rawOrders.map((o) => _mapOrder(Map<String, dynamic>.from(o))).toList();
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil daftar pesanan: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await _api.dio.get('/food/merchant/orders/$orderId');
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      
      final orderData = data['order'] as Map<String, dynamic>? ?? {};
      final itemsData = data['items'] as List? ?? [];
      
      return _mapOrder(orderData, itemsData);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil detail pesanan: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> confirmOrder(String orderId, int estPrepTimeMin) async {
    try {
      final response = await _api.dio.post(
        '/food/merchant/orders/$orderId/confirm',
        data: {
          'est_prep_time_min': estPrepTimeMin,
        },
      );
      final o = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return _mapOrder(o);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal menerima pesanan: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> rejectOrder(String orderId, String reason) async {
    try {
      final response = await _api.dio.post(
        '/food/merchant/orders/$orderId/reject',
        data: {
          'reason': reason,
        },
      );
      final o = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return _mapOrder(o);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal menolak pesanan: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> updatePrepStatus(String orderId, String action) async {
    try {
      final response = await _api.dio.put(
        '/food/merchant/orders/$orderId/status',
        data: {
          'action': action,
        },
      );
      final o = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return _mapOrder(o);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal memperbarui status pesanan: ${e.message}');
    }
  }
}

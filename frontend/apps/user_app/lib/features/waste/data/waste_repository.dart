import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class WasteRepository {
  final ClayApi _api;

  WasteRepository(this._api);

  // Waste category → delivery package category (reuse backend enum)
  static const _wasteCategoryMap = {
    'organik': 'food',
    'plastik': 'other',
    'kertas': 'document',
    'logam': 'electronics',
    'b3': 'fragile',
    'elektronik': 'electronics',
    'lainnya': 'other',
  };

  String _mapCategory(String wasteCategory) {
    return _wasteCategoryMap[wasteCategory] ?? 'other';
  }

  Future<Map<String, dynamic>> estimate({
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
    required String wasteCategory,
    required String wasteSize,
    double wasteWeight = 0,
  }) async {
    try {
      final response = await _api.dio.post(ApiEndpoints.deliveryEstimate, data: {
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dest_lat': destLat,
        'dest_lng': destLng,
        'package': {
          'category': _mapCategory(wasteCategory),
          'size': wasteSize,
          if (wasteWeight > 0) 'weight_kg': wasteWeight,
        },
      });

      final data = _extractData(response);
      final breakdown = data['breakdown'] as Map<String, dynamic>? ?? {};

      return {
        'distance_km': (data['distance_km'] as num).toDouble(),
        'duration_min': data['duration_min'] as int,
        'fare_estimate': (data['fare_estimate'] as num).round(),
        'surge_multiplier': data['surge_multiplier'] ?? 1.0,
        'promo_discount': (data['promo_discount'] as num?)?.round() ?? 0,
        'fare_after_promo': (data['fare_after_promo'] as num).round(),
        'breakdown': {
          'base_fare': (breakdown['base_fare'] as num?)?.round() ?? 0,
          'distance_fare': (breakdown['distance_fare'] as num?)?.round() ?? 0,
          'weight_surcharge': (breakdown['weight_surcharge'] as num?)?.round() ?? 0,
          'insurance_fee': (breakdown['insurance_fee'] as num?)?.round() ?? 0,
          'platform_fee': (breakdown['platform_fee'] as num?)?.round() ?? 0,
          'promo_discount': (breakdown['promo_discount'] as num?)?.round() ?? 0,
          'total': (breakdown['total'] as num?)?.round() ?? 0,
        },
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required String senderName,
    required String senderPhone,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required String recipientName,
    required String recipientPhone,
    required double destLat,
    required double destLng,
    required String destAddress,
    required String paymentMethod,
    required String wasteCategory,
    required String wasteSize,
    double wasteWeight = 0,
    String pickupNotes = '',
    int fareEstimate = 0,
    String? promoCode,
  }) async {
    try {
      final apiPayment = paymentMethod == 'clay_wallet' ? 'gopay' : paymentMethod;

      final response = await _api.dio.post(ApiEndpoints.deliveryCreate, data: {
        'sender_name': senderName,
        'sender_phone': senderPhone,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'pickup_address': pickupAddress,
        if (pickupNotes.isNotEmpty) 'pickup_notes': pickupNotes,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'dest_lat': destLat,
        'dest_lng': destLng,
        'dest_address': destAddress,
        'payment_method': apiPayment,
        'fare_estimate': fareEstimate.toDouble(),
        if (promoCode != null && promoCode.isNotEmpty) 'promo_id': promoCode,
        'package': {
          'category': _mapCategory(wasteCategory),
          'size': wasteSize,
          if (wasteWeight > 0) 'weight_kg': wasteWeight,
          'is_fragile': wasteCategory == 'b3' || wasteCategory == 'elektronik',
          'description': 'Waste pickup: $wasteCategory',
        },
      });

      final data = _extractData(response);
      return _mapOrderResponse(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    try {
      final response = await _api.dio.get(ApiEndpoints.deliveryOrder(orderId));
      final data = _extractData(response);
      return _mapOrderDetailResponse(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    String reason = '',
  }) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.cancelDeliveryOrder(orderId),
        data: {'reason': reason},
      );
      final data = _extractData(response);
      return _mapOrderResponse(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitRating({
    required String orderId,
    required int score,
    String comment = '',
    List<String> tags = const [],
  }) async {
    try {
      await _api.dio.post(ApiEndpoints.rateDeliveryOrder(orderId), data: {
        'score': score,
        'comment': comment,
        'tags': tags,
      });
      return {
        'message': 'rating submitted',
        'order_id': orderId,
        'score': score,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFareBreakdown(String orderId) async {
    try {
      final response = await _api.dio.get(ApiEndpoints.fareBreakdownDelivery(orderId));
      final data = _extractData(response);
      return {
        'base_fare': (data['base_fare'] as num).round(),
        'distance_fare': (data['distance_fare'] as num).round(),
        'weight_surcharge': (data['weight_surcharge'] as num?)?.round() ?? 0,
        'insurance_fee': (data['insurance_fee'] as num?)?.round() ?? 0,
        'promo_discount': (data['promo_discount'] as num?)?.round() ?? 0,
        'platform_fee': (data['platform_fee'] as num).round(),
        'total': (data['total'] as num).round(),
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDriverInfo(String driverId) async {
    try {
      final response = await _api.dio.get(ApiEndpoints.userById(driverId));
      final data = _extractData(response);
      return {
        'id': driverId,
        'name': data['full_name'] ?? 'Kurir',
        'phone': '',
        'photo_url': data['avatar_url'] ?? '',
      };
    } on DioException {
      return {
        'id': driverId,
        'name': 'Kurir',
        'phone': '',
        'photo_url': '',
      };
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Map<String, dynamic> _extractData(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }

  Map<String, dynamic> _mapOrderResponse(Map<String, dynamic> data) {
    return {
      'order_id': data['id'],
      'status': data['status'],
      'sender_name': data['sender_name'],
      'sender_phone': data['sender_phone'],
      'pickup_lat': data['pickup_lat'],
      'pickup_lng': data['pickup_lng'],
      'pickup_address': data['pickup_address'] ?? '',
      'recipient_name': data['recipient_name'],
      'recipient_phone': data['recipient_phone'],
      'dest_lat': data['dest_lat'],
      'dest_lng': data['dest_lng'],
      'dest_address': data['dest_address'] ?? '',
      'fare_estimate': (data['fare_estimate'] as num?)?.round() ?? 0,
      'fare_final': (data['fare_final'] as num?)?.round() ?? 0,
      'payment_method': data['payment_method'],
      'created_at': data['created_at'],
      if (data['driver_id'] != null && data['driver_id'] != '')
        'driver_id': data['driver_id'],
    };
  }

  Map<String, dynamic> _mapOrderDetailResponse(Map<String, dynamic> data) {
    final order = _mapOrderResponse(data);

    final pkg = data['package'] as Map<String, dynamic>?;
    if (pkg != null) {
      order['package'] = {
        'category': pkg['category'],
        'size': pkg['size'],
        'weight_kg': (pkg['weight_kg'] as num?)?.toDouble() ?? 0,
        'is_fragile': pkg['is_fragile'] ?? false,
        'description': pkg['description'] ?? '',
      };
    }

    final stateLogs = data['state_logs'] as List?;
    if (stateLogs != null) {
      order['state_logs'] = stateLogs.map((l) {
        final log = l as Map<String, dynamic>;
        return {
          'from_state': log['from_state'] ?? '',
          'to_state': log['to_state'] ?? '',
          'actor_type': log['actor_type'] ?? '',
          'changed_at': log['changed_at'] ?? '',
        };
      }).toList();
    }

    return order;
  }

  AppException _handleError(DioException e) {
    final errorMsg = e.response?.data?['message']?.toString();
    final message = errorMsg ?? (e.message ?? 'Unknown error');
    final code = e.response?.statusCode;
    if (code == 401) {
      return AuthException(message, statusCode: code);
    }
    return AppException(message, statusCode: code);
  }
}

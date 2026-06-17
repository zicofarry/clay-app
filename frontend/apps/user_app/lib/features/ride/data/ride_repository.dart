import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class RideRepository {
  final ClayApi _api;

  RideRepository(this._api);

  Future<Map<String, dynamic>> estimate({
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final results = await Future.wait([
        _api.dio.post(ApiEndpoints.rideEstimate, data: {
          'origin_lat': pickupLat,
          'origin_lng': pickupLng,
          'dest_lat': destLat,
          'dest_lng': destLng,
          'vehicle_type': 'motor',
        }),
        _api.dio.post(ApiEndpoints.rideEstimate, data: {
          'origin_lat': pickupLat,
          'origin_lng': pickupLng,
          'dest_lat': destLat,
          'dest_lng': destLng,
          'vehicle_type': 'car',
        }),
      ]);

      final motorData = _extractData(results[0]);
      final carData = _extractData(results[1]);

      return {
        'distance_km': motorData['distance_km'],
        'duration_min': motorData['duration_min'],
        'services': [
          _toService(motorData, 'ClayRide', 'bike', 3),
          _toService(carData, 'ClayCar', 'car', 5),
        ],
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double destLat,
    required double destLng,
    required String destAddress,
    required String vehicleType,
    required int fareEstimate,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      final serviceType = vehicleType == 'motor' ? 'goride' : 'gocar';
      final apiPayment = paymentMethod == 'clay_wallet' ? 'gopay' : paymentMethod;

      final response = await _api.dio.post(ApiEndpoints.rideCreate, data: {
        'service_type': serviceType,
        'vehicle_type': vehicleType,
        'origin_lat': pickupLat,
        'origin_lng': pickupLng,
        'origin_address': pickupAddress,
        'dest_lat': destLat,
        'dest_lng': destLng,
        'dest_address': destAddress,
        'payment_method': apiPayment,
        'fare_estimate': fareEstimate.toDouble(),
        if (promoCode != null && promoCode.isNotEmpty) 'promo_id': promoCode,
      });

      final data = _extractData(response);
      return _mapOrderResponse(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    try {
      final response = await _api.dio.get(ApiEndpoints.rideOrder(orderId));
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
        ApiEndpoints.cancelRideOrder(orderId),
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
      await _api.dio.post(ApiEndpoints.rateRideOrder(orderId), data: {
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
      final response = await _api.dio.get(ApiEndpoints.fareBreakdownRide(orderId));
      final data = _extractData(response);
      return {
        'base_fare': (data['base_fare'] as num).round(),
        'distance_fare': (data['distance_fare'] as num).round(),
        'time_fare': (data['time_fare'] as num).round(),
        'surge_multiplier': data['surge_multiplier'] ?? 1.0,
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
        'name': data['full_name'] ?? 'Driver',
        'phone': '',
        'plate': '',
        'vehicle': '',
        'vehicle_color': '',
        'rating': 0.0,
        'total_trips': 0,
        'photo_url': data['avatar_url'] ?? '',
      };
    } on DioException {
      return {
        'id': driverId,
        'name': 'Driver',
        'phone': '',
        'plate': '',
        'vehicle': '',
        'vehicle_color': '',
        'rating': 0.0,
        'total_trips': 0,
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

  Map<String, dynamic> _toService(
    Map<String, dynamic> apiData,
    String name,
    String icon,
    int etaOffset,
  ) {
    final distKm = (apiData['distance_km'] as num).toDouble();
    final breakdown = apiData['breakdown'] as Map<String, dynamic>? ?? {};
    return {
      'vehicle_type': apiData['vehicle_type'],
      'name': name,
      'icon': icon,
      'fare_estimate': (apiData['fare_estimate'] as num).round(),
      'fare_after_promo': (apiData['fare_after_promo'] as num).round(),
      'surge_multiplier': apiData['surge_multiplier'] ?? 1.0,
      'eta_min': (apiData['duration_min'] as int? ?? 0) + etaOffset,
      'breakdown': {
        'base_fare': (breakdown['base_fare'] as num?)?.round() ?? 0,
        'distance_fare': (breakdown['distance_fare'] as num?)?.round() ?? 0,
        'time_fare': (breakdown['time_fare'] as num?)?.round() ?? 0,
        'platform_fee': (breakdown['platform_fee'] as num?)?.round() ?? 0,
        'promo_discount': (breakdown['promo_discount'] as num?)?.round() ?? 0,
        'total': (breakdown['total'] as num?)?.round() ?? 0,
      },
    };
  }

  Map<String, dynamic> _mapOrderResponse(Map<String, dynamic> data) {
    return {
      'order_id': data['id'],
      'status': data['status'],
      'vehicle_type': data['vehicle_type'],
      'pickup_lat': data['origin_lat'],
      'pickup_lng': data['origin_lng'],
      'pickup_address': data['origin_address'] ?? '',
      'dest_lat': data['dest_lat'],
      'dest_lng': data['dest_lng'],
      'destination_address': data['dest_address'] ?? '',
      'fare_estimate': (data['fare_estimate'] as num?)?.round() ?? 0,
      'payment_method': data['payment_method'],
      'otp_code': data['otp_code'],
      'created_at': data['created_at'],
      if (data['driver_id'] != null && data['driver_id'] != '')
        'driver_id': data['driver_id'],
    };
  }

  Map<String, dynamic> _mapOrderDetailResponse(Map<String, dynamic> data) {
    final order = _mapOrderResponse(data);
    final tripDetails = data['trip_details'] as Map<String, dynamic>?;
    if (tripDetails != null) {
      order['trip_details'] = {
        'est_distance_km': tripDetails['est_distance_km'],
        'est_duration_min': tripDetails['est_duration_min'],
        'actual_distance_km': tripDetails['actual_distance_km'],
        'actual_duration_min': tripDetails['actual_duration_min'],
      };
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

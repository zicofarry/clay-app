import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class DriverOrderRepository {
  final ClayApi _api;
  DriverOrderRepository(this._api);

  Future<Map<String, dynamic>> getDispatcherStatus() async {
    try {
      final response = await _api.dio.get('/dispatcher/status');
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    try {
      final response = await _api.dio.get('/ride/orders/$orderId');
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    try {
      final response = await _api.dio.post('/ride/driver/orders/$orderId/accept');
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> rejectOrder(String orderId, {String? reason}) async {
    try {
      final response = await _api.dio.post('/ride/driver/orders/$orderId/reject', data: {
        if (reason != null) 'reason': reason,
      });
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateTripStatus(String orderId, String action, {String? otpCode, double? distanceKm, int? durationMin}) async {
    try {
      final response = await _api.dio.put('/ride/driver/orders/$orderId/status', data: {
        'action': action,
        if (otpCode != null) 'otp_code': otpCode,
        if (distanceKm != null) 'actual_distance_km': distanceKm,
        if (durationMin != null) 'actual_duration_min': durationMin,
      });
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> goOnline({String serviceType = 'ride', double lat = -6.9147, double lng = 107.6098}) async {
    try {
      await _api.dio.post(
        ApiEndpoints.driverOnline,
        data: {'service_type': serviceType, 'lat': lat, 'lng': lng},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> goOffline() async {
    try {
      await _api.dio.post(ApiEndpoints.driverOffline);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> respondToOffer(String orderId, {required String action, String? rejectReason}) async {
    try {
      await _api.dio.post('/dispatcher/respond', data: {
        'order_id': orderId,
        'action': action,
        if (rejectReason != null) 'reject_reason': rejectReason,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> heartbeat() async {
    try {
      await _api.dio.post('/dispatcher/heartbeat');
    } catch (_) {}
  }

  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _api.dio.put('/dispatcher/location', data: {'lat': lat, 'lng': lng});
    } catch (_) {}
  }

  Future<Map<String, dynamic>> setDispatchMode(String mode) async {
    try {
      final response = await _api.dio.put('/dispatcher/mode', data: {'mode': mode});
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> foodPickup(String orderId) async {
    try {
      final response = await _api.dio.post('/food/driver/orders/$orderId/pickup');
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> foodDeliver(String orderId) async {
    try {
      final response = await _api.dio.post('/food/driver/orders/$orderId/deliver');
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deliveryAccept(String orderId) async {
    try {
      final response = await _api.dio.post('/delivery/driver/orders/$orderId/accept');
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deliveryReject(String orderId, {String? reason}) async {
    try {
      final response = await _api.dio.post('/delivery/driver/orders/$orderId/reject', data: {
        if (reason != null) 'reason': reason,
      });
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deliveryUpdateStatus(String orderId, String action) async {
    try {
      final response = await _api.dio.put('/delivery/driver/orders/$orderId/status', data: {'action': action});
      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    final data = e.response?.data;
    final msg = data is Map ? (data['message']?.toString() ?? e.message ?? 'Gagal memproses order') : (e.message ?? 'Gagal memproses order');
    return AppException(msg, statusCode: e.response?.statusCode);
  }
}

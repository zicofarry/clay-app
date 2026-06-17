import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class DriverEarningRepository {
  final ClayApi _api;
  DriverEarningRepository(this._api);

  Future<Map<String, dynamic>> getTodayEarning() async {
    try {
      final response = await _api.dio.get('/dispatcher/earnings/today');
      final data = response.data as Map<String, dynamic>;
      final d = data['data'] as Map<String, dynamic>? ?? data;
      return {
        'total': d['total_earnings'] ?? d['total'] ?? 0,
        'trips': d['trip_count'] ?? d['trips'] ?? 0,
        'avg_fare': d['avg_fare'] ?? 0,
        'date': d['date'] ?? '',
      };
    } catch (_) {
      return {'total': 0, 'trips': 0, 'avg_fare': 0, 'date': ''};
    }
  }

  Future<List<Map<String, dynamic>>> getTripHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.dio.get('/driver/history/orders', queryParameters: {'page': page, 'limit': limit});
      final data = response.data as Map<String, dynamic>;
      final inner = data['data'] as Map<String, dynamic>? ?? data;
      final list = inner['data'] as List<dynamic>? ?? inner['orders'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getEarningHistory() async {
    try {
      final response = await _api.dio.get('/driver/history/earnings');
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? data['earnings'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}

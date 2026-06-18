import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/api_endpoints.dart';

class DashboardStats {
  final int totalUsers;
  final int totalDrivers;
  final int totalMerchants;
  final int totalTransactions;

  DashboardStats({
    required this.totalUsers,
    required this.totalDrivers,
    required this.totalMerchants,
    required this.totalTransactions,
  });
}

class DashboardRepository {
  final AdminApiClient _client = AdminApiClient.instance;

  Future<DashboardStats> getStats() async {
    int totalUsers = 0;
    int totalDrivers = 0;
    int totalMerchants = 0;
    int totalTransactions = 0;

    await Future.wait([
      _client.dio.get(ApiEndpoint.merchants).then((res) {
        totalMerchants = _extractTotal(res.data);
      }).catchError((_) {}),
      _client.dio.get(ApiEndpoint.historyTransactions).then((res) {
        totalTransactions = _extractTotal(res.data);
      }).catchError((_) {}),
      _client.dio.get(ApiEndpoint.historyOrderStats).then((res) {
      }).catchError((_) {}),
    ]);

    return DashboardStats(
      totalUsers: totalUsers,
      totalDrivers: totalDrivers,
      totalMerchants: totalMerchants,
      totalTransactions: totalTransactions,
    );
  }

  int _extractTotal(dynamic data) {
    if (data == null) return 0;
    if (data['meta'] != null && data['meta']['total'] != null) {
      return data['meta']['total'] as int;
    }
    if (data['data'] is List) {
      return (data['data'] as List).length;
    }
    if (data['data'] is Map && data['data']['total'] != null) {
      return data['data']['total'] as int;
    }
    return 0;
  }
}

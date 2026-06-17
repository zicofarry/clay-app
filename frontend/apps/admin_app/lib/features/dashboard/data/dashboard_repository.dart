import 'package:dio/dio.dart';

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
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080/api/v1',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  Future<DashboardStats> getStats(String token) async {
    final options = Options(headers: {'Authorization': 'Bearer $token'});

    int totalUsers = 0;
    int totalDrivers = 0;
    int totalMerchants = 0;
    int totalTransactions = 0;

    await Future.wait([
      _dio.get('/users', options: options).then((res) {
        totalUsers = _extractTotal(res.data);
      }).catchError((_) {}),
      _dio.get('/drivers', options: options).then((res) {
        totalDrivers = _extractTotal(res.data);
      }).catchError((_) {}),
      _dio.get('/merchants', options: options).then((res) {
        totalMerchants = _extractTotal(res.data);
      }).catchError((_) {}),
      _dio.get('/history/transactions', options: options).then((res) {
        totalTransactions = _extractTotal(res.data);
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
    if (data['data'] != null) {
      if (data['data'] is List) {
        return (data['data'] as List).length;
      }
      if (data['data']['total'] != null) {
         return data['data']['total'] as int;
      }
    }
    return 0;
  }
}

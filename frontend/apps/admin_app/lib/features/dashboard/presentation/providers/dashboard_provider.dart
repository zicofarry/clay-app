import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/admin_auth_provider.dart';
import '../../data/dashboard_repository.dart';

final dashboardRepoProvider = Provider((ref) => DashboardRepository());

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final authState = ref.watch(adminAuthProvider);
  final token = authState.admin?['token'] as String?;
  
  if (token == null) {
    return DashboardStats(totalUsers: 0, totalDrivers: 0, totalMerchants: 0, totalTransactions: 0);
  }
  
  final repo = ref.watch(dashboardRepoProvider);
  return await repo.getStats(token);
});

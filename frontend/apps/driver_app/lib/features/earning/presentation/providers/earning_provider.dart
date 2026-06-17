import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/driver_earning_repository.dart';

final earningRepositoryProvider = Provider<DriverEarningRepository>((ref) {
  return DriverEarningRepository(ClayApi.instance);
});

final todayEarningProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(earningRepositoryProvider).getTodayEarning();
});

final tripHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(earningRepositoryProvider).getTripHistory();
});

final earningHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(earningRepositoryProvider).getEarningHistory();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../orders/data/order_repository.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../auth/presentation/providers/merchant_auth_provider.dart';

class ReportState {
  final bool isLoading;
  final String? error;
  final int todaySales;
  final int weekSales;
  final int monthSales;
  final int totalSales;
  final int totalOrdersToday;
  final int completedOrdersToday;
  final int cancelledOrdersToday;
  final int avgOrderValueToday;
  final List<Map<String, dynamic>> topSellingItems;

  const ReportState({
    this.isLoading = false,
    this.error,
    this.todaySales = 0,
    this.weekSales = 0,
    this.monthSales = 0,
    this.totalSales = 0,
    this.totalOrdersToday = 0,
    this.completedOrdersToday = 0,
    this.cancelledOrdersToday = 0,
    this.avgOrderValueToday = 0,
    this.topSellingItems = const [],
  });

  ReportState copyWith({
    bool? isLoading,
    String? error,
    int? todaySales,
    int? weekSales,
    int? monthSales,
    int? totalSales,
    int? totalOrdersToday,
    int? completedOrdersToday,
    int? cancelledOrdersToday,
    int? avgOrderValueToday,
    List<Map<String, dynamic>>? topSellingItems,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      todaySales: todaySales ?? this.todaySales,
      weekSales: weekSales ?? this.weekSales,
      monthSales: monthSales ?? this.monthSales,
      totalSales: totalSales ?? this.totalSales,
      totalOrdersToday: totalOrdersToday ?? this.totalOrdersToday,
      completedOrdersToday: completedOrdersToday ?? this.completedOrdersToday,
      cancelledOrdersToday: cancelledOrdersToday ?? this.cancelledOrdersToday,
      avgOrderValueToday: avgOrderValueToday ?? this.avgOrderValueToday,
      topSellingItems: topSellingItems ?? this.topSellingItems,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final OrderRepository _orderRepo;
  final Ref _ref;

  ReportNotifier(this._orderRepo, this._ref) : super(const ReportState());

  Future<void> loadReportData() async {
    final m = _ref.read(merchantAuthProvider).merchant;
    if (m == null || m['id'] == null) {
      state = const ReportState();
      return;
    }
    final merchantId = m['id'];

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Fetch delivered, cancelled, and active orders to compute sales stats
      final deliveredOrders = await _orderRepo.getOrders(merchantId, status: 'delivered');
      final cancelledOrders = await _orderRepo.getOrders(merchantId, status: 'cancelled');
      final activeOrders = await _orderRepo.getOrders(merchantId);

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final monthStart = DateTime(now.year, now.month, 1);

      int todaySales = 0;
      int weekSales = 0;
      int monthSales = 0;
      int totalSales = 0;

      int totalOrdersToday = 0;
      int completedOrdersToday = 0;
      int cancelledOrdersToday = 0;
      int todaySalesSumForAvg = 0;

      final Map<String, int> itemCounts = {};

      // 1. Process delivered orders for actual sales/revenue
      for (var o in deliveredOrders) {
        final orderDateStr = o['created_at'] ?? o['date'];
        if (orderDateStr == null) continue;
        final orderDate = DateTime.tryParse(orderDateStr)?.toLocal();
        if (orderDate == null) continue;

        final int total = ((o['total_cents'] ?? o['total'] ?? 0) as num).toInt();
        
        totalSales += total;
        if (orderDate.isAfter(todayStart)) {
          todaySales += total;
          completedOrdersToday++;
          totalOrdersToday++;
          todaySalesSumForAvg += total;
        }
        if (orderDate.isAfter(weekStartDate)) {
          weekSales += total;
        }
        if (orderDate.isAfter(monthStart)) {
          monthSales += total;
        }
      }

      // 2. Process cancelled orders
      for (var o in cancelledOrders) {
        final orderDateStr = o['created_at'] ?? o['date'];
        if (orderDateStr == null) continue;
        final orderDate = DateTime.tryParse(orderDateStr)?.toLocal();
        if (orderDate == null) continue;

        if (orderDate.isAfter(todayStart)) {
          cancelledOrdersToday++;
          totalOrdersToday++;
        }
      }

      // 3. Process active orders (pending, confirmed, preparing, ready, etc.)
      for (var o in activeOrders) {
        final orderDateStr = o['created_at'] ?? o['date'];
        if (orderDateStr == null) continue;
        final orderDate = DateTime.tryParse(orderDateStr)?.toLocal();
        if (orderDate == null) continue;

        if (orderDate.isAfter(todayStart)) {
          totalOrdersToday++;
        }
      }

      // 4. Fetch details for delivered orders to compute Top Selling Menu
      // Fetch details in parallel, capping at the most recent 10 to avoid performance hits
      final recentDelivered = deliveredOrders.take(10).toList();
      final List<Future<Map<String, dynamic>>> detailFutures = recentDelivered.map((o) => _orderRepo.getOrderById(o['id'])).toList();
      final detailedOrders = await Future.wait(detailFutures).catchError((_) => <Map<String, dynamic>>[]);

      for (var o in detailedOrders) {
        final rawItems = o['raw_items'] as List<dynamic>?;
        if (rawItems != null) {
          for (var item in rawItems) {
            final name = item['name'] as String? ?? '';
            final qty = item['quantity'] as int? ?? 1;
            if (name.isNotEmpty) {
              itemCounts[name] = (itemCounts[name] ?? 0) + qty;
            }
          }
        }
      }

      // Convert itemCounts to list of maps and sort
      final sortedItems = itemCounts.entries
          .map((entry) => {'name': entry.key, 'count': entry.value})
          .toList();
      sortedItems.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      final avgOrder = completedOrdersToday > 0 ? (todaySalesSumForAvg ~/ completedOrdersToday) : 0;

      state = ReportState(
        isLoading: false,
        todaySales: todaySales,
        weekSales: weekSales,
        monthSales: monthSales,
        totalSales: totalSales,
        totalOrdersToday: totalOrdersToday,
        completedOrdersToday: completedOrdersToday,
        cancelledOrdersToday: cancelledOrdersToday,
        avgOrderValueToday: avgOrder,
        topSellingItems: sortedItems,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final orderRepo = ref.watch(merchantOrderRepositoryProvider);
  return ReportNotifier(orderRepo, ref);
});

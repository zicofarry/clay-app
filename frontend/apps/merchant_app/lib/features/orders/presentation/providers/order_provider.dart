import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../../auth/presentation/providers/merchant_auth_provider.dart';
import '../../data/order_repository.dart';

final merchantOrderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ClayApi.instance);
});

final merchantOrderProvider = StateNotifierProvider<MerchantOrderNotifier, MerchantOrderState>((ref) {
  final repo = ref.watch(merchantOrderRepositoryProvider);
  return MerchantOrderNotifier(repo, ref);
});

class MerchantOrderState {
  final List<Map<String, dynamic>> orders;
  final bool isLoading;
  final String? error;

  const MerchantOrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  MerchantOrderState copyWith({
    List<Map<String, dynamic>>? orders,
    bool? isLoading,
    String? error,
  }) {
    return MerchantOrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MerchantOrderNotifier extends StateNotifier<MerchantOrderState> {
  final OrderRepository _repo;
  final Ref _ref;

  MerchantOrderNotifier(this._repo, this._ref) : super(const MerchantOrderState());

  Future<void> loadOrders() async {
    final m = _ref.read(merchantAuthProvider).merchant;
    if (m == null || m['id'] == null) {
      state = state.copyWith(orders: []);
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await _repo.getOrders(m['id']);
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>> loadOrderDetail(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orderDetail = await _repo.getOrderById(orderId);
      final updatedOrders = state.orders.map((o) => o['id'] == orderId ? orderDetail : o).toList();
      if (!state.orders.any((o) => o['id'] == orderId)) {
        updatedOrders.add(orderDetail);
      }
      state = state.copyWith(orders: updatedOrders, isLoading: false);
      return orderDetail;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> confirmOrder(String orderId, int estPrepTimeMin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.confirmOrder(orderId, estPrepTimeMin);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.rejectOrder(orderId, reason);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updatePrepStatus(String orderId, String action) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.updatePrepStatus(orderId, action);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Legacy compatibility mapping
  Future<void> updateStatus(String id, String status) async {
    if (status == 'processing') {
      await confirmOrder(id, 15);
    } else if (status == 'cancelled') {
      await rejectOrder(id, 'Dibatalkan');
    } else if (status == 'ready') {
      await updatePrepStatus(id, 'mark_ready');
    } else if (status == 'preparing') {
      await updatePrepStatus(id, 'start_preparing');
    } else {
      await loadOrders();
    }
  }
}

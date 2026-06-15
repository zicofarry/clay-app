import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_order_repository.dart';

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(MockOrderRepository());
});

class OrderState {
  final bool isLoading;
  final List<Map<String, dynamic>> incoming;
  final Map<String, dynamic>? activeOrder;

  const OrderState({this.isLoading = false, this.incoming = const [], this.activeOrder});

  OrderState copyWith({bool? isLoading, List<Map<String, dynamic>>? incoming, Map<String, dynamic>? activeOrder}) {
    return OrderState(isLoading: isLoading ?? this.isLoading, incoming: incoming ?? this.incoming, activeOrder: activeOrder ?? this.activeOrder);
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final MockOrderRepository _repo;
  OrderNotifier(this._repo) : super(const OrderState());

  Future<void> loadIncoming() async {
    state = state.copyWith(isLoading: true);
    final orders = await _repo.getIncomingOrders();
    state = state.copyWith(isLoading: false, incoming: orders);
  }

  Future<void> acceptOrder(String id) async {
    await _repo.acceptOrder(id);
    final order = state.incoming.firstWhere((o) => o['id'] == id);
    state = state.copyWith(activeOrder: order, incoming: state.incoming.where((o) => o['id'] != id).toList());
  }

  Future<void> rejectOrder(String id) async {
    await _repo.rejectOrder(id);
    state = state.copyWith(incoming: state.incoming.where((o) => o['id'] != id).toList());
  }

  Future<void> updateStatus(String status) async {
    if (state.activeOrder != null) {
      await _repo.updateStatus(state.activeOrder!['id'], status);
    }
  }

  void completeOrder() {
    state = state.copyWith(activeOrder: null);
  }
}

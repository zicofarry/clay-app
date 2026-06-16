import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_order_repository.dart';

final merchantOrderProvider = StateNotifierProvider<MerchantOrderNotifier, MerchantOrderState>((ref) {
  return MerchantOrderNotifier(MockOrderRepository());
});

class MerchantOrderState {
  final List<Map<String, dynamic>> orders;
  final bool isLoading;

  const MerchantOrderState({this.orders = const [], this.isLoading = false});

  MerchantOrderState copyWith({List<Map<String, dynamic>>? orders, bool? isLoading}) {
    return MerchantOrderState(orders: orders ?? this.orders, isLoading: isLoading ?? this.isLoading);
  }
}

class MerchantOrderNotifier extends StateNotifier<MerchantOrderState> {
  final MockOrderRepository _repo;
  MerchantOrderNotifier(this._repo) : super(const MerchantOrderState());

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true);
    final orders = await _repo.getOrders();
    state = MerchantOrderState(orders: orders);
  }

  Future<void> updateStatus(String id, String status) async {
    await _repo.updateStatus(id, status);
    await loadOrders();
  }
}

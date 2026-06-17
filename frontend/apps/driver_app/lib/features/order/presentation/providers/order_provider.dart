import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/driver_order_repository.dart';

final orderRepositoryProvider = Provider<DriverOrderRepository>((ref) {
  return DriverOrderRepository(ClayApi.instance);
});

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref.watch(orderRepositoryProvider));
});

class OrderState {
  final bool isLoading;
  final Map<String, dynamic>? incomingOrder;
  final Map<String, dynamic>? activeOrder;
  final Map<String, dynamic>? lastCompletedOrder;
  final String? otpCode;

  const OrderState({this.isLoading = false, this.incomingOrder, this.activeOrder, this.lastCompletedOrder, this.otpCode});

  OrderState copyWith({
    bool? isLoading,
    Map<String, dynamic>? incomingOrder,
    Map<String, dynamic>? activeOrder,
    Map<String, dynamic>? lastCompletedOrder,
    String? otpCode,
    bool clearIncoming = false,
    bool clearActive = false,
    bool clearOtp = false,
    bool clearLastCompleted = false,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      incomingOrder: clearIncoming ? null : (incomingOrder ?? this.incomingOrder),
      activeOrder: clearActive ? null : (activeOrder ?? this.activeOrder),
      lastCompletedOrder: clearLastCompleted ? null : (lastCompletedOrder ?? this.lastCompletedOrder),
      otpCode: clearOtp ? null : (otpCode ?? this.otpCode),
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final DriverOrderRepository _repo;
  OrderNotifier(this._repo) : super(const OrderState());

  Future<void> checkDispatch() async {
    if (state.activeOrder != null) return;
    try {
      final status = await _repo.getDispatcherStatus();
      final activeOrderId = status['active_order_id'] as String?;
      if (activeOrderId != null && activeOrderId.isNotEmpty && state.incomingOrder == null) {
        final order = await _repo.getOrderDetail(activeOrderId);
        state = state.copyWith(incomingOrder: order);
      }
    } catch (_) {}
  }

  Future<void> acceptOrder() async {
    if (state.incomingOrder == null) return;
    final orderId = state.incomingOrder!['id']?.toString();
    if (orderId == null) return;
    final result = await _repo.acceptOrder(orderId);
    state = state.copyWith(
      activeOrder: result,
      otpCode: result['otp_code']?.toString(),
      clearIncoming: true,
    );
  }

  Future<void> rejectOrder({String? reason}) async {
    if (state.incomingOrder == null) return;
    final orderId = state.incomingOrder!['id']?.toString();
    if (orderId == null) return;
    await _repo.rejectOrder(orderId, reason: reason);
    state = state.copyWith(clearIncoming: true);
  }

  Future<void> updateTripStatus(String action) async {
    if (state.activeOrder == null) return;
    final orderId = state.activeOrder!['id']?.toString();
    if (orderId == null) return;

    String? otpCode;
    if (action == 'start_trip') {
      otpCode = state.otpCode;
    }

    final result = await _repo.updateTripStatus(orderId, action, otpCode: otpCode);
    state = state.copyWith(activeOrder: result);
  }

  void completeOrder() {
    state = state.copyWith(
      lastCompletedOrder: state.activeOrder,
      clearActive: true,
      clearOtp: true,
    );
  }

  void clearLastCompleted() {
    state = state.copyWith(clearLastCompleted: true);
  }
}

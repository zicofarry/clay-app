import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/mock_ride_repository.dart';

final mockRideRepoProvider = Provider<MockRideRepository>((ref) => MockRideRepository());

final rideStateProvider = StateNotifierProvider<RideNotifier, RideState>((ref) {
  return RideNotifier(ref.watch(mockRideRepoProvider));
});

class RideState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? estimate;
  final Map<String, dynamic>? activeOrder;
  final List<Map<String, dynamic>> history;

  const RideState({
    this.isLoading = false,
    this.error,
    this.estimate,
    this.activeOrder,
    this.history = const [],
  });

  RideState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? estimate,
    Map<String, dynamic>? activeOrder,
    List<Map<String, dynamic>>? history,
  }) {
    return RideState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      estimate: estimate ?? this.estimate,
      activeOrder: activeOrder ?? this.activeOrder,
      history: history ?? this.history,
    );
  }
}

class RideNotifier extends StateNotifier<RideState> {
  final MockRideRepository _repo;

  RideNotifier(this._repo) : super(const RideState());

  Future<void> estimate({
    required double pickupLat, required double pickupLng,
    required double destLat, required double destLng,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.estimate(
        pickupLat: pickupLat, pickupLng: pickupLng,
        destLat: destLat, destLng: destLng,
      );
      state = state.copyWith(isLoading: false, estimate: result);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> createOrder({
    required double pickupLat, required double pickupLng, required String pickupAddress,
    required double destLat, required double destLng, required String destAddress,
    required String serviceType, required int price,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final order = await _repo.createOrder(
        pickupLat: pickupLat, pickupLng: pickupLng, pickupAddress: pickupAddress,
        destLat: destLat, destLng: destLng, destAddress: destAddress,
        serviceType: serviceType, price: price,
      );
      state = state.copyWith(isLoading: false, activeOrder: order);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadActiveOrder() async {
    final order = await _repo.getActiveOrder();
    state = state.copyWith(activeOrder: order);
  }

  Future<void> loadHistory() async {
    final list = await _repo.getHistory();
    state = state.copyWith(history: list);
  }
}

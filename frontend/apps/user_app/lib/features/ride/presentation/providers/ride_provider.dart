import 'dart:async';
import 'package:clay_shared/clay_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ride_repository.dart';

final rideRepoProvider = Provider<RideRepository>((ref) {
  return RideRepository(ClayApi.instance);
});

final rideStateProvider = StateNotifierProvider<RideNotifier, RideState>((ref) {
  return RideNotifier(ref.watch(rideRepoProvider));
});

// ── Ride State ────────────────────────────────────────────────────────────

class RideState {
  final bool isLoading;
  final String? error;

  // Locations
  final double? pickupLat;
  final double? pickupLng;
  final String pickupAddress;
  final double? destLat;
  final double? destLng;
  final String destAddress;

  // Estimate
  final Map<String, dynamic>? estimate;
  final double distanceKm;
  final int durationMin;

  // Selected service
  final Map<String, dynamic>? selectedService;

  // Order
  final String paymentMethod;
  final String? promoCode;
  final Map<String, dynamic>? activeOrder;
  final String orderStatus;

  // Driver
  final Map<String, dynamic>? driverInfo;
  final String? otpCode;
  final int etaSeconds;

  // Fare
  final Map<String, dynamic>? fareBreakdown;

  const RideState({
    this.isLoading = false,
    this.error,
    this.pickupLat,
    this.pickupLng,
    this.pickupAddress = '',
    this.destLat,
    this.destLng,
    this.destAddress = '',
    this.estimate,
    this.distanceKm = 0,
    this.durationMin = 0,
    this.selectedService,
    this.paymentMethod = 'clay_wallet',
    this.promoCode,
    this.activeOrder,
    this.orderStatus = '',
    this.driverInfo,
    this.otpCode,
    this.etaSeconds = 0,
    this.fareBreakdown,
  });

  RideState copyWith({
    bool? isLoading,
    String? error,
    double? pickupLat,
    double? pickupLng,
    String? pickupAddress,
    double? destLat,
    double? destLng,
    String? destAddress,
    Map<String, dynamic>? estimate,
    double? distanceKm,
    int? durationMin,
    Map<String, dynamic>? selectedService,
    String? paymentMethod,
    String? promoCode,
    Map<String, dynamic>? activeOrder,
    String? orderStatus,
    Map<String, dynamic>? driverInfo,
    String? otpCode,
    int? etaSeconds,
    Map<String, dynamic>? fareBreakdown,
    bool clearError = false,
    bool clearEstimate = false,
    bool clearSelectedService = false,
    bool clearActiveOrder = false,
    bool clearDriverInfo = false,
    bool clearFareBreakdown = false,
  }) {
    return RideState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      destAddress: destAddress ?? this.destAddress,
      estimate: clearEstimate ? null : (estimate ?? this.estimate),
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      selectedService: clearSelectedService ? null : (selectedService ?? this.selectedService),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      activeOrder: clearActiveOrder ? null : (activeOrder ?? this.activeOrder),
      orderStatus: orderStatus ?? this.orderStatus,
      driverInfo: clearDriverInfo ? null : (driverInfo ?? this.driverInfo),
      otpCode: otpCode ?? this.otpCode,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      fareBreakdown: clearFareBreakdown ? null : (fareBreakdown ?? this.fareBreakdown),
    );
  }
}

// ── Ride Notifier ─────────────────────────────────────────────────────────

class RideNotifier extends StateNotifier<RideState> {
  final RideRepository _repo;
  Timer? _pollTimer;
  String? _lastDriverId;

  RideNotifier(this._repo) : super(const RideState());

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Location ──

  void setPickupLocation(double lat, double lng, String address) {
    state = state.copyWith(
      pickupLat: lat,
      pickupLng: lng,
      pickupAddress: address,
      clearError: true,
    );
  }

  void setDestLocation(double lat, double lng, String address) {
    state = state.copyWith(
      destLat: lat,
      destLng: lng,
      destAddress: address,
      clearError: true,
    );
  }

  // ── Estimate ──

  Future<void> estimateFare() async {
    if (state.pickupLat == null || state.destLat == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.estimate(
        pickupLat: state.pickupLat!,
        pickupLng: state.pickupLng!,
        destLat: state.destLat!,
        destLng: state.destLng!,
      );
      state = state.copyWith(
        isLoading: false,
        estimate: result,
        distanceKm: (result['distance_km'] as num).toDouble(),
        durationMin: result['duration_min'] as int,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Select Service ──

  void selectService(Map<String, dynamic> service) {
    state = state.copyWith(selectedService: service, clearError: true);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setPromoCode(String? code) {
    state = state.copyWith(promoCode: code);
  }

  // ── Create Order ──

  Future<void> confirmOrder() async {
    if (state.selectedService == null) return;
    if (state.pickupLat == null || state.destLat == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final order = await _repo.createOrder(
        pickupLat: state.pickupLat!,
        pickupLng: state.pickupLng!,
        pickupAddress: state.pickupAddress,
        destLat: state.destLat!,
        destLng: state.destLng!,
        destAddress: state.destAddress,
        vehicleType: state.selectedService!['vehicle_type'] as String,
        fareEstimate: state.selectedService!['fare_estimate'] as int,
        paymentMethod: state.paymentMethod,
        promoCode: state.promoCode,
      );

      state = state.copyWith(
        isLoading: false,
        activeOrder: order,
        orderStatus: order['status'] as String,
        otpCode: order['otp_code'] as String?,
      );

      _startPolling(order['order_id'] as String);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Polling ──

  void _startPolling(String orderId) {
    _pollTimer?.cancel();
    _lastDriverId = null;

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      try {
        final detail = await _repo.getOrderDetail(orderId);
        if (!mounted) return;

        final newStatus = detail['status'] as String;
        final driverId = detail['driver_id'] as String?;

        // Update status in state
        state = state.copyWith(
          orderStatus: newStatus,
          otpCode: detail['otp_code'] as String? ?? state.otpCode,
        );

        // Fetch driver info when driver is assigned
        if (driverId != null && driverId.isNotEmpty && driverId != _lastDriverId) {
          _lastDriverId = driverId;
          _fetchDriverInfo(driverId);
        }

        // Fetch fare breakdown on completion
        if (newStatus == 'completed') {
          _stopPolling();
          _fetchFareBreakdown(orderId);
        }

        // Stop polling on terminal states
        if (newStatus == 'cancelled') {
          _stopPolling();
        }
      } catch (_) {
        // Silently retry on next tick
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _fetchDriverInfo(String driverId) async {
    try {
      final info = await _repo.getDriverInfo(driverId);
      if (!mounted) return;
      state = state.copyWith(driverInfo: info);
    } catch (_) {
      // Non-critical — UI will show placeholders
    }
  }

  Future<void> _fetchFareBreakdown(String orderId) async {
    try {
      final breakdown = await _repo.getFareBreakdown(orderId);
      if (!mounted) return;
      state = state.copyWith(fareBreakdown: breakdown);
    } catch (_) {
      // Non-critical
    }
  }

  // ── Cancel ──

  Future<void> cancelOrder({String reason = ''}) async {
    final orderId = state.activeOrder?['order_id'] as String? ?? '';
    _stopPolling();
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repo.cancelOrder(orderId: orderId, reason: reason);
      state = state.copyWith(
        isLoading: false,
        orderStatus: 'cancelled',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Rating ──

  Future<void> submitRating({
    required int score,
    String comment = '',
    List<String> tags = const [],
  }) async {
    final orderId = state.activeOrder?['order_id'] as String? ?? '';
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repo.submitRating(
        orderId: orderId,
        score: score,
        comment: comment,
        tags: tags,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Reset ──

  void resetRide() {
    _stopPolling();
    _lastDriverId = null;
    state = const RideState();
  }
}

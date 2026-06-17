import 'dart:async';
import 'package:clay_shared/clay_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/send_repository.dart';

final sendRepoProvider = Provider<SendRepository>((ref) {
  return SendRepository(ClayApi.instance);
});

final sendStateProvider = StateNotifierProvider<SendNotifier, SendState>((ref) {
  return SendNotifier(ref.watch(sendRepoProvider));
});

// ── Send State ────────────────────────────────────────────────────────────

class SendState {
  final bool isLoading;
  final String? error;

  // Locations
  final double? pickupLat;
  final double? pickupLng;
  final String pickupAddress;
  final double? destLat;
  final double? destLng;
  final String destAddress;

  // Package
  final String packageCategory;
  final String packageSize;
  final double packageWeight;
  final String packageDescription;
  final bool isFragile;
  final double insuranceValue;

  // Sender / Recipient
  final String senderName;
  final String senderPhone;
  final String recipientName;
  final String recipientPhone;

  // Estimate
  final Map<String, dynamic>? estimate;
  final double distanceKm;
  final int durationMin;

  // Order
  final String paymentMethod;
  final String? promoCode;
  final Map<String, dynamic>? activeOrder;
  final String orderStatus;

  // Driver
  final Map<String, dynamic>? driverInfo;

  // Fare
  final Map<String, dynamic>? fareBreakdown;

  const SendState({
    this.isLoading = false,
    this.error,
    this.pickupLat,
    this.pickupLng,
    this.pickupAddress = '',
    this.destLat,
    this.destLng,
    this.destAddress = '',
    this.packageCategory = '',
    this.packageSize = '',
    this.packageWeight = 0,
    this.packageDescription = '',
    this.isFragile = false,
    this.insuranceValue = 0,
    this.senderName = '',
    this.senderPhone = '',
    this.recipientName = '',
    this.recipientPhone = '',
    this.estimate,
    this.distanceKm = 0,
    this.durationMin = 0,
    this.paymentMethod = 'clay_wallet',
    this.promoCode,
    this.activeOrder,
    this.orderStatus = '',
    this.driverInfo,
    this.fareBreakdown,
  });

  SendState copyWith({
    bool? isLoading,
    String? error,
    double? pickupLat,
    double? pickupLng,
    String? pickupAddress,
    double? destLat,
    double? destLng,
    String? destAddress,
    String? packageCategory,
    String? packageSize,
    double? packageWeight,
    String? packageDescription,
    bool? isFragile,
    double? insuranceValue,
    String? senderName,
    String? senderPhone,
    String? recipientName,
    String? recipientPhone,
    Map<String, dynamic>? estimate,
    double? distanceKm,
    int? durationMin,
    String? paymentMethod,
    String? promoCode,
    Map<String, dynamic>? activeOrder,
    String? orderStatus,
    Map<String, dynamic>? driverInfo,
    Map<String, dynamic>? fareBreakdown,
    bool clearError = false,
    bool clearEstimate = false,
    bool clearActiveOrder = false,
    bool clearDriverInfo = false,
    bool clearFareBreakdown = false,
  }) {
    return SendState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      destAddress: destAddress ?? this.destAddress,
      packageCategory: packageCategory ?? this.packageCategory,
      packageSize: packageSize ?? this.packageSize,
      packageWeight: packageWeight ?? this.packageWeight,
      packageDescription: packageDescription ?? this.packageDescription,
      isFragile: isFragile ?? this.isFragile,
      insuranceValue: insuranceValue ?? this.insuranceValue,
      senderName: senderName ?? this.senderName,
      senderPhone: senderPhone ?? this.senderPhone,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      estimate: clearEstimate ? null : (estimate ?? this.estimate),
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      activeOrder: clearActiveOrder ? null : (activeOrder ?? this.activeOrder),
      orderStatus: orderStatus ?? this.orderStatus,
      driverInfo: clearDriverInfo ? null : (driverInfo ?? this.driverInfo),
      fareBreakdown: clearFareBreakdown ? null : (fareBreakdown ?? this.fareBreakdown),
    );
  }
}

// ── Send Notifier ─────────────────────────────────────────────────────────

class SendNotifier extends StateNotifier<SendState> {
  final SendRepository _repo;
  Timer? _pollTimer;
  String? _lastDriverId;

  SendNotifier(this._repo) : super(const SendState());

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

  // ── Package ──

  void setPackageInfo({
    String? category,
    String? size,
    double? weight,
    String? description,
    bool? isFragile,
    double? insuranceValue,
  }) {
    state = state.copyWith(
      packageCategory: category ?? state.packageCategory,
      packageSize: size ?? state.packageSize,
      packageWeight: weight ?? state.packageWeight,
      packageDescription: description ?? state.packageDescription,
      isFragile: isFragile ?? state.isFragile,
      insuranceValue: insuranceValue ?? state.insuranceValue,
      clearError: true,
      clearEstimate: true,
    );
  }

  // ── Sender / Recipient ──

  void setSenderInfo(String name, String phone) {
    state = state.copyWith(senderName: name, senderPhone: phone);
  }

  void setRecipientInfo(String name, String phone) {
    state = state.copyWith(recipientName: name, recipientPhone: phone);
  }

  // ── Payment ──

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setPromoCode(String? code) {
    state = state.copyWith(promoCode: code);
  }

  // ── Estimate ──

  Future<void> estimateFare() async {
    if (state.pickupLat == null || state.destLat == null) return;
    if (state.packageCategory.isEmpty || state.packageSize.isEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.estimate(
        pickupLat: state.pickupLat!,
        pickupLng: state.pickupLng!,
        destLat: state.destLat!,
        destLng: state.destLng!,
        packageCategory: state.packageCategory,
        packageSize: state.packageSize,
        packageWeight: state.packageWeight,
        insuranceValue: state.insuranceValue,
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

  // ── Create Order ──

  Future<void> confirmOrder() async {
    if (state.pickupLat == null || state.destLat == null) return;
    if (state.senderName.isEmpty || state.recipientName.isEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final fareEstimate = state.estimate?['fare_estimate'] as int? ?? 0;

      final order = await _repo.createOrder(
        senderName: state.senderName,
        senderPhone: state.senderPhone,
        pickupLat: state.pickupLat!,
        pickupLng: state.pickupLng!,
        pickupAddress: state.pickupAddress,
        recipientName: state.recipientName,
        recipientPhone: state.recipientPhone,
        destLat: state.destLat!,
        destLng: state.destLng!,
        destAddress: state.destAddress,
        paymentMethod: state.paymentMethod,
        packageCategory: state.packageCategory,
        packageSize: state.packageSize,
        packageWeight: state.packageWeight,
        packageDescription: state.packageDescription,
        isFragile: state.isFragile,
        insuranceValue: state.insuranceValue,
        fareEstimate: fareEstimate,
        promoCode: state.promoCode,
      );

      state = state.copyWith(
        isLoading: false,
        activeOrder: order,
        orderStatus: order['status'] as String,
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

        state = state.copyWith(orderStatus: newStatus);

        if (driverId != null && driverId.isNotEmpty && driverId != _lastDriverId) {
          _lastDriverId = driverId;
          _fetchDriverInfo(driverId);
        }

        if (newStatus == 'delivered') {
          _stopPolling();
          _fetchFareBreakdown(orderId);
        }

        if (newStatus == 'cancelled') {
          _stopPolling();
        }
      } catch (_) {}
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
    } catch (_) {}
  }

  Future<void> _fetchFareBreakdown(String orderId) async {
    try {
      final breakdown = await _repo.getFareBreakdown(orderId);
      if (!mounted) return;
      state = state.copyWith(fareBreakdown: breakdown);
    } catch (_) {}
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

  void resetSend() {
    _stopPolling();
    _lastDriverId = null;
    state = const SendState();
  }
}

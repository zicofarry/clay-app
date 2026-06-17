import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/ride_provider.dart';

class RideConfirmScreen extends ConsumerStatefulWidget {
  const RideConfirmScreen({super.key});

  @override
  ConsumerState<RideConfirmScreen> createState() => _RideConfirmScreenState();
}

class _RideConfirmScreenState extends ConsumerState<RideConfirmScreen> {
  final _promoController = TextEditingController();
  bool _showPromoInput = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    final str = amount.abs().toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideStateProvider);
    final service = state.selectedService;

    if (service == null) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada layanan dipilih')),
      );
    }

    final fare = service['fare_estimate'] as int;
    final etaMin = service['eta_min'] as int;
    final serviceName = service['name'] as String;
    final breakdown = service['breakdown'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Map preview ──
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      ((state.pickupLat ?? 0) + (state.destLat ?? 0)) / 2,
                      ((state.pickupLng ?? 0) + (state.destLng ?? 0)) / 2,
                    ),
                    initialZoom: 13,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.clay.user_app',
                    ),
                    MarkerLayer(
                      markers: [
                        if (state.pickupLat != null)
                          Marker(
                            point: LatLng(state.pickupLat!, state.pickupLng!),
                            child: const Icon(Icons.radio_button_checked, color: Colors.green, size: 24),
                          ),
                        if (state.destLat != null)
                          Marker(
                            point: LatLng(state.destLat!, state.destLng!),
                            child: const Icon(Icons.location_on, color: Colors.red, size: 28),
                          ),
                      ],
                    ),
                    if (state.pickupLat != null && state.destLat != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              LatLng(state.pickupLat!, state.pickupLng!),
                              LatLng(state.destLat!, state.destLng!),
                            ],
                            color: ClayColors.primary,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                  ],
                ),
                // Back button overlay
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Ride summary ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ClayColors.muted,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: ClayColors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.pickupAddress,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Container(
                            width: 2,
                            height: 16,
                            color: ClayColors.divider,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: ClayColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.destAddress,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Service selected ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ClayColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ClayColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: ClayColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            service['icon'] == 'car' ? Icons.directions_car : Icons.two_wheeler,
                            color: ClayColors.primaryDark,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '~$etaMin menit • ${state.distanceKm} km',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: ClayColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rp${_formatCurrency(fare)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: ClayColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Payment method ──
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PaymentOption(
                    icon: Icons.account_balance_wallet,
                    label: 'ClayWallet',
                    isSelected: state.paymentMethod == 'clay_wallet',
                    onTap: () => ref.read(rideStateProvider.notifier).setPaymentMethod('clay_wallet'),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    icon: Icons.payments_outlined,
                    label: 'Cash',
                    isSelected: state.paymentMethod == 'cash',
                    onTap: () => ref.read(rideStateProvider.notifier).setPaymentMethod('cash'),
                  ),

                  const SizedBox(height: 20),

                  // ── Promo ──
                  GestureDetector(
                    onTap: () => setState(() => _showPromoInput = !_showPromoInput),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer_outlined, size: 20, color: ClayColors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Punya kode promo?',
                          style: TextStyle(
                            fontSize: 14,
                            color: ClayColors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _showPromoInput ? Icons.expand_less : Icons.expand_more,
                          color: ClayColors.green,
                        ),
                      ],
                    ),
                  ),
                  if (_showPromoInput) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan kode promo',
                              hintStyle: const TextStyle(fontSize: 14),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: ClayColors.divider),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(rideStateProvider.notifier).setPromoCode(_promoController.text);
                          },
                          child: const Text('Pakai'),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Fare breakdown ──
                  if (breakdown != null) ...[
                    const Text(
                      'Rincian Harga',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FareRow(label: 'Tarif dasar', amount: breakdown['base_fare'] as int),
                    _FareRow(label: 'Tarif jarak', amount: breakdown['distance_fare'] as int),
                    _FareRow(label: 'Tarif waktu', amount: breakdown['time_fare'] as int),
                    _FareRow(label: 'Biaya platform', amount: breakdown['platform_fee'] as int),
                    if ((breakdown['promo_discount'] as int) > 0)
                      _FareRow(
                        label: 'Diskon promo',
                        amount: -(breakdown['promo_discount'] as int),
                        isDiscount: true,
                      ),
                    const Divider(height: 20),
                    _FareRow(
                      label: 'Total',
                      amount: breakdown['total'] as int,
                      isBold: true,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Bottom confirm button ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClayButton(
              label: 'Pesan $serviceName',
              isLoading: state.isLoading,
              onPressed: state.isLoading ? null : _onConfirmOrder,
            ),
          ),
        ],
      ),
    );
  }

  void _onConfirmOrder() {
    ref.read(rideStateProvider.notifier).confirmOrder();

    // Listen for order creation → navigate to searching
    ref.listenManual(rideStateProvider, (_, state) {
      if (state.orderStatus == 'finding_driver' && !state.isLoading) {
        context.go('/ride/searching');
      }
    });
  }
}

// ── Payment Option Widget ─────────────────────────────────────────────────

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ClayColors.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ClayColors.primary : ClayColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isSelected ? ClayColors.primary : ClayColors.textSecondary),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? ClayColors.primaryDark : ClayColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: ClayColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Fare Row Widget ───────────────────────────────────────────────────────

class _FareRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool isBold;
  final bool isDiscount;

  const _FareRow({
    required this.label,
    required this.amount,
    this.isBold = false,
    this.isDiscount = false,
  });

  String _formatCurrency(int amount) {
    final str = amount.abs().toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? ClayColors.green : ClayColors.textPrimary,
            ),
          ),
          Text(
            '${isDiscount ? "-" : ""}Rp${_formatCurrency(amount.abs())}',
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? ClayColors.green : ClayColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

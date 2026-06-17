import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/ride_provider.dart';

class RideCompleteScreen extends ConsumerWidget {
  const RideCompleteScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rideStateProvider);
    final driver = state.driverInfo;
    final breakdown = state.fareBreakdown;
    final service = state.selectedService;
    final fare = service?['fare_estimate'] as int? ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ── Success animation ──
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: ClayColors.green.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: ClayColors.green,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Perjalanan Selesai!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Terima kasih telah menggunakan Clay',
                      style: TextStyle(
                        fontSize: 14,
                        color: ClayColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Total fare highlight ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ClayColors.primary,
                            ClayColors.primaryDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ClayColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total Biaya',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp${_formatCurrency(breakdown?['total'] as int? ?? fare)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  state.paymentMethod == 'cash'
                                      ? Icons.payments_outlined
                                      : Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  state.paymentMethod == 'cash' ? 'Cash' : 'ClayWallet',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Route summary ──
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
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _InfoChip(icon: Icons.route, label: '${state.distanceKm} km'),
                              const SizedBox(width: 12),
                              _InfoChip(icon: Icons.schedule, label: '${state.durationMin} menit'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Driver info ──
                    if (driver != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ClayColors.divider),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: ClayColors.primary.withValues(alpha: 0.15),
                              child: const Icon(Icons.person, color: ClayColors.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver['name'] as String? ?? 'Driver',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                  Text(
                                    '${driver['vehicle'] ?? ''} • ${driver['plate'] ?? ''}',
                                    style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ClayColors.warning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: ClayColors.warningDark, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${driver['rating'] ?? '4.8'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: ClayColors.warningDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── Fare breakdown ──
                    if (breakdown != null) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Rincian Biaya',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _FareRow(label: 'Tarif dasar', amount: breakdown['base_fare'] as int? ?? 0),
                      _FareRow(label: 'Tarif jarak', amount: breakdown['distance_fare'] as int? ?? 0),
                      _FareRow(label: 'Tarif waktu', amount: breakdown['time_fare'] as int? ?? 0),
                      _FareRow(label: 'Biaya platform', amount: breakdown['platform_fee'] as int? ?? 0),
                      if ((breakdown['promo_discount'] as int? ?? 0) > 0)
                        _FareRow(
                          label: 'Diskon promo',
                          amount: -(breakdown['promo_discount'] as int),
                          isDiscount: true,
                        ),
                      const Divider(height: 20),
                      _FareRow(
                        label: 'Total',
                        amount: breakdown['total'] as int? ?? fare,
                        isBold: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ──
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
              child: Column(
                children: [
                  ClayButton(
                    label: 'Beri Rating',
                    onPressed: () => context.go('/ride/rating'),
                  ),
                  const SizedBox(height: 8),
                  ClayButton(
                    label: 'Kembali ke Beranda',
                    outlined: true,
                    onPressed: () {
                      ref.read(rideStateProvider.notifier).resetRide();
                      context.go('/home');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ClayColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ClayColors.textSecondary,
            ),
          ),
        ],
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

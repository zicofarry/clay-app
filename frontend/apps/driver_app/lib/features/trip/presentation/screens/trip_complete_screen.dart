import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../../../shared/widgets.dart';
import '../../../order/presentation/providers/order_provider.dart';

class TripCompleteScreen extends ConsumerStatefulWidget {
  const TripCompleteScreen({super.key});

  @override
  ConsumerState<TripCompleteScreen> createState() => _TripCompleteScreenState();
}

class _TripCompleteScreenState extends ConsumerState<TripCompleteScreen> {
  int _rating = 5;

  Future<void> _submitRating() async {
    final order = ref.read(orderProvider).lastCompletedOrder;
    if (order == null) {
      context.go('/home');
      return;
    }
    final orderId = order['id']?.toString();
    if (orderId == null) {
      context.go('/home');
      return;
    }
    try {
      await ClayApi.instance.dio.post('/ride/orders/$orderId/rate', data: {
        'score': _rating,
      });
    } catch (_) {}
    ref.read(orderProvider.notifier).clearLastCompleted();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderProvider).lastCompletedOrder ?? {};

    final fare = order['fare_final'] ?? order['fare_estimate'] ?? 0;
    final paymentMethod = order['payment_method']?.toString() ?? 'cash';
    final paymentLabel = paymentMethod == 'gopay' ? 'GoPay' : 'Tunai';
    final tripDetails = order['trip_details'] as Map<String, dynamic>?;
    final actualDistance = tripDetails?['actual_distance_km']?.toString() ?? tripDetails?['est_distance_km']?.toString() ?? '-';
    final actualDuration = tripDetails?['actual_duration_min']?.toString() ?? tripDetails?['est_duration_min']?.toString() ?? '-';

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [ClayColors.green, ClayColors.greenDark]),
            ),
            child: Column(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, size: 32, color: ClayColors.green),
                ),
                const SizedBox(height: 16),
                const Text('Trip Selesai!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Terima kasih telah mengantar dengan aman', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: ClayColors.background,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: softShadow(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Penghasilan Trip Ini', style: TextStyle(fontSize: 13, color: ClayColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Rp $fare', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                        const Divider(height: 24),
                        _EarningRow(icon: Icons.navigation, label: 'Jarak', value: '$actualDistance km'),
                        const Divider(height: 1),
                        _EarningRow(icon: Icons.access_time, label: 'Durasi', value: '$actualDuration menit'),
                        const Divider(height: 1),
                        _EarningRow(icon: Icons.monetization_on, label: 'Pembayaran', value: paymentLabel),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: softShadow(),
                    child: Column(
                      children: [
                        const Text('Beri Rating Penumpang', style: TextStyle(fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final star = i + 1;
                            return GestureDetector(
                              onTap: () => setState(() => _rating = star),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  star <= _rating ? Icons.star : Icons.star_border,
                                  size: 36,
                                  color: star <= _rating ? ClayColors.warning : ClayColors.divider,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: _submitRating,
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(color: ClayColors.primary, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 6))]),
                      child: const Center(child: Text('Kirim Rating', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      ref.read(orderProvider.notifier).clearLastCompleted();
                      context.go('/home');
                    },
                    child: Container(
                      width: double.infinity, height: 44,
                      decoration: BoxDecoration(color: ClayColors.card, borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: Text('Lewati', style: TextStyle(fontWeight: FontWeight.w500, color: ClayColors.textSecondary))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _EarningRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Icon(icon, size: 16, color: ClayColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: ClayColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textPrimary)),
      ]),
    );
  }
}

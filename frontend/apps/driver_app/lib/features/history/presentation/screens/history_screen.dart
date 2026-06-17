import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets.dart';
import '../../../earning/presentation/providers/earning_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(tripHistoryProvider);
    final trips = historyAsync.valueOrNull ?? [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(onTap: () { if (Navigator.canPop(context)) { context.pop(); } else { context.go('/home'); } }, child: Container(width: 40, height: 40, decoration: softShadow(), child: const Center(child: Icon(Icons.arrow_back, size: 20, color: ClayColors.textPrimary)))),
                  const SizedBox(width: 12),
                  const Text('Riwayat Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: historyAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : trips.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 48, color: ClayColors.textSecondary),
                              SizedBox(height: 12),
                              Text('Belum ada riwayat trip', style: TextStyle(color: ClayColors.textSecondary, fontSize: 14)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: trips.length,
                          itemBuilder: (context, index) {
                            final t = trips[index];
                            final originAddress = t['origin_address']?.toString() ?? '-';
                            final destAddress = t['dest_address']?.toString() ?? '-';
                            final fareTotal = t['fare_total'] ?? 0;
                            final ratingScore = t['rating_score'];
                            final serviceType = t['service_type']?.toString() ?? t['order_type']?.toString() ?? 'ride';
                            final paymentMethod = t['payment_method']?.toString() ?? 'cash';
                            final completedAt = t['completed_at']?.toString() ?? '-';
                            final paymentLabel = paymentMethod == 'gopay' ? 'GoPay' : 'Tunai';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: softShadow(),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(width: 32, height: 32, decoration: BoxDecoration(color: ClayColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.directions_car, size: 16, color: ClayColors.primary)),
                                      const SizedBox(width: 8),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(serviceType.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                                        Text(completedAt, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                                      ])),
                                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                        Text('+Rp $fareTotal', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ClayColors.green)),
                                        if (ratingScore != null)
                                          Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) => Icon(Icons.star, size: 10, color: i < (ratingScore as int) ? ClayColors.warning : ClayColors.divider))),
                                      ]),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(children: [
                                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: ClayColors.green, shape: BoxShape.circle)),
                                        Container(width: 1, height: 20, color: ClayColors.divider),
                                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: ClayColors.accent, shape: BoxShape.circle)),
                                      ]),
                                      const SizedBox(width: 8),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(originAddress, style: const TextStyle(fontSize: 11, color: ClayColors.textPrimary)),
                                        const SizedBox(height: 10),
                                        Text(destAddress, style: const TextStyle(fontSize: 11, color: ClayColors.textPrimary)),
                                      ])),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    children: [
                                      _DetailChip(icon: Icons.monetization_on, text: paymentLabel),
                                      const Spacer(),
                                      const Icon(Icons.chevron_right, size: 16, color: ClayColors.textSecondary),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DriverBottomNav(current: '/history'),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: ClayColors.textSecondary),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 10, color: ClayColors.textSecondary)),
    ]);
  }
}

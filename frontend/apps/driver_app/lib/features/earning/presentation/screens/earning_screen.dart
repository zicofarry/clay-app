import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets.dart';
import '../providers/earning_provider.dart';

class EarningScreen extends ConsumerWidget {
  const EarningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayEarningAsync = ref.watch(todayEarningProvider);
    final earningHistoryAsync = ref.watch(earningHistoryProvider);

    final todayEarning = todayEarningAsync.valueOrNull ?? {'total': 0, 'trips': 0, 'avg_fare': 0};
    final totalEarning = todayEarning['total'] ?? 0;
    final trips = todayEarning['trips'] ?? 0;
    final avgFare = todayEarning['avg_fare'] ?? 0;

    final historyList = earningHistoryAsync.valueOrNull ?? [];

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
                  const Text('Pendapatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(colors: [ClayColors.primary, ClayColors.primaryLight, ClayColors.primary]),
                      boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Pendapatan Hari Ini', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                        const SizedBox(height: 4),
                        Text('Rp $totalEarning', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _EarningMiniStat(icon: Icons.directions_car, label: 'Trip', value: '$trips'),
                            const SizedBox(width: 12),
                            _EarningMiniStat(icon: Icons.trending_up, label: 'Rata-rata', value: 'Rp $avgFare'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pencairan dana diproses. Akan masuk ke rekening dalam 1x24 jam.'), duration: Duration(seconds: 2))),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: softShadow(),
                      child: const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, size: 20, color: ClayColors.green),
                          SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cairkan Dana', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                              Text('Tarik saldo ke rekening bank', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                            ],
                          )),
                          Icon(Icons.chevron_right, color: ClayColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const SectionHeader(title: 'Riwayat Pendapatan'),
                  const SizedBox(height: 8),
                  if (historyList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('Tidak ada riwayat pendapatan', style: TextStyle(color: ClayColors.textSecondary, fontSize: 13)),
                      ),
                    )
                  else
                    ...historyList.map((t) {
                      final title = t['description']?.toString() ?? t['type']?.toString() ?? 'Pendapatan';
                      final date = t['date']?.toString() ?? t['created_at']?.toString() ?? '-';
                      final amount = (t['amount'] ?? t['total'] ?? 0) as int;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: softShadow(),
                        child: Row(
                          children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.directions_car, size: 16, color: ClayColors.primary)),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(date, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                            ])),
                            Text('+Rp $amount', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ClayColors.green)),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DriverBottomNav(current: '/earnings'),
    );
  }
}

class _EarningMiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _EarningMiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
            ]),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

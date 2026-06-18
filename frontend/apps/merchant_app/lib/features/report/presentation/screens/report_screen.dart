import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/report_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reportProvider.notifier).loadReportData();
    });
  }

  String _formatCurrency(num value) {
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}jt';
    } else {
      final valueStr = value.toStringAsFixed(0);
      final buffer = StringBuffer();
      int count = 0;
      for (int i = valueStr.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(valueStr[i]);
        count++;
      }
      return 'Rp ${buffer.toString().split('').reversed.join('')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reportProvider.notifier).loadReportData(),
        child: reportState.isLoading && reportState.totalSales == 0
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (reportState.error != null)
                    Card(
                      color: Colors.red.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          reportState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  Row(children: [
                    Expanded(
                      child: _StatCard(
                        'Hari Ini',
                        _formatCurrency(reportState.todaySales),
                        Icons.today,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        'Minggu Ini',
                        _formatCurrency(reportState.weekSales),
                        Icons.weekend,
                        Colors.green,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _StatCard(
                        'Bulan Ini',
                        _formatCurrency(reportState.monthSales),
                        Icons.date_range,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        'Total',
                        _formatCurrency(reportState.totalSales),
                        Icons.account_balance,
                        Colors.purple,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  const Text('Pesanan Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(children: [
                      ListTile(
                        title: const Text('Total Pesanan'),
                        trailing: Text(
                          '${reportState.totalOrdersToday}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Selesai'),
                        trailing: Text(
                          '${reportState.completedOrdersToday}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Dibatalkan'),
                        trailing: Text(
                          '${reportState.cancelledOrdersToday}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Rata-rata Pesanan'),
                        trailing: Text(
                          _formatCurrency(reportState.avgOrderValueToday),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  const Text('Menu Terlaris', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (reportState.topSellingItems.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Belum ada menu terjual',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(reportState.topSellingItems.length, (i) {
                      final item = reportState.topSellingItems[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: ClayColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(color: ClayColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(item['name'] ?? ''),
                          trailing: Text(
                            '${item['count']}x',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }),
                ],
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 20),
            const Spacer(),
          ]),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ]),
      ),
    );
  }
}

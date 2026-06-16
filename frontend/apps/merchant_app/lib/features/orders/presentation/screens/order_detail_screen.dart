import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(merchantOrderProvider);
    final notifier = ref.read(merchantOrderProvider.notifier);
    final order = state.orders.firstWhere((o) => o['id'] == orderId, orElse: () => {});

    if (order.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Detail Pesanan')), body: const Center(child: Text('Pesanan tidak ditemukan')));
    }

    final statusColors = <String, Color>{
      'pending': Colors.orange,
      'processing': Colors.blue,
      'ready': Colors.green,
      'completed': Colors.grey,
      'cancelled': Colors.red,
    };

    return Scaffold(
      appBar: AppBar(title: Text(order['id'])),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (statusColors[order['status']] ?? Colors.grey).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(order['status'] ?? '', style: TextStyle(color: statusColors[order['status']] ?? Colors.grey, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Text(order['date'] ?? '', style: const TextStyle(color: Colors.grey)),
                  ]),
                  const Divider(height: 24),
                  _InfoRow(Icons.person, 'Pelanggan', order['customer'] ?? ''),
                  const SizedBox(height: 8),
                  _InfoRow(Icons.receipt_long, 'Pesanan', order['items'] ?? ''),
                  const SizedBox(height: 8),
                  _InfoRow(Icons.attach_money, 'Total', 'Rp ${order['total'] ?? 0}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (order['status'] == 'pending') ...[
            ClayButton(label: 'Terima Pesanan', onPressed: () {
              notifier.updateStatus(order['id'], 'processing');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan diterima')));
            }),
            const SizedBox(height: 12),
            ClayButton(label: 'Tolak', backgroundColor: ClayColors.error, onPressed: () {
              notifier.updateStatus(order['id'], 'cancelled');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan ditolak')));
            }),
          ] else if (order['status'] == 'processing') ...[
            ClayButton(label: 'Siapkan Pesanan', onPressed: () {
              notifier.updateStatus(order['id'], 'ready');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan siap')));

            }),
          ] else if (order['status'] == 'ready') ...[
            ClayButton(label: 'Selesaikan Pesanan', onPressed: () {
              notifier.updateStatus(order['id'], 'completed');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan selesai')));
            }),
          ],
          if (order['status'] != 'completed' && order['status'] != 'cancelled') ...[
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.go('/orders'), child: const Text('Kembali')),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: Colors.grey),
      const SizedBox(width: 12),
      SizedBox(width: 80, child: Text('$label:', style: const TextStyle(color: Colors.grey))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
    ]);
  }
}

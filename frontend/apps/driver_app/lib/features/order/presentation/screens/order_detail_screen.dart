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
    final state = ref.watch(orderProvider);
    final notifier = ref.read(orderProvider.notifier);
    final order = state.activeOrder ?? state.incoming.firstWhere((o) => o['id'] == orderId, orElse: () => {});

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(order['type'] == 'GoFood' ? Icons.restaurant : Icons.directions_car, color: ClayColors.primary),
                      const SizedBox(width: 8),
                      Text(order['type'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ]),
                    const Divider(height: 24),
                    _InfoRow(Icons.person, 'Customer', order['user'] ?? ''),
                    _InfoRow(Icons.location_on, 'Jemput', order['pickup'] ?? ''),
                    _InfoRow(Icons.flag, 'Tujuan', order['dest'] ?? ''),
                    _InfoRow(Icons.attach_money, 'Tarif', 'Rp ${order['price'] ?? 0}'),
                    _InfoRow(Icons.timer, 'Jarak', order['distance'] ?? ''),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (state.activeOrder != null) ...[
              ClayButton(label: 'Update Status', onPressed: () {
                notifier.updateStatus('arrived');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status diupdate')));
              }),
              const SizedBox(height: 12),
              ClayButton(label: 'Selesaikan', backgroundColor: Colors.green, onPressed: () {
                notifier.completeOrder();
                context.go('/home');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan selesai')));
              }),
            ] else ...[
              ClayButton(label: 'Terima', onPressed: () {
                notifier.acceptOrder(orderId);
                context.go('/home');
              }),
              const SizedBox(height: 12),
              ClayButton(label: 'Tolak', backgroundColor: ClayColors.error, onPressed: () {
                notifier.rejectOrder(orderId);
                context.go('/home');
              }),
            ],
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(color: Colors.grey)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

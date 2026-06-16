import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/order_provider.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(merchantOrderProvider.notifier).loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantOrderProvider);
    final statusColors = <String, Color>{
      'pending': Colors.orange,
      'processing': Colors.blue,
      'ready': Colors.green,
      'completed': Colors.grey,
      'cancelled': Colors.red,
    };

    final filtered = state.orders.where((o) => _filter == 'all' || o['status'] == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              _FilterChip('all', 'Semua', _filter == 'all', () => setState(() => _filter = 'all')),
              const SizedBox(width: 8),
              _FilterChip('pending', 'Menunggu', _filter == 'pending', () => setState(() => _filter = 'pending')),
              const SizedBox(width: 8),
              _FilterChip('processing', 'Diproses', _filter == 'processing', () => setState(() => _filter = 'processing')),
              const SizedBox(width: 8),
              _FilterChip('ready', 'Siap', _filter == 'ready', () => setState(() => _filter = 'ready')),
              const SizedBox(width: 8),
              _FilterChip('completed', 'Selesai', _filter == 'completed', () => setState(() => _filter = 'completed')),
            ]),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('Tidak ada pesanan'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final o = filtered[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (statusColors[o['status']] ?? Colors.grey).withValues(alpha: 0.1),
                                child: Icon(Icons.receipt, color: statusColors[o['status']] ?? Colors.grey),
                              ),
                              title: Text(o['id']),
                              subtitle: Text('${o['customer']} • Rp ${o['total']}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (statusColors[o['status']] ?? Colors.grey).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(o['status'], style: TextStyle(color: statusColors[o['status']] ?? Colors.grey, fontSize: 12)),
                              ),
                              onTap: () => context.push('/order/${o['id']}'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, text;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(this.label, this.text, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ClayColors.primary : ClayColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : ClayColors.divider),
        ),
        child: Text(text, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 13)),
      ),
    );
  }
}

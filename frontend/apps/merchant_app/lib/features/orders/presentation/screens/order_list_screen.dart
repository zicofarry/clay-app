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

class _OrderListScreenState extends ConsumerState<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() => ref.read(merchantOrderProvider.notifier).loadOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showConfirmDialog(String orderId) {
    int estTime = 15;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Terima Pesanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tentukan estimasi waktu persiapan makanan:'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 28),
                    onPressed: estTime > 5 ? () => setDialogState(() => estTime -= 5) : null,
                  ),
                  Text('$estTime menit', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 28),
                    onPressed: estTime < 120 ? () => setDialogState(() => estTime += 5) : null,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                ref.read(merchantOrderProvider.notifier).confirmOrder(orderId, estTime);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pesanan berhasil diterima')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: ClayColors.primary),
              child: const Text('Terima', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(String orderId) {
    final reasonC = TextEditingController(text: 'Habis stok');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alasan penolakan:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonC,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Contoh: Habis stok, Toko tutup lebih awal',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              ref.read(merchantOrderProvider.notifier).rejectOrder(orderId, reasonC.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pesanan ditolak')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: ClayColors.error),
            child: const Text('Tolak Pesanan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantOrderProvider);

    // Filter categories
    final newOrders = state.orders.where((o) => o['status'] == 'pending').toList();
    final preparingOrders = state.orders.where((o) => o['status'] == 'confirmed' || o['status'] == 'preparing').toList();
    final activeDeliveryOrders = state.orders.where((o) => o['status'] == 'ready' || o['status'] == 'picked_up' || o['status'] == 'on_delivery').toList();
    final historicalOrders = state.orders.where((o) => o['status'] == 'delivered' || o['status'] == 'cancelled').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Board', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ClayColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: ClayColors.primary,
          isScrollable: false,
          tabs: [
            Tab(text: 'Baru (${newOrders.length})'),
            Tab(text: 'Proses (${preparingOrders.length})'),
            Tab(text: 'Kirim (${activeDeliveryOrders.length})'),
            Tab(text: 'Riwayat (${historicalOrders.length})'),
          ],
        ),
      ),
      body: SafeArea(
        child: state.isLoading && state.orders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => ref.read(merchantOrderProvider.notifier).loadOrders(),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OrderColumn(
                      orders: newOrders,
                      emptyMessage: 'Belum ada pesanan baru masuk',
                      buildActions: (o) => Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showRejectDialog(o['id']),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ClayColors.error,
                                side: BorderSide(color: ClayColors.error),
                              ),
                              child: const Text('Tolak'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _showConfirmDialog(o['id']),
                              style: ElevatedButton.styleFrom(backgroundColor: ClayColors.primary),
                              child: const Text('Terima', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _OrderColumn(
                      orders: preparingOrders,
                      emptyMessage: 'Tidak ada pesanan sedang diproses',
                      buildActions: (o) {
                        final isConfirmed = o['status'] == 'confirmed';
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final action = isConfirmed ? 'start_preparing' : 'mark_ready';
                              ref.read(merchantOrderProvider.notifier).updatePrepStatus(o['id'], action);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(isConfirmed ? 'Memulai menyiapkan pesanan' : 'Pesanan ditandai siap disajikan')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isConfirmed ? Colors.blue : Colors.green,
                            ),
                            child: Text(
                              isConfirmed ? 'Mulai Siapkan' : 'Siap Saji',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                    _OrderColumn(
                      orders: activeDeliveryOrders,
                      emptyMessage: 'Tidak ada pesanan dalam pengiriman',
                      buildActions: (o) {
                        final status = o['status'];
                        String statusLabel = 'Menunggu Driver';
                        IconData icon = Icons.hourglass_empty;
                        Color col = Colors.orange;

                        if (status == 'picked_up' || status == 'on_delivery') {
                          statusLabel = 'Sedang Dikirim oleh Driver';
                          icon = Icons.motorcycle;
                          col = Colors.blue;
                        }

                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: col.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, color: col, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                statusLabel,
                                style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    _OrderColumn(
                      orders: historicalOrders,
                      emptyMessage: 'Belum ada riwayat pesanan selesai',
                      isHistory: true,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _OrderColumn extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final String emptyMessage;
  final Widget Function(Map<String, dynamic>)? buildActions;
  final bool isHistory;

  const _OrderColumn({
    required this.orders,
    required this.emptyMessage,
    this.buildActions,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(emptyMessage, style: const TextStyle(color: Colors.grey, fontSize: 15)),
              ],
            ),
          ),
        ],
      );
    }

    final statusColors = <String, Color>{
      'pending': Colors.orange,
      'confirmed': Colors.blue,
      'preparing': Colors.indigo,
      'ready': Colors.teal,
      'picked_up': Colors.blueAccent,
      'on_delivery': Colors.blueAccent,
      'delivered': Colors.green,
      'cancelled': Colors.red,
    };

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final o = orders[index];
        final orderIdShort = o['id']?.toString().substring(0, 8).toUpperCase() ?? '';
        final status = o['status'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => context.push('/order/${o['id']}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#$orderIdShort',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (statusColors[status] ?? Colors.grey).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.toString().toUpperCase(),
                          style: TextStyle(
                            color: statusColors[status] ?? Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          o['customer'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ),
                      Text(
                        'Rp ${o['total']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: ClayColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          o['items'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  if (o['notes'] != null && o['notes'].toString().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Catatan: "${o['notes']}"',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.orange),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        o['date'] ?? '',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const Spacer(),
                      if (isHistory && o['cancelled_by'] != null) ...[
                        Text(
                          'Ditolak oleh: ${o['cancelled_by']}',
                          style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                  if (buildActions != null) ...[
                    const Divider(height: 24),
                    buildActions!(o),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

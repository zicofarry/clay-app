import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        await ref.read(merchantOrderProvider.notifier).loadOrderDetail(widget.orderId);
      } catch (_) {
        // Handle error silently
      }
    });
  }

  void _showConfirmDialog() {
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
                ref.read(merchantOrderProvider.notifier).confirmOrder(widget.orderId, estTime);
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

  void _showRejectDialog() {
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
              ref.read(merchantOrderProvider.notifier).rejectOrder(widget.orderId, reasonC.text.trim());
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
    final order = state.orders.firstWhere((o) => o['id'] == widget.orderId, orElse: () => {});

    if (order.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : const Center(child: Text('Pesanan tidak ditemukan')),
      );
    }

    final status = order['status'] ?? 'pending';
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

    return Scaffold(
      appBar: AppBar(title: Text('Pesanan #${widget.orderId.substring(0, 8).toUpperCase()}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (statusColors[status] ?? Colors.grey).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toString().toUpperCase(),
                            style: TextStyle(
                              color: statusColors[status] ?? Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(order['date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                    const Divider(height: 24),
                    _InfoRow(Icons.person_outline, 'Pelanggan', order['customer'] ?? ''),
                    const SizedBox(height: 12),
                    _InfoRow(Icons.receipt_long_outlined, 'Pesanan', order['items'] ?? ''),
                    const SizedBox(height: 12),
                    _InfoRow(Icons.location_on_outlined, 'Alamat', order['address'] ?? ''),
                    const SizedBox(height: 12),
                    _InfoRow(Icons.payment_outlined, 'Pembayaran', (order['payment_method'] ?? 'cash').toString().toUpperCase()),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Biaya Makanan:', style: TextStyle(color: Colors.grey)),
                        Text('Rp ${order['subtotal'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Biaya Pengiriman:', style: TextStyle(color: Colors.grey)),
                        Text('Rp ${order['delivery_fee'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pendapatan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          'Rp ${order['total'] ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: ClayColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (order['notes'] != null && order['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.amber.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Catatan dari Pelanggan:\n"${order['notes']}"',
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.orange, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (status == 'pending') ...[
              ClayButton(label: 'Terima Pesanan', onPressed: _showConfirmDialog),
              const SizedBox(height: 12),
              ClayButton(
                label: 'Tolak Pesanan',
                backgroundColor: ClayColors.error,
                onPressed: _showRejectDialog,
              ),
            ] else if (status == 'confirmed') ...[
              ClayButton(
                label: 'Mulai Siapkan Pesanan',
                onPressed: () {
                  ref.read(merchantOrderProvider.notifier).updatePrepStatus(widget.orderId, 'start_preparing');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Memulai menyiapkan pesanan')),
                  );
                },
              ),
            ] else if (status == 'preparing') ...[
              ClayButton(
                label: 'Tandai Siap Saji',
                backgroundColor: Colors.green,
                onPressed: () {
                  ref.read(merchantOrderProvider.notifier).updatePrepStatus(widget.orderId, 'mark_ready');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pesanan ditandai siap disajikan')),
                  );
                },
              ),
            ] else if (status == 'ready' || status == 'picked_up' || status == 'on_delivery') ...[
              Card(
                elevation: 0,
                color: Colors.blue.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        status == 'ready' ? Icons.hourglass_empty : Icons.motorcycle,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          status == 'ready'
                              ? 'Menunggu kurir mengambil makanan...'
                              : 'Makanan sedang diantarkan oleh kurir...',
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (status == 'delivered') ...[
              Card(
                elevation: 0,
                color: Colors.green.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green),
                      SizedBox(width: 12),
                      Text(
                        'Pesanan telah selesai diantarkan!',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (status == 'cancelled') ...[
              Card(
                elevation: 0,
                color: Colors.red.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_outlined, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pesanan dibatalkan / ditolak.\nAlasan: "${order['cancel_reason'] ?? 'Tidak ada alasan specified'}"',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Kembali ke Order Board'),
            ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        SizedBox(width: 90, child: Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 13))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

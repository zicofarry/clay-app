import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../food/presentation/providers/food_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(foodStateProvider.notifier).loadActiveOrder();
      ref.read(foodStateProvider.notifier).loadHistory();
      ref.read(walletStateProvider.notifier).loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodStateProvider);
    final notifier = ref.read(foodStateProvider.notifier);

    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            color: ClayColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ClayColors.primary,
          unselectedLabelColor: ClayColors.textSecondary,
          indicatorColor: ClayColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Dalam Proses'),
            Tab(text: 'Riwayat'),
            Tab(text: 'Transaksi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Orders Tab
          _buildActiveOrdersTab(state, notifier),

          // History Tab
          _buildHistoryTab(state, notifier),

          // Wallet Transactions Tab
          _buildTransactionsTab(),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersTab(FoodState state, FoodNotifier notifier) {
    if (state.activeOrder == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: ClayColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada pesanan aktif',
              style: TextStyle(
                color: ClayColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ClayButton(
                label: 'Pesan Sekarang',
                onPressed: () => context.go('/food'),
              ),
            ),
          ],
        ),
      );
    }

    final order = state.activeOrder!;
    final orderId = order['order_id'] ?? '';
    final status = order['status'] ?? 'pending';
    final total = order['total'] ?? 0;
    final address = order['address'] ?? '';

    // Map status to visual styles
    Color statusColor = ClayColors.warningDark;
    String statusTitle = 'Menunggu Konfirmasi';
    double progress = 0.25;

    if (status == 'confirmed') {
      statusColor = ClayColors.primary;
      statusTitle = 'Pesanan Dikonfirmasi';
      progress = 0.5;
    } else if (status == 'preparing') {
      statusColor = ClayColors.purple;
      statusTitle = 'Sedang Disiapkan';
      progress = 0.75;
    } else if (status == 'ready' || status == 'picked_up' || status == 'on_delivery') {
      statusColor = ClayColors.green;
      statusTitle = 'Dalam Pengiriman';
      progress = 0.9;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant, color: ClayColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'ClayFood Order',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ClayColors.textPrimary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusTitle,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: ClayColors.divider),
            const SizedBox(height: 12),

            // Order ID & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ID PESANAN', style: TextStyle(color: ClayColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TOTAL HARGA', style: TextStyle(color: ClayColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Rp $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ClayColors.primary)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: ClayColors.divider,
                    color: statusColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dipesan', style: TextStyle(fontSize: 10, color: ClayColors.textSecondary, fontWeight: FontWeight.bold)),
                    Text('Disiapkan', style: TextStyle(fontSize: 10, color: ClayColors.textSecondary, fontWeight: FontWeight.bold)),
                    Text('Dikirim', style: TextStyle(fontSize: 10, color: ClayColors.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Delivery Destination Address
            const Text(
              'TUJUAN PENGIRIMAN',
              style: TextStyle(color: ClayColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: ClayColors.accent, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(fontSize: 13, color: ClayColors.textPrimary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Refresh Status Button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ClayColors.primary,
                      side: const BorderSide(color: ClayColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => notifier.loadActiveOrder(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(FoodState state, FoodNotifier notifier) {
    if (state.history.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat pesanan',
          style: TextStyle(color: ClayColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadHistory(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.history.length,
        itemBuilder: (context, i) {
          final o = state.history[i];
          final String orderId = o['order_id'] ?? '';
          final String date = o['date'] ?? '';
          final String merchant = o['merchant'] ?? 'ClayFood Resto';
          final int total = o['total'] ?? 0;
          final String status = o['status'] ?? 'completed';

          final isCancelled = status == 'cancelled' || status == 'rejected';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ClayColors.divider),
            ),
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ClayColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant, color: ClayColors.primary, size: 22),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GoFood',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ClayColors.primary),
                  ),
                  Text(
                    date.length > 10 ? date.substring(0, 10) : date,
                    style: const TextStyle(color: ClayColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    merchant,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp $total',
                    style: const TextStyle(
                      color: ClayColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? ClayColors.error.withValues(alpha: 0.1)
                      : ClayColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCancelled ? 'Batal' : 'Selesai',
                  style: TextStyle(
                    color: isCancelled ? ClayColors.error : ClayColors.greenDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              onTap: () => _showOrderDetailDialog(context, orderId, merchant, total, status, date),
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final walletState = ref.watch(walletStateProvider);

    if (walletState.transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Belum ada transaksi',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(walletStateProvider.notifier).loadTransactions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: walletState.transactions.length,
        itemBuilder: (context, i) {
          final t = walletState.transactions[i];
          final amount = (t['amount'] as num?)?.toInt() ?? 0;
          final isCredit = amount > 0;
          final desc = t['description']?.toString() ?? 'Transaksi';
          final date = t['created_at']?.toString() ?? '';
          final type = t['type']?.toString() ?? '';
          String displayDate = date;
          try {
            final dt = DateTime.parse(date);
            displayDate = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          } catch (_) {}

          IconData iconData;
          Color iconColor;
          if (type == 'top_up') {
            iconData = Icons.add_circle_outline;
            iconColor = Colors.green;
          } else if (type == 'transfer') {
            iconData = Icons.swap_horiz;
            iconColor = Colors.blue;
          } else {
            iconData = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
            iconColor = isCredit ? Colors.green : Colors.red;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ClayColors.divider),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: iconColor.withValues(alpha: 0.1),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              title: Text(desc, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(displayDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              trailing: Text(
                '${isCredit ? '+' : ''}Rp ${amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOrderDetailDialog(
    BuildContext context,
    String orderId,
    String merchant,
    int total,
    String status,
    String date,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final isCancelled = status == 'cancelled' || status == 'rejected';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.receipt, color: ClayColors.primary),
              const SizedBox(width: 8),
              const Text('Detail Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('ID Pesanan', orderId),
              _buildDetailItem('Restoran', merchant),
              _buildDetailItem('Tanggal', date.length > 16 ? date.substring(0, 16) : date),
              _buildDetailItem('Total Belanja', 'Rp $total'),
              const Divider(color: ClayColors.divider, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status', style: TextStyle(color: ClayColors.textSecondary, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? ClayColors.error.withValues(alpha: 0.1)
                          : ClayColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCancelled ? 'Dibatalkan' : 'Selesai',
                      style: TextStyle(
                        color: isCancelled ? ClayColors.error : ClayColors.greenDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(color: ClayColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: ClayColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: ClayColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

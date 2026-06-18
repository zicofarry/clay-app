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

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _scaffoldBg => _isDark ? const Color(0xFF121212) : ClayColors.background;
  Color get _surfaceColor => _isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _textPrimary => _isDark ? Colors.white : ClayColors.textPrimary;
  Color get _textSecondary => _isDark ? Colors.white70 : ClayColors.textSecondary;
  Color get _borderColor => _isDark ? Colors.white12 : ClayColors.divider;

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
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Pesanan Saya',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ClayColors.primary,
          unselectedLabelColor: _textSecondary,
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
            Icon(Icons.receipt_long_outlined, size: 80, color: _textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Tidak ada pesanan aktif',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ClayButton(
                label: 'Pesan Sekarang',
                onPressed: () => context.push('/food'),
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
          color: _surfaceColor,
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
                    Text(
                      'ClayFood Order',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textPrimary),
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
            Divider(color: _borderColor),
            const SizedBox(height: 12),

            // Order ID & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID PESANAN', style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(orderId, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TOTAL HARGA', style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
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
                    backgroundColor: _borderColor,
                    color: statusColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dipesan', style: TextStyle(fontSize: 10, color: _textSecondary, fontWeight: FontWeight.bold)),
                    Text('Disiapkan', style: TextStyle(fontSize: 10, color: _textSecondary, fontWeight: FontWeight.bold)),
                    Text('Dikirim', style: TextStyle(fontSize: 10, color: _textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Delivery Destination Address
            Text(
              'TUJUAN PENGIRIMAN',
              style: TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: ClayColors.accent, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(fontSize: 13, color: _textPrimary),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: _textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat pesanan',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan makanan lezatmu akan muncul di sini',
              style: TextStyle(
                color: _textSecondary.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadHistory(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: state.history.length,
        itemBuilder: (context, i) {
          final o = state.history[i];
          final String orderId = o['order_id'] ?? '';
          final String date = o['date'] ?? '';
          final String merchant = o['merchant'] ?? 'ClayFood Resto';
          final String merchantId = o['merchant_id'] ?? '';
          final int total = o['total'] ?? 0;
          final String status = o['status'] ?? 'completed';

          final isCancelled = status == 'cancelled' || status == 'rejected';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => _showOrderDetailBottomSheet(context, orderId, merchant, merchantId, total, status, date),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: ClayColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.restaurant, color: ClayColors.primary, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'ClayFood',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: ClayColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        color: _textSecondary.withValues(alpha: 0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        date.length > 10 ? date.substring(0, 10) : date,
                                        style: TextStyle(
                                          color: _textSecondary,
                                          fontSize: 11,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCancelled
                                  ? ClayColors.error.withValues(alpha: 0.1)
                                  : ClayColors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
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
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: _borderColor, height: 1),
                      const SizedBox(height: 12),

                      // Merchant & Total Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  merchant,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID Pesanan: ${orderId.length > 8 ? orderId.substring(0, 8) : orderId}...',
                                  style: TextStyle(
                                    color: _textSecondary.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Belanja',
                                style: TextStyle(
                                  color: _textSecondary.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rp $total',
                                style: TextStyle(
                                  color: _textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 12),

                      // Quick Action Row
                      Row(
                        children: [
                          if (!isCancelled) ...[
                            OutlinedButton.icon(
                              onPressed: () => _showRatingDialog(context, orderId, merchant),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: ClayColors.primary),
                                foregroundColor: ClayColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              icon: const Icon(Icons.star_border, size: 16),
                              label: const Text(
                                'Beri Ulasan',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              // Show generic loading overlay/snackbar
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Menyiapkan pesanan ulang...'),
                                    ],
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              final success = await notifier.reorder(orderId, merchantId, merchant);
                              if (success) {
                                scaffoldMessenger.clearSnackBars();
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Menu dari $merchant berhasil ditambahkan ke keranjang!'),
                                    backgroundColor: ClayColors.greenDark,
                                    action: SnackBarAction(
                                      label: 'LIHAT',
                                      textColor: Colors.white,
                                      onPressed: () => context.push('/food/cart'),
                                    ),
                                  ),
                                );
                                context.push('/food/cart');
                              } else {
                                scaffoldMessenger.clearSnackBars();
                                // Fallback: navigate to merchant menu
                                notifier.selectMerchant(merchantId, merchant);
                                context.push('/food/menu/$merchantId');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ClayColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.replay_rounded, size: 16),
                            label: const Text(
                              'Pesan Lagi',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

  void _showOrderDetailBottomSheet(
    BuildContext context,
    String orderId,
    String merchant,
    String merchantId,
    int total,
    String status,
    String date,
  ) {
    final isCancelled = status == 'cancelled' || status == 'rejected';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<Map<String, dynamic>?>(
              future: ref.read(foodRepositoryProvider).getOrderDetails(orderId),
              builder: (context, snapshot) {
                final isLoading = snapshot.connectionState == ConnectionState.waiting;
                final orderDetails = snapshot.data;
                final items = orderDetails != null ? (orderDetails['items'] as List?) : null;

                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _borderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Detail Transaksi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCancelled
                                  ? ClayColors.error.withValues(alpha: 0.1)
                                  : ClayColors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isCancelled ? 'Dibatalkan' : 'Selesai',
                              style: TextStyle(
                                color: isCancelled ? ClayColors.error : ClayColors.greenDark,
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

                      // Summary Details
                      _buildDetailItem('ID Pesanan', orderId),
                      _buildDetailItem('Restoran', merchant),
                      _buildDetailItem('Waktu Pemesanan', date),
                      const SizedBox(height: 16),

                      const Text(
                        'Rincian Pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(color: ClayColors.primary),
                          ),
                        )
                      else if (items == null || items.isEmpty)
                        Text(
                          'Detail item tidak tersedia',
                          style: TextStyle(color: _textSecondary, fontSize: 13),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            final String itemName = item['name'] ?? 'Menu Makanan';
                            final int itemQty = item['quantity'] ?? 1;
                            final int itemPrice = item['unit_price_cents'] ?? item['price'] ?? 0;
                            final int subtotal = item['subtotal_cents'] ?? (itemPrice * itemQty);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${itemQty}x $itemName',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Rp $subtotal',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 16),
                      Divider(color: _borderColor),
                      const SizedBox(height: 12),

                      // Billing Breakdown
                      _buildDetailItem(
                        'Subtotal',
                        'Rp ${orderDetails != null ? (orderDetails['subtotal_cents'] ?? total) : total}',
                      ),
                      _buildDetailItem(
                        'Biaya Ongkir',
                        'Rp ${orderDetails != null ? (orderDetails['delivery_fee_cents'] ?? 0) : 0}',
                      ),
                      if (orderDetails != null && (orderDetails['discount_cents'] ?? 0) > 0)
                        _buildDetailItem(
                          'Diskon Promo',
                          '-Rp ${orderDetails['discount_cents']}',
                          valueColor: ClayColors.primary,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: _textPrimary,
                            ),
                          ),
                          Text(
                            'Rp $total',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ClayColors.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Divider(color: _borderColor),
                      const SizedBox(height: 12),

                      // Address Section
                      Text(
                        'Alamat Pengiriman',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: ClayColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              orderDetails != null ? (orderDetails['delivery_address'] ?? 'Alamat terdaftar') : 'Alamat terdaftar',
                              style: TextStyle(
                                color: _textSecondary.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Reorder Action inside BottomSheet
                      SizedBox(
                        width: double.infinity,
                        child: ClayButton(
                          label: 'Pesan Lagi Menu Ini',
                          onPressed: () async {
                            Navigator.pop(context);
                            final notifier = ref.read(foodStateProvider.notifier);
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Menyiapkan pesanan ulang...'),
                                  ],
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            final success = await notifier.reorder(orderId, merchantId, merchant);
                            if (success) {
                              scaffoldMessenger.clearSnackBars();
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('Menu dari $merchant berhasil ditambahkan ke keranjang!'),
                                  backgroundColor: ClayColors.greenDark,
                                  action: SnackBarAction(
                                    label: 'LIHAT',
                                    textColor: Colors.white,
                                    onPressed: () => context.push('/food/cart'),
                                  ),
                                ),
                              );
                              context.push('/food/cart');
                            } else {
                              scaffoldMessenger.clearSnackBars();
                              notifier.selectMerchant(merchantId, merchant);
                              context.push('/food/menu/$merchantId');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, String orderId, String merchant) {
    int driverStars = 5;
    int merchantStars = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Beri Ulasan $merchant',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bagaimana kinerja driver Anda?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return GestureDetector(
                          onTap: () => setDialogState(() => driverStars = starIndex),
                          child: Icon(
                            starIndex <= driverStars ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Bagaimana rasa makanan restoran?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return GestureDetector(
                          onTap: () => setDialogState(() => merchantStars = starIndex),
                          child: Icon(
                            starIndex <= merchantStars ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Komentar Anda (Opsional)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textPrimary),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tulis tanggapan Anda mengenai pelayanan ini...',
                        hintStyle: TextStyle(color: _textSecondary.withValues(alpha: 0.6), fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: ClayColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: TextStyle(color: _textSecondary, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final success = await ref.read(foodStateProvider.notifier).submitRating(
                          orderId: orderId,
                          driverRating: driverStars,
                          merchantRating: merchantStars,
                          comment: commentController.text,
                        );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Ulasan Anda berhasil dikirim! Terima kasih.'
                                : 'Gagal mengirim ulasan.',
                          ),
                          backgroundColor: success ? ClayColors.greenDark : ClayColors.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ClayColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _textSecondary.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? _textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

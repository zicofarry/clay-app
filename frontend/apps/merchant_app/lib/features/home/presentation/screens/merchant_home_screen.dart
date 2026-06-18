import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../auth/presentation/providers/merchant_auth_provider.dart';
import '../../../menu/presentation/screens/menu_list_screen.dart';
import '../../../orders/presentation/screens/order_list_screen.dart';
import '../../../profile/presentation/screens/merchant_profile_screen.dart';
import '../../../profile/presentation/providers/merchant_profile_provider.dart';
import '../../../orders/presentation/providers/order_provider.dart';

final _currentTabProvider = StateProvider<int>((ref) => 0);

class MerchantHomeScreen extends ConsumerStatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  ConsumerState<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends ConsumerState<MerchantHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(merchantOrderProvider.notifier).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(_currentTabProvider);

    final pages = <Widget>[
      const _DashboardTab(),
      const OrderListScreen(),
      const MenuListScreen(),
      const MerchantProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentTab, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ClayColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) => ref.read(_currentTabProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), activeIcon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchant = ref.watch(merchantAuthProvider).merchant;
    final isOpen = merchant?['status'] == 'active';
    final orderState = ref.watch(merchantOrderProvider);
    final orders = orderState.orders;

    // Calculate real stats
    final completedOrders = orders.where((o) => o['status'] == 'delivered').toList();
    final revenue = completedOrders.fold<int>(0, (sum, o) => sum + (o['total'] as int? ?? 0));
    final completedCount = completedOrders.length;
    final activeCount = orders.where((o) => o['status'] != 'delivered' && o['status'] != 'cancelled').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(merchant?['name'] ?? 'Merchant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/report'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(merchantOrderProvider.notifier).loadOrders(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [ClayColors.primary, ClayColors.primaryDark]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selamat datang, ${merchant?['owner'] ?? 'Merchant'}', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(merchant?['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${merchant?['rating'] ?? 4.5}', style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 16),
                      const Icon(Icons.receipt_long, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text('${merchant?['total_orders'] ?? 0} ulasan', style: const TextStyle(color: Colors.white70)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: ClayColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ClayColors.divider),
                ),
                child: Row(children: [
                  Icon(isOpen ? Icons.check_circle : Icons.cancel, color: isOpen ? Colors.green : Colors.red),
                  const SizedBox(width: 12),
                  Text('Toko ${isOpen ? "Buka" : "Tutup"}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Switch(
                    value: isOpen,
                    activeThumbColor: Colors.green,
                    onChanged: (v) {
                      if (merchant != null && merchant['id'] != null) {
                        ref.read(merchantProfileProvider.notifier).updateStatus(merchant['id'], v ? 'active' : 'closed');
                      }
                    },
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              const Text('Statistik Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Omset',
                    value: 'Rp $revenue',
                    icon: Icons.monetization_on,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Selesai',
                    value: '$completedCount',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Aktif',
                    value: '$activeCount',
                    icon: Icons.timer_outlined,
                    color: Colors.blue,
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              // Wallet shortcut card
              GestureDetector(
                onTap: () => context.push('/wallet'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF97C5F5)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dompet Clay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 2),
                            Text('Lihat saldo, top up, transfer & riwayat transaksi', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Pesanan Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              if (orderState.isLoading && orders.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ))
              else if (orders.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Belum ada pesanan masuk', style: TextStyle(color: Colors.grey))),
                  ),
                )
              else
                ...orders.take(5).map((o) {
                  final status = o['status'] ?? '';
                  final isCompleted = status == 'delivered';
                  final isCancelled = status == 'cancelled';
                  String statusText = 'Baru';
                  Color statusCol = Colors.orange;

                  if (isCompleted) {
                    statusText = 'Selesai';
                    statusCol = Colors.green;
                  } else if (isCancelled) {
                    statusText = 'Dibatalkan';
                    statusCol = Colors.red;
                  } else if (status == 'confirmed' || status == 'preparing') {
                    statusText = 'Diproses';
                    statusCol = Colors.blue;
                  } else if (status == 'ready' || status == 'picked_up' || status == 'on_delivery') {
                    statusText = 'Pengiriman';
                    statusCol = Colors.teal;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusCol.withValues(alpha: 0.1),
                        child: Icon(Icons.receipt, color: statusCol),
                      ),
                      title: Text('Pesanan #${o['id']?.toString().substring(0, 8).toUpperCase()}'),
                      subtitle: Text('Rp ${o['total']} • $statusText'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/order/${o['id']}'),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ClayColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ClayColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

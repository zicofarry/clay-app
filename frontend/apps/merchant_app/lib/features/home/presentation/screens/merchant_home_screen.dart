import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../auth/presentation/providers/merchant_auth_provider.dart';
import '../../../menu/presentation/screens/menu_list_screen.dart';
import '../../../orders/presentation/screens/order_list_screen.dart';
import '../../../profile/presentation/screens/merchant_profile_screen.dart';

final _currentTabProvider = StateProvider<int>((ref) => 0);
final _isOpenProvider = StateProvider<bool>((ref) => true);

class MerchantHomeScreen extends ConsumerWidget {
  const MerchantHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final isOpen = ref.watch(_isOpenProvider);

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
        child: ListView(
          padding: const EdgeInsets.all(16),
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
                    Text('${merchant?['rating'] ?? 0}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 16),
                    const Icon(Icons.receipt_long, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text('${merchant?['total_orders'] ?? 0} pesanan', style: const TextStyle(color: Colors.white70)),
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
                Switch(value: isOpen, activeColor: Colors.green, onChanged: (v) => ref.read(_isOpenProvider.notifier).state = v),
              ]),
            ),
            const SizedBox(height: 24),
            const Text('Statistik Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _MetricCard(
                  title: 'Omset',
                  value: 'Rp 450.000',
                  icon: Icons.monetization_on,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Pesanan Selesai',
                  value: '18',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Aktif',
                  value: '6',
                  icon: Icons.timer_outlined,
                  color: Colors.blue,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            const Text('Pesanan Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...List.generate(3, (i) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ClayColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.receipt, color: ClayColors.primary),
                ),
                title: Text('Pesanan #ORD-${100 + i}'),
                subtitle: Text('Rp ${[25000, 45000, 32000][i]} • ${['Menunggu', 'Diproses', 'Selesai'][i]}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/order/ORD-${100 + i}'),
              ),
            )),
          ],
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
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../../../features/profile/presentation/screens/profile_screen.dart';

final _currentTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(_currentTabProvider);

    final pages = <Widget>[
      _DashboardTab(),
      _OrdersTab(),
      _WalletTab(),
      _AccountTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentTab, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ClayColors.primary,
        onTap: (i) => ref.read(_currentTabProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet_outlined), activeIcon: Icon(Icons.wallet), label: 'Dompet'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clay'), actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Halo, Pengguna!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Ada yang bisa kami bantu hari ini?', style: TextStyle(fontSize: 14, color: ClayColors.textSecondary)),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
              ),
              itemCount: _services.length,
              itemBuilder: (_, i) => _ServiceCard(item: _services[i]),
            ),
            const SizedBox(height: 32),
            const Text('Pesanan Aktif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ClayColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ClayColors.divider),
              ),
              child: Column(children: [
                Icon(Icons.inbox_outlined, size: 48, color: ClayColors.textSecondary),
                const SizedBox(height: 12),
                const Text('Tidak ada pesanan aktif', style: TextStyle(color: ClayColors.textSecondary, fontSize: 16)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan')),
      body: const Center(child: Text('Riwayat pesanan')),
    );
  }
}

class _WalletTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const WalletScreen();
  }
}

class _AccountTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ProfileScreen();
  }
}

final _services = [
  _ServiceItem('GoRide', '/ride', Icons.directions_car, ClayColors.primary),
  _ServiceItem('GoCar', '/ride', Icons.directions_car_filled, ClayColors.primaryDark),
  _ServiceItem('GoFood', '/food', Icons.restaurant, Colors.orange),
  _ServiceItem('GoSend', '/ride', Icons.inventory_2, Colors.green),
  _ServiceItem('GoMart', '/food', Icons.store, Colors.purple),
  _ServiceItem('GoBox', '/food', Icons.move_to_inbox, Colors.teal),
];

class _ServiceItem {
  final String name, route;
  final IconData icon;
  final Color color;
  const _ServiceItem(this.name, this.route, this.icon, this.color);
}

class _ServiceCard extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Container(
        decoration: BoxDecoration(
          color: ClayColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ClayColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

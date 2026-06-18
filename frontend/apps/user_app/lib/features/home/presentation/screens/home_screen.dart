import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../../../features/wallet/presentation/providers/wallet_provider.dart';
import '../../../../features/profile/presentation/screens/profile_screen.dart';
import '../../../../features/history/presentation/screens/history_screen.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    final pages = <Widget>[
      _DashboardTab(),
      _OrdersTab(),
      _WalletTab(),
      _AccountTab(),
    ];

    return PopScope(
      // Never allow the OS back gesture to pop/exit from HomeScreen
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (currentTab != 0) {
          // If not on Home tab, go back to Home tab
          ref.read(currentTabProvider.notifier).state = 0;
        }
        // If already on Home tab (index 0), do nothing — stay in app
      },
      child: Scaffold(
        body: IndexedStack(index: currentTab, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ClayColors.primary,
          onTap: (i) => ref.read(currentTabProvider.notifier).state = i,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.wallet_outlined), activeIcon: Icon(Icons.wallet), label: 'Wallet'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> {
  String _selectedAddress = 'Jl. Buah Batu No.263';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletStateProvider.notifier).loadWallet();
    });
  }

  String _formatCurrency(int amount) {
    final str = amount.abs().toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(context),
              const SizedBox(height: 12),
              _buildLocationBar(context),
              const SizedBox(height: 24),
              _buildWalletSection(),
              const SizedBox(height: 28),
              _buildServicesSection(),
              const SizedBox(height: 32),
              _buildPromoSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset('assets/logo/logo_utama.png', height: 24),
            const SizedBox(width: 8),
            const Text(
              'CLAY',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: ClayColors.primary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined, size: 22),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ClayColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 22, color: ClayColors.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ClayColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: ClayColors.primary, size: 22),
            const SizedBox(width: 12),
            Text(
              'Find a service',
              style: TextStyle(color: ClayColors.textSecondary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBar(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await context.push('/location-picker');
        if (result != null && result is Map) {
          // Handle selected location
          setState(() {
            _selectedAddress = result['address'] ?? 'Jl. Buah Batu No.263';
          });
        }
      },
      child: Row(
        children: [
          Icon(Icons.location_on, color: ClayColors.primary, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _selectedAddress,
              style: TextStyle(fontSize: 14, color: ClayColors.textPrimary, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18, color: ClayColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildWalletSection() {
    final walletState = ref.watch(walletStateProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ClayWallet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 90,
          child: Row(
            children: [
              Expanded(
                child: _WalletCard(
                  icon: Icons.account_balance_wallet,
                  iconColor: Colors.blue,
                  label: 'Balance +',
                  value: 'Rp${_formatCurrency(walletState.balance)}',
                  onTap: () => ref.read(currentTabProvider.notifier).state = 2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WalletCard(
                  icon: Icons.arrow_upward,
                  iconColor: ClayColors.primary,
                  label: 'Payment',
                  value: 'Here',
                  onTap: () => ref.read(currentTabProvider.notifier).state = 2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WalletCard(
                  icon: Icons.receipt_long_outlined,
                  iconColor: ClayColors.primary,
                  label: 'Transaction',
                  value: 'History',
                  onTap: () => ref.read(currentTabProvider.notifier).state = 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _services.length,
          itemBuilder: (_, i) => _ServiceCard(item: _services[i]),
        ),
      ],
    );
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Promo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See all',
                style: TextStyle(fontSize: 14, color: ClayColors.primary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _promos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _PromoCard(promo: _promos[i]),
          ),
        ),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _WalletCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ClayColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: ClayColors.textSecondary),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: item.imageAsset.isEmpty
                ? const Icon(Icons.grid_view, color: Colors.grey, size: 22)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(item.imageAsset, fit: BoxFit.contain),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: ClayColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final _PromoItem promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: promo.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  promo.discountText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  promo.subText,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    promo.codeText,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -5,
            bottom: -5,
            child: Image.asset(
              promo.imageAsset,
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const HistoryScreen();
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
  _ServiceItem('ClayRide', '/ride', 'assets/logo/logo_clayride.png', const Color(0xFFB3D4F0)),
  _ServiceItem('ClayCar', '/car', 'assets/logo/logo_claycar.png', const Color(0xFFB3D4F0)),
  _ServiceItem('ClaySend', '/send', 'assets/logo/logo_claysend.png', const Color(0xFFB3D4F0)),
  _ServiceItem('ClayFood', '/food', 'assets/logo/logo_clayfood.png', const Color(0xFFF08080)),
  _ServiceItem('ClayPet', '/pet', 'assets/logo/logo_claypet.png', const Color(0xFFB3D4F0)),
  _ServiceItem('ClayWaste', '/waste', 'assets/logo/logo_claywaste.png', const Color(0xFFB3D4F0)),
  _ServiceItem('ClayCare', '/care', 'assets/logo/logo_claycare.png', const Color(0xFFB3D4F0)),
  _ServiceItem('Other', '/other', '', Colors.grey.shade300),
];

class _ServiceItem {
  final String name, route, imageAsset;
  final Color bgColor;
  const _ServiceItem(this.name, this.route, this.imageAsset, this.bgColor);
}

final _promos = [
  _PromoItem(
    discountText: 'DISCOUNT\n50%',
    subText: 'First Ride',
    codeText: 'Use Code : NEW10',
    bgColor: const Color(0xFF7EB8E0),
    imageAsset: 'assets/logo/logo_clayride.png',
  ),
  _PromoItem(
    discountText: 'DISCOUNT\n25%',
    subText: 'First Order',
    codeText: 'Use Code : NEW10',
    bgColor: const Color(0xFFE87070),
    imageAsset: 'assets/logo/logo_clayfood.png',
  ),
  _PromoItem(
    discountText: 'DISCOUNT\n15%',
    subText: 'First Order',
    codeText: 'Use Code : NEW10',
    bgColor: const Color(0xFFC0392B),
    imageAsset: 'assets/logo/logo_clayfood.png',
  ),
];

class _PromoItem {
  final String discountText, subText, codeText, imageAsset;
  final Color bgColor;
  const _PromoItem({
    required this.discountText,
    required this.subText,
    required this.codeText,
    required this.bgColor,
    required this.imageAsset,
  });
}

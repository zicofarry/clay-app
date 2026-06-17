import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../../../auth/presentation/providers/admin_auth_provider.dart';
import '../../../admins/presentation/screens/admin_management_screen.dart';
import '../../../security/presentation/screens/security_fraud_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminAuthProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors matching the user app reference
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF757575);
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE0E0E0);
    
    // Soft pastel blue from reference
    const primaryBlue = Color(0xFF7BB4E3);
    const softBlue = Color(0xFFD6E8F9);

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: NavigationBar(
        backgroundColor: cardColor,
        indicatorColor: softBlue,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            selectedIcon: Icon(Icons.dashboard_rounded, color: primaryBlue),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_rounded),
            label: 'Manajemen Admin',
          ),
          NavigationDestination(
            icon: Icon(Icons.security_rounded),
            label: 'Security',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: bgColor,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo placeholder similar to reference
                      Icon(Icons.cloud_rounded, color: primaryBlue, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'CLAY',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        ' Admin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFF0F0F0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_none_rounded, color: textColor, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: softBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, color: primaryBlue, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero banner (styled like ClayWallet card from reference)
                Text(
                  'System Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: softBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: primaryBlue, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Systems Operational',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last checked just now',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Online',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stats Title
                Text(
                  'Platform Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Stats Grid (styled like Promo cards or Services)
                statsAsync.when(
                  data: (stats) => MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                      _StatCard(
                        title: 'Pengguna',
                        value: stats.totalUsers.toString(),
                        icon: Icons.people_alt_rounded,
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        borderColor: borderColor,
                        isDark: isDark,
                        onTap: () => context.push('/users'),
                      ),
                      _StatCard(
                        title: 'Driver',
                        value: stats.totalDrivers.toString(),
                        icon: Icons.directions_car_rounded,
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        borderColor: borderColor,
                        isDark: isDark,
                        onTap: () => context.push('/drivers'),
                      ),
                      _StatCard(
                        title: 'Merchant',
                        value: stats.totalMerchants.toString(),
                        icon: Icons.store_rounded,
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        borderColor: borderColor,
                        isDark: isDark,
                        onTap: () => context.push('/merchants'),
                      ),
                      _StatCard(
                        title: 'Transaksi',
                        value: stats.totalTransactions.toString(),
                        icon: Icons.receipt_long_rounded,
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        borderColor: borderColor,
                        isDark: isDark,
                        onTap: () => context.push('/transactions'),
                      ),
                    ],
                  ),),
                  loading: () => const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator(color: primaryBlue)),
                  ),
                  error: (e, s) => Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Gagal memuat data', style: TextStyle(color: Color(0xFFD32F2F))),
                  ),
                ),


                
                const SizedBox(height: 32),
                
                // Layanan Lainnya
                Text(
                  'Layanan Lainnya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                 const SizedBox(height: 12),
                
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => context.push('/support'),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFD6E8F9), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.support_agent_rounded, color: Color(0xFF7BB4E3)),
                        ),
                        title: Text('Customer Support', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        subtitle: Text('Kelola tiket bantuan pengguna', style: TextStyle(color: subTextColor, fontSize: 12)),
                        trailing: Icon(Icons.chevron_right_rounded, color: subTextColor),
                      ),
                      Divider(color: borderColor, height: 1, indent: 64),
                      ListTile(
                        onTap: () => context.push('/finance'),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF4CAF50)),
                        ),
                        title: Text('Pencairan Dana (Finance)', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        subtitle: Text('Approval saldo driver & merchant', style: TextStyle(color: subTextColor, fontSize: 12)),
                        trailing: Icon(Icons.chevron_right_rounded, color: subTextColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
          const AdminManagementScreen(),
          const SecurityFraudScreen(),
        ],
      ),
    );
  }
}

// ─── Components ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;
  final Color borderColor;
  final bool isDark;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
    required this.borderColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: const Color(0xFF7BB4E3), size: 24),
                Icon(Icons.arrow_forward_ios_rounded, color: borderColor, size: 14),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

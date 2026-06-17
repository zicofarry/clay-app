import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/widgets.dart';
import '../../../auth/presentation/providers/driver_auth_provider.dart';
import '../../../earning/presentation/providers/earning_provider.dart';
import '../../../order/presentation/providers/order_provider.dart';

final isOnlineProvider = StateProvider<bool>((ref) => false);

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupPolling();
    });
  }

  @override
  void didUpdateWidget(covariant DriverHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setupPolling();
  }

  void _setupPolling() {
    _pollingTimer?.cancel();
    final isOnline = ref.read(isOnlineProvider);
    if (isOnline) {
      ref.read(orderProvider.notifier).checkDispatch();
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        ref.read(orderProvider.notifier).checkDispatch();
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(driverAuthProvider).driver;
    final isOnline = ref.watch(isOnlineProvider);
    final todayEarningAsync = ref.watch(todayEarningProvider);
    final orderState = ref.watch(orderProvider);
    final incomingOrder = orderState.incomingOrder;

    final todayEarning = todayEarningAsync.valueOrNull ?? {'total': 0, 'trips': 0, 'avg_fare': 0};
    final earningTotal = todayEarning['total'] ?? 0;
    final tripsToday = todayEarning['trips'] ?? 0;
    final avgFare = todayEarning['avg_fare'] ?? 0;
    final rating = driver?['rating'] ?? 0.0;

    final formattedEarning = earningTotal >= 1000
        ? 'Rp ${(earningTotal / 1000).toStringAsFixed(0)}K'
        : 'Rp $earningTotal';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => SystemNavigator.pop(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                driverName: driver?['name']?.toString().split(' ').first ?? 'Driver',
                rating: '$rating',
                avatarUrl: driver?['avatar_url']?.toString(),
              ),
              _OnlineToggle(
                isOnline: isOnline,
                onToggle: () async {
                  final notifier = ref.read(isOnlineProvider.notifier);
                  final nextState = !isOnline;
                  try {
                    if (nextState) {
                      await ref.read(orderRepositoryProvider).goOnline();
                    } else {
                      await ref.read(orderRepositoryProvider).goOffline();
                    }
                    notifier.state = nextState;
                    _setupPolling();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengubah status: $e')),
                    );
                  }
                },
              ),
              if (isOnline && incomingOrder != null)
                _IncomingOrderBanner(
                  order: incomingOrder,
                  onTap: () => context.go('/order/${incomingOrder['id']}'),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _StatsRow(
                      earnings: formattedEarning,
                      trips: '$tripsToday',
                      rating: '$rating',
                      avgFare: 'Rp $avgFare',
                    ),
                    const SizedBox(height: 16),
                    _EarningsCard(onTap: () => context.go('/earnings')),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context.go('/history'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: softShadow(),
                        child: const Row(
                          children: [
                            Icon(Icons.history, size: 20, color: ClayColors.primary),
                            SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Riwayat Trip', style: TextStyle(fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                                Text('Lihat semua riwayat perjalanan', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                              ],
                            )),
                            Icon(Icons.chevron_right, color: ClayColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const DriverBottomNav(current: '/home'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String driverName, rating;
  final String? avatarUrl;
  const _Header({required this.driverName, required this.rating, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(22)), gradient: LinearGradient(colors: [ClayColors.primaryLight, ClayColors.primaryDark])),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: avatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl!,
                            fit: BoxFit.cover, placeholder: (_, __) => const Icon(Icons.person, color: Colors.white), errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                          )
                        : const Icon(Icons.person, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, $driverName!', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.star, size: 12, color: ClayColors.warning),
                      const SizedBox(width: 4),
                      Text('$rating Rating', style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/notifications'),
            child: Container(
              width: 40, height: 40, decoration: softShadow(),
              child: const Center(child: Icon(Icons.notifications_outlined, size: 20, color: ClayColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineToggle extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;
  const _OnlineToggle({required this.isOnline, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isOnline ? const LinearGradient(colors: [ClayColors.green, ClayColors.greenDark]) : null,
            color: isOnline ? null : ClayColors.card,
            boxShadow: isOnline
                ? [BoxShadow(color: ClayColors.green.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: isOnline ? Colors.white.withValues(alpha: 0.2) : ClayColors.muted, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.power_settings_new, size: 24, color: isOnline ? Colors.white : ClayColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isOnline ? 'Anda Sedang Online' : 'Anda Sedang Offline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isOnline ? Colors.white : ClayColors.textPrimary)),
                Text(isOnline ? 'Siap menerima orderan' : 'Ketuk untuk mulai bekerja', style: TextStyle(fontSize: 11, color: isOnline ? Colors.white.withValues(alpha: 0.8) : ClayColors.textSecondary)),
              ])),
              ClayToggle(value: isOnline, onChanged: (_) => onToggle()),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String earnings, trips, rating, avgFare;
  const _StatsRow({required this.earnings, required this.trips, required this.rating, required this.avgFare});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StatCard(label: 'Hari Ini', value: earnings, icon: Icons.account_balance_wallet, color: ClayColors.primary),
      const SizedBox(width: 8),
      _StatCard(label: 'Trip', value: trips, icon: Icons.directions_car, color: ClayColors.green),
      const SizedBox(width: 8),
      _StatCard(label: 'Rating', value: rating, icon: Icons.star, color: ClayColors.warning),
      const SizedBox(width: 8),
      _StatCard(label: 'Rata-rata', value: avgFare, icon: Icons.trending_up, color: ClayColors.purple),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: softShadow(),
        child: Column(
          children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 15, color: Colors.white)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 9, color: ClayColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EarningsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [ClayColors.primary, ClayColors.primaryLight, ClayColors.primary]),
          boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Penghasilan Hari Ini', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 4),
              const Text('Lihat Detail', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
            ])),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.trending_up, size: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingOrderBanner extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  const _IncomingOrderBanner({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final serviceType = order['service_type'] ?? 'Ride';
    final fare = order['fare_estimate'] ?? order['fare_final'] ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: ClayColors.green.withValues(alpha: 0.1),
            border: Border.all(color: ClayColors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: ClayColors.green, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.delivery_dining, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ada Order Masuk! ($serviceType)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                Text('Fare: Rp $fare - Ketuk untuk detail', style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
              ])),
              const Icon(Icons.chevron_right, color: ClayColors.green),
            ],
          ),
        ),
      ),
    );
  }
}

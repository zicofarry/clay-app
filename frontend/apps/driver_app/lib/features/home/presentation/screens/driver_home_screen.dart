import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
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

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> with WidgetsBindingObserver {
  Timer? _pollingTimer;
  double _currentLat = -6.9147;
  double _currentLng = 107.6098;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(driverAuthProvider.notifier).refreshProfile();
        _updateGpsPosition();
      } catch (e) {
        dev.log('initState error: $e', name: 'HomeScreen');
      }
    });
  }

  Future<void> _updateGpsPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        dev.log('GPS service disabled', name: 'HomeScreen');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _currentLat = position.latitude;
      _currentLng = position.longitude;
      dev.log('GPS updated: $_currentLat, $_currentLng', name: 'HomeScreen');
    } catch (e) {
      dev.log('GPS error: $e', name: 'HomeScreen');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    dev.log('lifecycle: $state', name: 'HomeScreen');
    if (state == AppLifecycleState.resumed) {
      _restartPollingIfNeeded();
    } else if (state == AppLifecycleState.paused) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  void _restartPollingIfNeeded() {
    final isOnline = ref.read(isOnlineProvider);
    if (isOnline && _pollingTimer == null) {
      dev.log('restarting polling after resume', name: 'HomeScreen');
      _startPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _doPoll();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _doPoll();
    });
    dev.log('polling started', name: 'HomeScreen');
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    dev.log('polling stopped', name: 'HomeScreen');
  }

  void _doPoll() {
    try {
      final repo = ref.read(orderRepositoryProvider);
      repo.heartbeat();
      repo.updateLocation(_currentLat, _currentLng);
      ref.read(orderProvider.notifier).checkDispatch();
    } catch (e) {
      dev.log('polling error: $e', name: 'HomeScreen');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(driverAuthProvider);
    final driver = authState.driver;
    final isOnline = ref.watch(isOnlineProvider);
    final todayEarningAsync = ref.watch(todayEarningProvider);
    final orderState = ref.watch(orderProvider);
    final incomingOrder = orderState.incomingOrder;

    ref.listen<bool>(isOnlineProvider, (prev, next) {
      dev.log('isOnline changed: $prev -> $next', name: 'HomeScreen');
      if (next) {
        _startPolling();
      } else {
        _stopPolling();
      }
    });

    dev.log('build: driver=${driver != null}, isOnline=$isOnline, timerActive=${_pollingTimer != null}', name: 'HomeScreen');

    final todayEarning = todayEarningAsync.valueOrNull ?? {'total': 0, 'trips': 0, 'avg_fare': 0};
    final earningTotal = todayEarning['total'] ?? 0;
    final tripsToday = todayEarning['trips'] ?? 0;
    final avgFare = todayEarning['avg_fare'] ?? 0;
    final rating = driver?['rating'] ?? 0.0;
    final driverName = driver?['name']?.toString().split(' ').first ?? 'Driver';

    final formattedEarning = earningTotal >= 1000
        ? 'Rp ${(earningTotal / 1000).toStringAsFixed(0)}K'
        : 'Rp $earningTotal';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: ClayColors.background,
        bottomNavigationBar: _buildBottomNav(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [ClayColors.primaryLight, ClayColors.primaryDark]),
                            ),
                            child: const Center(child: Icon(Icons.person, color: Colors.white, size: 24)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, $driverName!',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                              ),
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
                        width: 40, height: 40,
                        decoration: softShadow(),
                        child: const Center(child: Icon(Icons.notifications_outlined, size: 20, color: ClayColors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Online toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () async {
                    final notifier = ref.read(isOnlineProvider.notifier);
                    final nextState = !isOnline;
                    try {
                      if (nextState) {
                        await _updateGpsPosition();
                        await ref.read(orderRepositoryProvider).goOnline(lat: _currentLat, lng: _currentLng);
                      } else {
                        await ref.read(orderRepositoryProvider).goOffline();
                      }
                      notifier.state = nextState;
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal mengubah status: $e')),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isOnline ? ClayColors.green : ClayColors.card,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.white.withValues(alpha: 0.2) : ClayColors.muted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.power_settings_new, size: 24, color: isOnline ? Colors.white : ClayColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(isOnline ? 'Anda Sedang Online' : 'Anda Sedang Offline',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isOnline ? Colors.white : ClayColors.textPrimary)),
                          Text(isOnline ? 'Siap menerima orderan' : 'Ketuk untuk mulai bekerja',
                              style: TextStyle(fontSize: 11, color: isOnline ? Colors.white.withValues(alpha: 0.8) : ClayColors.textSecondary)),
                        ])),
                      ],
                    ),
                  ),
                ),
              ),
              // Incoming order banner
              if (isOnline && incomingOrder != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () => context.go('/order/${incomingOrder['id']}'),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: ClayColors.green.withValues(alpha: 0.1),
                        border: Border.all(color: ClayColors.green.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.delivery_dining, color: ClayColors.green, size: 28),
                          SizedBox(width: 12),
                          Expanded(child: Text('Ada Order Masuk!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ClayColors.textPrimary))),
                          Icon(Icons.chevron_right, color: ClayColors.green),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  _StatCard(label: 'Hari Ini', value: formattedEarning, icon: Icons.account_balance_wallet, color: ClayColors.primary),
                  const SizedBox(width: 8),
                  _StatCard(label: 'Trip', value: '$tripsToday', icon: Icons.directions_car, color: ClayColors.green),
                  const SizedBox(width: 8),
                  _StatCard(label: 'Rating', value: '$rating', icon: Icons.star, color: ClayColors.warning),
                  const SizedBox(width: 8),
                  _StatCard(label: 'Rata-rata', value: 'Rp $avgFare', icon: Icons.trending_up, color: ClayColors.purple),
                ]),
              ),
              const SizedBox(height: 20),
              // Earnings card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => context.go('/earnings'),
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
                ),
              ),
              const SizedBox(height: 20),
              // History row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
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
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(icon: Icons.directions_car_outlined, label: 'Beranda', route: '/home', currentRoute: '/home'),
              _NavItem(icon: Icons.access_time_rounded, label: 'Riwayat', route: '/history', currentRoute: '/home'),
              _NavItem(icon: Icons.account_balance_wallet_outlined, label: 'Pendapatan', route: '/earnings', currentRoute: '/home'),
              _NavItem(icon: Icons.person_outline, label: 'Profil', route: '/profile', currentRoute: '/home'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final active = route == currentRoute;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!active) context.go(route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: active ? ClayColors.primary : ClayColors.textSecondary),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: active ? ClayColors.primary : ClayColors.textSecondary)),
              if (active) ...[
                const SizedBox(height: 4),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: ClayColors.primary, shape: BoxShape.circle)),
              ],
            ],
          ),
        ),
      ),
    );
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/widgets.dart';
import '../../../auth/presentation/providers/driver_auth_provider.dart';
import '../../../home/presentation/screens/driver_home_screen.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(driverAuthProvider).driver;

    final vehicleBrand = d?['vehicle_brand']?.toString() ?? d?['vehicle']?.toString() ?? '-';
    final vehicleModel = d?['vehicle_model']?.toString() ?? '';
    final vehicleYear = d?['vehicle_year']?.toString() ?? '';
    final vehicleColor = d?['vehicle_color']?.toString() ?? '';
    final plate = d?['plate']?.toString() ?? '-';
    final totalTrips = d?['total_orders'] ?? 0;
    final rating = d?['rating'] ?? 0.0;
    final verificationStatus = d?['verification_status']?.toString() ?? 'pending';
    final avatarUrl = d?['avatar_url']?.toString();

    final vehicleDisplay = [vehicleBrand, vehicleModel].where((s) => s.isNotEmpty).join(' ');
    final vehicleMeta = [vehicleColor, vehicleYear].where((s) => s.isNotEmpty).join(' | ');

    final verificationLabel = switch (verificationStatus) {
      'verified' => ('Terverifikasi', ClayColors.green),
      'pending' => ('Menunggu Verifikasi', ClayColors.warning),
      'rejected' => ('Ditolak', ClayColors.accent),
      'suspended' => ('Ditangguhkan', ClayColors.accent),
      _ => (verificationStatus, ClayColors.textSecondary),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(onTap: () { if (Navigator.canPop(context)) { context.pop(); } else { context.go('/home'); } }, child: Container(width: 40, height: 40, decoration: softShadow(), child: const Center(child: Icon(Icons.arrow_back, size: 20, color: ClayColors.textPrimary)))),
                  const SizedBox(width: 12),
                  const Text('Profil Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: softShadow(),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(width: 72, height: 72, decoration: BoxDecoration(borderRadius: BorderRadius.circular(36), gradient: const LinearGradient(colors: [ClayColors.primaryLight, ClayColors.primaryDark])), child: ClipRRect(
                              borderRadius: BorderRadius.circular(36),
                              child: avatarUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: avatarUrl,
                                      fit: BoxFit.cover, placeholder: (_, __) => const Icon(Icons.person, color: Colors.white), errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                                    )
                                  : const Icon(Icons.person, color: Colors.white),
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(d?['name'] ?? '-', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                              Text(d?['phone'] ?? '-', style: const TextStyle(fontSize: 13, color: ClayColors.textSecondary)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: verificationLabel.$2.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                child: Text(verificationLabel.$1, style: TextStyle(fontSize: 10, color: verificationLabel.$2, fontWeight: FontWeight.w500)),
                              ),
                            ])),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(child: _ProfileStat(icon: Icons.directions_car, value: '$totalTrips', label: 'Trip')),
                            const _ProfileStatDivider(),
                            Expanded(child: _ProfileStat(icon: Icons.star, value: '$rating', label: 'Rating')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Kendaraan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: softShadow(),
                    child: Row(
                      children: [
                        Container(width: 56, height: 56, decoration: BoxDecoration(color: ClayColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.directions_car, size: 28, color: ClayColors.primary)),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(vehicleDisplay, style: const TextStyle(fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                          Text(plate, style: const TextStyle(fontSize: 13, color: ClayColors.textSecondary)),
                          if (vehicleMeta.isNotEmpty)
                            Text(vehicleMeta, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                        ])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Pengaturan Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: ClayColors.card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                    child: Column(
                      children: [
                        _MenuItem(icon: Icons.settings_outlined, label: 'Pengaturan', onTap: () => context.go('/settings')),
                        _MenuItem(icon: Icons.help_outline, label: 'Bantuan', onTap: () => context.go('/help'), isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      ref.read(driverAuthProvider.notifier).logout();
                      ref.read(isOnlineProvider.notifier).state = false;
                      context.go('/login');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: ClayColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.logout, size: 18, color: ClayColors.accent),
                        SizedBox(width: 8),
                        Text('Keluar', style: TextStyle(fontWeight: FontWeight.w500, color: ClayColors.accent)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(child: Text('ClayRide Driver v2.5.0', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary))),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DriverBottomNav(current: '/profile'),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _ProfileStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14, color: ClayColors.primary),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
        ]),
        Text(label, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
      ],
    );
  }
}

class _ProfileStatDivider extends StatelessWidget {
  const _ProfileStatDivider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 24, color: ClayColors.divider, margin: const EdgeInsets.symmetric(horizontal: 4));
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: ClayColors.divider))),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.muted, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: ClayColors.textSecondary)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ClayColors.textPrimary))),
            const Icon(Icons.chevron_right, size: 18, color: ClayColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

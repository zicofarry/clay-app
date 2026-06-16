import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final authState = ref.watch(authStateProvider);
    final userPhone = authState.authResponse?.user.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      body: profileAsync.when(
        data: (profile) {
          final fullName = profile['full_name']?.toString() ?? 'User Clay';
          final referral = profile['referral_code']?.toString() ?? '-';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ClayColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ClayColors.divider),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: ClayColors.primary,
                      child: const Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userPhone.isNotEmpty ? userPhone : 'No Phone',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Referral: $referral',
                            style: const TextStyle(fontSize: 12, color: ClayColors.primary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Pengaturan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _MenuItem(icon: Icons.location_on_outlined, title: 'Alamat Tersimpan', onTap: () {}),
              _MenuItem(icon: Icons.payment_outlined, title: 'Metode Pembayaran', onTap: () {}),
              _MenuItem(icon: Icons.notifications_outlined, title: 'Notifikasi', onTap: () {}),
              _MenuItem(icon: Icons.language, title: 'Bahasa', onTap: () {}),
              _MenuItem(icon: Icons.dark_mode_outlined, title: 'Tema Gelap', onTap: () {}),
              const SizedBox(height: 24),
              const Text('Lainnya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _MenuItem(icon: Icons.star_outline, title: 'Beri Rating', onTap: () {}),
              _MenuItem(icon: Icons.help_outline, title: 'Pusat Bantuan', onTap: () {}),
              _MenuItem(icon: Icons.info_outline, title: 'Tentang', onTap: () {}),
              const SizedBox(height: 24),
              ClayButton(
                label: 'Keluar',
                backgroundColor: ClayColors.error,
                onPressed: () {
                  ref.read(authStateProvider.notifier).logout();
                  context.go('/login');
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: ClayColors.error),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat profil: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(profileProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: ClayColors.textSecondary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

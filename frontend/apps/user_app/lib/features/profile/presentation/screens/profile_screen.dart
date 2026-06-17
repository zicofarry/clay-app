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
      body: profileAsync.when(
        data: (profile) => _buildContent(context, ref, profile, userPhone),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildError(context, ref, err),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Map<String, dynamic> profile, String userPhone) {
    final fullName = profile['full_name']?.toString() ?? 'User Clay';
    final avatarUrl = profile['avatar_url']?.toString() ?? '';
    final birthDate = profile['birth_date']?.toString() ?? '';
    final gender = profile['gender']?.toString() ?? '';
    final referral = profile['referral_code']?.toString() ?? '-';

    return RefreshIndicator(
      onRefresh: () => ref.read(profileProvider.notifier).loadProfile(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Gradient Header ───────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ClayColors.primary, ClayColors.primaryDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Akun Saya', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => _showEditDialog(context, ref, profile),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl.isEmpty
                                  ? const Icon(Icons.person, size: 36, color: Colors.white)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.camera_alt, size: 14, color: ClayColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userPhone.isNotEmpty ? userPhone : 'No Phone',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Info Cards ────────────────────────────────────────────────
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.cake_outlined,
                        label: 'Tanggal Lahir',
                        value: birthDate.isNotEmpty ? birthDate : 'Belum diisi',
                      ),
                    ),
                    Container(width: 1, height: 40, color: ClayColors.divider),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.person_outline,
                        label: 'Gender',
                        value: gender.isNotEmpty ? _genderLabel(gender) : 'Belum diisi',
                      ),
                    ),
                    Container(width: 1, height: 40, color: ClayColors.divider),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.card_giftcard_outlined,
                        label: 'Referral',
                        value: referral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Menu Sections ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _SectionTitle('Pengaturan'),
                _MenuGroup(
                  items: [
                    _MenuItemData(Icons.location_on_outlined, Colors.orange, 'Alamat Tersimpan', 'Kelola alamat pengiriman'),
                    _MenuItemData(Icons.payment_outlined, Colors.blue, 'Metode Pembayaran', 'Kartu, e-wallet, transfer'),
                    _MenuItemData(Icons.notifications_outlined, Colors.red, 'Notifikasi', 'Atur pemberitahuan'),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionTitle('Preferensi'),
                _MenuGroup(
                  items: [
                    _MenuItemData(Icons.language, Colors.green, 'Bahasa', 'Indonesia'),
                    _MenuItemData(Icons.dark_mode_outlined, Colors.indigo, 'Tema Gelap', 'Nonaktif'),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionTitle('Lainnya'),
                _MenuGroup(
                  items: [
                    _MenuItemData(Icons.star_outline, Colors.amber, 'Beri Rating', 'Bantu kami berkembang'),
                    _MenuItemData(Icons.help_outline, Colors.teal, 'Pusat Bantuan', 'FAQ & hubungi kami'),
                    _MenuItemData(Icons.info_outline, Colors.grey, 'Tentang', 'Versi 1.0.0'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ClayButton(
                    label: 'Keluar',
                    backgroundColor: ClayColors.error,
                    onPressed: () {
                      ref.read(authStateProvider.notifier).logout();
                      context.go('/login');
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: ClayColors.error),
            const SizedBox(height: 16),
            Text('Gagal memuat profil', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  String _genderLabel(String g) {
    switch (g) {
      case 'male': return 'Pria';
      case 'female': return 'Wanita';
      case 'other': return 'Lainnya';
      default: return g;
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> profile) {
    final nameCtrl = TextEditingController(text: profile['full_name']?.toString() ?? '');
    final birthCtrl = TextEditingController(text: profile['birth_date']?.toString() ?? '');
    const validGenders = ['male', 'female', 'other'];
    final rawGender = profile['gender']?.toString() ?? '';
    String selectedGender = validGenders.contains(rawGender) ? rawGender : 'male';
    String? nameError;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    errorText: nameError,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (nameError != null) setDialogState(() => nameError = null);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: birthCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime(1995),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      birthCtrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Pria')),
                    DropdownMenuItem(value: 'female', child: Text('Wanita')),
                    DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                  ],
                  onChanged: isSaving
                      ? null
                      : (v) {
                          if (v != null) {
                            setDialogState(() => selectedGender = v);
                          }
                        },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final trimmedName = nameCtrl.text.trim();
                      if (trimmedName.isEmpty) {
                        setDialogState(() => nameError = 'Nama tidak boleh kosong');
                        return;
                      }
                      setDialogState(() => isSaving = true);

                      final birth = birthCtrl.text.trim();
                      final ok = await ref.read(profileProvider.notifier).updateProfile(
                            fullName: trimmedName,
                            birthDate: birth.isEmpty ? null : birth,
                            gender: selectedGender,
                          );

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'Profil berhasil diperbarui' : 'Gagal memperbarui profil'),
                            backgroundColor: ok ? Colors.green : ClayColors.error,
                          ),
                        );
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: ClayColors.textSecondary),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: ClayColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _MenuItemData(this.icon, this.iconColor, this.title, this.subtitle);
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItemData> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 56, color: ClayColors.divider),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: items[i].iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(items[i].icon, color: items[i].iconColor, size: 20),
              ),
              title: Text(items[i].title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text(items[i].subtitle, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              onTap: () {},
            ),
          ],
        ],
      ),
    );
  }
}

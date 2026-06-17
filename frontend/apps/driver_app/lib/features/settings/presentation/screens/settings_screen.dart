import 'package:flutter/material.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _sound = true;
  bool _vibration = true;
  bool _locationSharing = true;
  bool _autoAccept = false;

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun', style: TextStyle(color: ClayColors.accent, fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus akun Anda secara permanen? Semua data pendapatan, riwayat, dan profil Anda akan dihapus selamanya. Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: ClayColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permintaan penghapusan akun sedang diproses...'), backgroundColor: ClayColors.accent),
              );
            },
            child: const Text('Hapus Permanen', style: TextStyle(color: ClayColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: softShadow(),
                      child: const Center(
                        child: Icon(Icons.arrow_back, size: 20, color: ClayColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Pengaturan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _Section(title: 'Tampilan', children: [
                    _ToggleItem(icon: Icons.dark_mode, label: 'Mode Gelap', value: _darkMode, onChanged: (v) => setState(() => _darkMode = v)),
                    _LinkItem(
                      icon: Icons.language,
                      label: 'Bahasa',
                      value: 'Indonesia',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pengaturan bahasa dibuka (Default: Indonesia)'), duration: Duration(seconds: 1)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _Section(title: 'Notifikasi', children: [
                    _ToggleItem(icon: Icons.notifications_outlined, label: 'Notifikasi Push', value: _notifications, onChanged: (v) => setState(() => _notifications = v)),
                    _ToggleItem(icon: Icons.volume_up_outlined, label: 'Suara', value: _sound, onChanged: (v) => setState(() => _sound = v)),
                    _ToggleItem(icon: Icons.vibration, label: 'Getaran', value: _vibration, onChanged: (v) => setState(() => _vibration = v)),
                  ]),
                  const SizedBox(height: 16),
                  _Section(title: 'Privasi', children: [
                    _ToggleItem(icon: Icons.location_on_outlined, label: 'Bagikan Lokasi', value: _locationSharing, onChanged: (v) => setState(() => _locationSharing = v)),
                    _LinkItem(
                      icon: Icons.lock_outlined,
                      label: 'Ubah PIN',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu Ubah PIN dibuka...'), duration: Duration(seconds: 1)),
                      ),
                    ),
                    _LinkItem(
                      icon: Icons.phone_android,
                      label: 'Perangkat Terhubung',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Memeriksa perangkat terhubung...'), duration: Duration(seconds: 1)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _Section(title: 'Order', children: [
                    _ToggleItem(icon: Icons.shield_outlined, label: 'Auto Accept Order', description: 'Terima order otomatis saat rating tinggi', value: _autoAccept, onChanged: (v) => setState(() => _autoAccept = v)),
                  ]),
                  const SizedBox(height: 16),

                  // Danger zone
                  const Text('Zona Berbahaya', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ClayColors.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showDeleteAccountDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: ClayColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.delete_outline, size: 18, color: ClayColors.accent)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Hapus Akun', style: TextStyle(fontWeight: FontWeight.w500, color: ClayColors.accent)),
                            Text('Tindakan ini tidak dapat dibatalkan', style: TextStyle(fontSize: 11, color: ClayColors.accent.withValues(alpha: 0.7))),
                          ])),
                          const Icon(Icons.chevron_right, size: 18, color: ClayColors.accent),
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
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ClayColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: ClayColors.card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleItem({required this.icon, required this.label, this.description, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ClayColors.divider))),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.muted, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: ClayColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ClayColors.textPrimary)),
            if (description != null) Text(description!, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
          ])),
          ClayToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  const _LinkItem({required this.icon, required this.label, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.transparent, border: Border(bottom: BorderSide(color: ClayColors.divider))),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.muted, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: ClayColors.textSecondary)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ClayColors.textPrimary))),
            if (value != null) Text(value!, style: const TextStyle(fontSize: 13, color: ClayColors.textSecondary)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: ClayColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

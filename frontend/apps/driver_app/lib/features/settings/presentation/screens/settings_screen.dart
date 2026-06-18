import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets.dart';

final settingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final response = await ClayApi.instance.dio.get('/settings');
    final data = response.data as Map<String, dynamic>;
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    return inner;
  } catch (_) {
    return {};
  }
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _initialized = false;
  bool _saving = false;

  bool _darkMode = false;
  bool _notifications = true;
  bool _sound = true;
  bool _vibration = true;
  bool _locationSharing = true;
  bool _autoAccept = false;

  void _applyFromData(Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() {
      if (data.containsKey('dark_mode')) _darkMode = data['dark_mode'] == true;
      if (data.containsKey('push_notifications')) _notifications = data['push_notifications'] != false;
      if (data.containsKey('sound_enabled')) _sound = data['sound_enabled'] != false;
      if (data.containsKey('vibration_enabled')) _vibration = data['vibration_enabled'] != false;
      if (data.containsKey('location_sharing')) _locationSharing = data['location_sharing'] != false;
      if (data.containsKey('auto_accept')) _autoAccept = data['auto_accept'] == true;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      await ClayApi.instance.dio.put('/settings', data: {
        'dark_mode': _darkMode,
        'push_notifications': _notifications,
        'sound_enabled': _sound,
        'vibration_enabled': _vibration,
        'location_sharing': _locationSharing,
        'auto_accept': _autoAccept,
      });
      ref.invalidate(settingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan disimpan'), backgroundColor: ClayColors.green),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final msg = data is Map
          ? (data['message']?.toString() ?? e.message ?? 'Gagal menyimpan pengaturan')
          : (e.message ?? 'Gagal menyimpan pengaturan');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: ClayColors.accent),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: ClayColors.accent),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    settingsAsync.whenData((data) {
      if (!_initialized) {
        _initialized = true;
        _applyFromData(data);
      }
    });

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
                  const Text(
                    'Pengaturan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Tampilan
                  _Section(title: 'Tampilan', children: [
                    _ToggleItem(
                      icon: Icons.dark_mode,
                      label: 'Mode Gelap',
                      value: _darkMode,
                      onChanged: (v) {
                        setState(() => _darkMode = v);
                        _saveSettings();
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Notifikasi
                  _Section(title: 'Notifikasi', children: [
                    _ToggleItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifikasi Push',
                      value: _notifications,
                      onChanged: (v) {
                        setState(() => _notifications = v);
                        _saveSettings();
                      },
                    ),
                    _ToggleItem(
                      icon: Icons.volume_up_outlined,
                      label: 'Suara',
                      value: _sound,
                      onChanged: (v) {
                        setState(() => _sound = v);
                        _saveSettings();
                      },
                    ),
                    _ToggleItem(
                      icon: Icons.vibration,
                      label: 'Getaran',
                      value: _vibration,
                      onChanged: (v) {
                        setState(() => _vibration = v);
                        _saveSettings();
                      },
                    ),
                    _LinkItem(
                      icon: Icons.tune,
                      label: 'Preferensi Notifikasi',
                      onTap: () => context.push('/notification-preferences'),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Privasi
                  _Section(title: 'Privasi', children: [
                    _ToggleItem(
                      icon: Icons.location_on_outlined,
                      label: 'Bagikan Lokasi',
                      value: _locationSharing,
                      onChanged: (v) {
                        setState(() => _locationSharing = v);
                        _saveSettings();
                      },
                    ),
                    _LinkItem(
                      icon: Icons.lock_outlined,
                      label: 'Ubah Password',
                      onTap: () => context.push('/change-password'),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Order
                  _Section(title: 'Order', children: [
                    _ToggleItem(
                      icon: Icons.shield_outlined,
                      label: 'Auto Accept Order',
                      description: 'Terima order otomatis saat rating tinggi',
                      value: _autoAccept,
                      onChanged: (v) {
                        setState(() => _autoAccept = v);
                        _saveSettings();
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Akun
                  _Section(title: 'Akun', children: [
                    _LinkItem(
                      icon: Icons.person_outline,
                      label: 'Edit Profil',
                      onTap: () => context.push('/edit-profile'),
                    ),
                    _LinkItem(
                      icon: Icons.description_outlined,
                      label: 'Dokumen',
                      onTap: () => context.push('/documents'),
                    ),
                    _LinkItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Dompet',
                      onTap: () => context.push('/wallet'),
                    ),
                  ]),
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
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ClayColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ClayColors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
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
  const _ToggleItem({
    required this.icon,
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ClayColors.divider))),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ClayColors.muted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: ClayColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ClayColors.textPrimary),
                ),
                if (description != null)
                  Text(description!, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
              ],
            ),
          ),
          ClayToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _LinkItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(bottom: BorderSide(color: ClayColors.divider)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ClayColors.muted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: ClayColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ClayColors.textPrimary),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: ClayColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

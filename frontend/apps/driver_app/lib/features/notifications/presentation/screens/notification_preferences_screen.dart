import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets.dart';

final notificationPrefsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final response = await ClayApi.instance.dio.get('/settings');
    final data = response.data as Map<String, dynamic>;
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    return inner;
  } catch (_) {
    return {};
  }
});

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends ConsumerState<NotificationPreferencesScreen> {
  bool _initialized = false;

  bool _orderNotifications = true;
  bool _earningNotifications = true;
  bool _promotionNotifications = true;
  bool _systemNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final prefsAsync = ref.read(notificationPrefsProvider);
      prefsAsync.whenData((data) {
        setState(() {
          _orderNotifications = data['order_notifications'] != false;
          _earningNotifications = data['earning_notifications'] != false;
          _promotionNotifications = data['promotion_notifications'] != false;
          _systemNotifications = data['system_notifications'] != false;
          _soundEnabled = data['sound_enabled'] != false;
          _vibrationEnabled = data['vibration_enabled'] != false;
        });
      });
    }
  }

  Future<void> _savePreferences() async {
    try {
      await ClayApi.instance.dio.put('/settings', data: {
        'order_notifications': _orderNotifications,
        'earning_notifications': _earningNotifications,
        'promotion_notifications': _promotionNotifications,
        'system_notifications': _systemNotifications,
        'sound_enabled': _soundEnabled,
        'vibration_enabled': _vibrationEnabled,
      });
    } catch (_) {
      // Silently fail if endpoint doesn't exist; local state is already updated.
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(notificationPrefsProvider);

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
                        context.go('/settings');
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
                    'Preferensi Notifikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Jenis Notifikasi
                  _Section(title: 'Jenis Notifikasi', children: [
                    _ToggleItem(
                      icon: Icons.assignment,
                      label: 'Order Baru',
                      description: 'Pemberitahuan saat ada order masuk',
                      value: _orderNotifications,
                      onChanged: (v) {
                        setState(() => _orderNotifications = v);
                        _savePreferences();
                      },
                    ),
                    _ToggleItem(
                      icon: Icons.account_balance_wallet,
                      label: 'Pendapatan',
                      description: 'Pembayaran, pencairan, dan settlement',
                      value: _earningNotifications,
                      onChanged: (v) {
                        setState(() => _earningNotifications = v);
                        _savePreferences();
                      },
                    ),
                    _ToggleItem(
                      icon: Icons.local_offer,
                      label: 'Promosi',
                      description: 'Bonus, insentif, dan penawaran spesial',
                      value: _promotionNotifications,
                      onChanged: (v) {
                        setState(() => _promotionNotifications = v);
                        _savePreferences();
                      },
                    ),
                    _ToggleItem(
                      icon: Icons.info_outline,
                      label: 'Sistem',
                      description: 'Update aplikasi dan pengumuman penting',
                      value: _systemNotifications,
                      onChanged: (v) {
                        setState(() => _systemNotifications = v);
                        _savePreferences();
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Pengaturan Alert
                  _Section(title: 'Pengaturan Alert', children: [
                    _ToggleItem(
                      icon: Icons.volume_up_outlined,
                      label: 'Suara',
                      description: 'Bunyikan suara saat notifikasi masuk',
                      value: _soundEnabled,
                      onChanged: (v) {
                        setState(() => _soundEnabled = v);
                        _savePreferences();
                      },
                    ),
                    _ToggleItem(
                      icon: Icons.vibration,
                      label: 'Getaran',
                      description: 'Getarkan perangkat saat notifikasi masuk',
                      value: _vibrationEnabled,
                      onChanged: (v) {
                        setState(() => _vibrationEnabled = v);
                        _savePreferences();
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ClayColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: ClayColors.primary.withValues(alpha: 0.7)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Notifikasi order masuk tidak dapat dimatikan saat Anda sedang online.',
                            style: TextStyle(
                              fontSize: 11,
                              color: ClayColors.primary.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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

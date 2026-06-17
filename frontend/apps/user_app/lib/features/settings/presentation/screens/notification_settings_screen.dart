import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/settings_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  Timer? _notifDebounce;
  Timer? _marketingDebounce;

  @override
  void dispose() {
    _notifDebounce?.cancel();
    _marketingDebounce?.cancel();
    super.dispose();
  }

  void _onNotif(bool v) {
    _notifDebounce?.cancel();
    _notifDebounce = Timer(const Duration(milliseconds: 300), () async {
      final ok = await ref.read(settingsProvider.notifier).setNotifEnabled(v);
      if (!mounted) return;
      _showFeedback(ok, 'Notifikasi pesanan ${v ? 'diaktifkan' : 'dinonaktifkan'}');
    });
  }

  void _onMarketing(bool v) {
    _marketingDebounce?.cancel();
    _marketingDebounce = Timer(const Duration(milliseconds: 300), () async {
      final ok = await ref.read(settingsProvider.notifier).setMarketingEnabled(v);
      if (!mounted) return;
      _showFeedback(ok, 'Promo & update ${v ? 'diaktifkan' : 'dinonaktifkan'}');
    });
  }

  void _showFeedback(bool ok, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: ok ? Colors.green : ClayColors.error,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_outlined),
            onPressed: state.isLoading ? null : () => ref.read(settingsProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading && !state.notifEnabled && !state.marketingEnabled
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(settingsProvider.notifier).load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ClayColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ClayColors.error.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: ClayColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: const TextStyle(fontSize: 12, color: ClayColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _SectionHeader(
                    icon: Icons.notifications_active_outlined,
                    iconColor: ClayColors.primary,
                    title: 'Jenis Notifikasi',
                    subtitle: 'Atur jenis pemberitahuan yang ingin kamu terima',
                  ),
                  const SizedBox(height: 12),
                  _ToggleCard(
                    icon: Icons.shopping_bag_outlined,
                    iconColor: Colors.orange,
                    title: 'Notifikasi Pesanan',
                    subtitle: 'Status pesanan, chat driver, dan update pengantaran',
                    value: state.notifEnabled,
                    onChanged: _onNotif,
                  ),
                  const SizedBox(height: 10),
                  _ToggleCard(
                    icon: Icons.campaign_outlined,
                    iconColor: Colors.pink,
                    title: 'Promo & Update',
                    subtitle: 'Diskon, voucher, dan info produk baru',
                    value: state.marketingEnabled,
                    onChanged: _onMarketing,
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.phonelink_ring_outlined,
                    iconColor: Colors.indigo,
                    title: 'Notifikasi Sistem',
                    subtitle: 'Pengaturan tampilan di perangkat (coming soon)',
                  ),
                  const SizedBox(height: 12),
                  const _DisabledCard(
                    icon: Icons.vibration,
                    iconColor: Colors.teal,
                    title: 'Getar',
                    subtitle: 'Segera tersedia',
                  ),
                  const SizedBox(height: 10),
                  const _DisabledCard(
                    icon: Icons.volume_up_outlined,
                    iconColor: Colors.blue,
                    title: 'Suara',
                    subtitle: 'Segera tersedia',
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _SectionHeader({required this.icon, required this.iconColor, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ClayColors.divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: ClayColors.primary),
        ],
      ),
    );
  }
}

class _DisabledCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _DisabledCard({required this.icon, required this.iconColor, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ClayColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor.withValues(alpha: 0.6), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textSecondary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(value: false, onChanged: null),
        ],
      ),
    );
  }
}

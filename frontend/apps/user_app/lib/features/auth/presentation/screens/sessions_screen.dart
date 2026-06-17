import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/auth_provider.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await ref.read(authStateProvider.notifier).listSessions();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  Future<void> _revokeSession(String sessionId, String deviceInfo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Sesi'),
        content: Text('Logout dari "$deviceInfo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: ClayColors.error),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await ref.read(authStateProvider.notifier).revokeSession(sessionId);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(ok ? 'Sesi berhasil dihapus' : 'Gagal menghapus sesi'),
        backgroundColor: ok ? Colors.green : ClayColors.error,
      ));

    if (ok) _loadSessions();
  }

  Future<void> _revokeAllSessions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout Semua Perangkat'),
        content: const Text(
          'Semua sesi login di perangkat lain akan dihentikan. Anda tetap login di perangkat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Ya, Logout Semua'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await ref.read(authStateProvider.notifier).logoutAll();
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(ok ? 'Semua sesi lain telah dihentikan' : 'Gagal menghapus sesi'),
        backgroundColor: ok ? Colors.green : ClayColors.error,
      ));

    if (ok) _loadSessions();
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';

      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  IconData _getDeviceIcon(String deviceInfo) {
    final lower = deviceInfo.toLowerCase();
    if (lower.contains('android')) return Icons.phone_android;
    if (lower.contains('iphone') || lower.contains('ios')) return Icons.phone_iphone;
    if (lower.contains('windows')) return Icons.computer;
    if (lower.contains('mac')) return Icons.laptop_mac;
    if (lower.contains('linux')) return Icons.terminal;
    if (lower.contains('web') || lower.contains('browser')) return Icons.web;
    return Icons.devices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        title: const Text('Perangkat Aktif'),
        backgroundColor: ClayColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ClayColors.primary))
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ClayColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: ClayColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Perangkat yang sedang login ke akun Anda',
                            style: TextStyle(color: ClayColors.primaryDark, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_sessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.devices_other, size: 64, color: ClayColors.textSecondary.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada sesi aktif',
                            style: TextStyle(color: ClayColors.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    for (final session in _sessions) ...[
                      _SessionCard(
                        deviceInfo: session['device_info']?.toString() ?? 'Unknown Device',
                        ipAddress: session['ip_address']?.toString() ?? '-',
                        lastActive: _formatDateTime(session['last_active']?.toString()),
                        isCurrent: session['is_current'] == true,
                        deviceIcon: _getDeviceIcon(session['device_info']?.toString() ?? ''),
                        onRevoke: session['is_current'] == true
                            ? null
                            : () => _revokeSession(
                                  session['session_id']?.toString() ?? '',
                                  session['device_info']?.toString() ?? 'Unknown Device',
                                ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (_sessions.any((s) => s['is_current'] != true)) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ClayButton(
                          label: 'Logout dari Semua Perangkat Lain',
                          backgroundColor: Colors.orange,
                          onPressed: _revokeAllSessions,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String deviceInfo;
  final String ipAddress;
  final String lastActive;
  final bool isCurrent;
  final IconData deviceIcon;
  final VoidCallback? onRevoke;

  const _SessionCard({
    required this.deviceInfo,
    required this.ipAddress,
    required this.lastActive,
    required this.isCurrent,
    required this.deviceIcon,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isCurrent ? Border.all(color: ClayColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isCurrent ? ClayColors.primary : Colors.grey).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              deviceIcon,
              color: isCurrent ? ClayColors.primary : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        deviceInfo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: ClayColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ClayColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Perangkat ini',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ClayColors.green,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'IP: $ipAddress',
                  style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Aktif: $lastActive',
                  style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary),
                ),
              ],
            ),
          ),
          if (onRevoke != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRevoke,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ClayColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout, color: ClayColors.error, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

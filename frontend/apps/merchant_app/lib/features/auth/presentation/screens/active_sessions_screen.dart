import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/session_provider.dart';

class ActiveSessionsScreen extends ConsumerStatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  ConsumerState<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends ConsumerState<ActiveSessionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sessionProvider.notifier).loadSessions();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$min';
    } catch (_) {
      return dateStr;
    }
  }

  IconData _deviceIcon(String? userAgent) {
    if (userAgent == null) return Icons.devices_other;
    final ua = userAgent.toLowerCase();
    if (ua.contains('iphone') || ua.contains('android') || ua.contains('mobile')) {
      return Icons.phone_android;
    }
    if (ua.contains('ipad') || ua.contains('tablet')) {
      return Icons.tablet_mac;
    }
    if (ua.contains('macintosh') || ua.contains('windows') || ua.contains('linux')) {
      return Icons.computer;
    }
    return Icons.devices_other;
  }

  String _parseUserAgent(String? userAgent) {
    if (userAgent == null || userAgent.isEmpty) return 'Perangkat Tidak Dikenal';
    
    // Quick parse standard user agents to look pretty
    final ua = userAgent.toLowerCase();
    if (ua.contains('iphone')) {
      return 'Apple iPhone';
    }
    if (ua.contains('ipad')) {
      return 'Apple iPad';
    }
    if (ua.contains('android')) {
      // Find model or just return Android Device
      return 'Perangkat Android';
    }
    if (ua.contains('windows')) {
      return 'Windows PC';
    }
    if (ua.contains('macintosh')) {
      return 'Apple Mac';
    }
    if (ua.contains('linux')) {
      return 'Linux PC';
    }

    return userAgent.length > 35 ? '${userAgent.substring(0, 35)}...' : userAgent;
  }

  Future<void> _confirmRevokeSession(String sessionId, String deviceName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Putuskan Sesi?'),
        content: Text('Apakah Anda ingin mengeluarkan akun Anda dari perangkat "$deviceName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluarkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(sessionProvider.notifier).revokeSession(sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Sesi berhasil diputuskan' : 'Gagal memutuskan sesi'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmRevokeAllOthers() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluarkan Semua Perangkat?'),
        content: const Text(
          'Tindakan ini akan memutuskan akses akun Anda di semua perangkat lain kecuali perangkat yang Anda gunakan saat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluarkan Semua'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(sessionProvider.notifier).revokeAllOtherSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? 'Berhasil mengeluarkan seluruh perangkat lain' 
                  : 'Gagal mengeluarkan perangkat lain',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        title: const Text('Sesi Login Aktif'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        color: ClayColors.primaryDark,
        onRefresh: () => ref.read(sessionProvider.notifier).loadSessions(),
        child: _buildBody(state),
      ),
      bottomNavigationBar: state.sessions.length > 1
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ClayButton(
                  label: 'Keluarkan Semua Perangkat Lain',
                  backgroundColor: ClayColors.error,
                  onPressed: state.isLoading ? null : _confirmRevokeAllOthers,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(SessionState state) {
    if (state.isLoading && state.sessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.read(sessionProvider.notifier).loadSessions(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.devices_other, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Tidak ada sesi aktif',
              style: TextStyle(color: ClayColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.sessions.length,
      itemBuilder: (context, index) {
        final s = state.sessions[index];
        final isCurrent = s['is_current'] == true;
        final rawUa = s['user_agent']?.toString();
        final deviceName = _parseUserAgent(rawUa);
        final ipAddress = s['ip_address']?.toString() ?? 'IP Tidak Diketahui';
        final createdAt = _formatDate(s['created_at']?.toString());
        final deviceIcon = _deviceIcon(rawUa);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isCurrent ? ClayColors.primary : ClayColors.border,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCurrent 
                        ? ClayColors.primary.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    deviceIcon,
                    color: isCurrent ? ClayColors.primaryDark : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              deviceName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: ClayColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Sesi Ini',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'IP: $ipAddress',
                        style: const TextStyle(
                          color: ClayColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Masuk sejak: $createdAt',
                        style: const TextStyle(
                          color: ClayColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions (Revoke session button)
                if (!isCurrent)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: state.isLoading 
                        ? null 
                        : () => _confirmRevokeSession(s['id']?.toString() ?? '', deviceName),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

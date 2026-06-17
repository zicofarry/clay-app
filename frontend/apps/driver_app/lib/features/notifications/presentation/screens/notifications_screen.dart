import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets.dart';

final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final response = await ClayApi.instance.dio.get('/notifications');
    final data = response.data as Map<String, dynamic>;
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    final list = inner['data'] as List<dynamic>? ?? inner['notifications'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final notifications = notificationsAsync.valueOrNull ?? [];

    Color _typeColor(String type) {
      switch (type) {
        case 'order_assigned':
        case 'order_completed':
          return ClayColors.green;
        case 'payment':
        case 'settlement':
          return ClayColors.primary;
        case 'promotion':
          return ClayColors.warning;
        default:
          return ClayColors.textSecondary;
      }
    }

    IconData _typeIcon(String type) {
      switch (type) {
        case 'order_assigned':
          return Icons.assignment;
        case 'order_completed':
          return Icons.check_circle;
        case 'payment':
        case 'settlement':
          return Icons.account_balance_wallet;
        case 'promotion':
          return Icons.local_offer;
        default:
          return Icons.notifications_outlined;
      }
    }

    String _parseTitle(String eventType, String payload) {
      try {
        final p = jsonDecode(payload) as Map<String, dynamic>;
        return p['title']?.toString() ?? _humanizeType(eventType);
      } catch (_) {
        return _humanizeType(eventType);
      }
    }

    String _parseDescription(String payload) {
      try {
        final p = jsonDecode(payload) as Map<String, dynamic>;
        return p['body']?.toString() ?? p['description']?.toString() ?? p['message']?.toString() ?? payload;
      } catch (_) {
        return payload;
      }
    }

    String _formatTime(String? sentAt) {
      if (sentAt == null) return '-';
      try {
        final dt = DateTime.parse(sentAt);
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inMinutes < 1) return 'Baru saja';
        if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
        if (diff.inHours < 24) return '${diff.inHours} jam lalu';
        return '${diff.inDays} hari lalu';
      } catch (_) {
        return sentAt;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: Container(width: 40, height: 40, decoration: softShadow(), child: const Center(child: Icon(Icons.arrow_back, size: 20, color: ClayColors.textPrimary))),
                  ),
                  const SizedBox(width: 12),
                  const Text('Notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: notificationsAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 48, color: ClayColors.textSecondary.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              const Text('Tidak ada notifikasi', style: TextStyle(color: ClayColors.textSecondary, fontSize: 14)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final n = notifications[index];
                            final eventType = n['event_type']?.toString() ?? 'system';
                            final payload = n['payload']?.toString() ?? '{}';
                            final sentAt = n['sent_at']?.toString();
                            final status = n['status']?.toString() ?? 'sent';
                            final isUnread = status == 'pending' || status == 'sent';

                            final title = _parseTitle(eventType, payload);
                            final description = _parseDescription(payload);
                            final time = _formatTime(sentAt);
                            final color = _typeColor(eventType);
                            final icon = _typeIcon(eventType);

                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: Text(title),
                                    content: Text(description),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Tutup', style: TextStyle(color: ClayColors.primary)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: ClayColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isUnread ? const Border(left: BorderSide(color: ClayColors.primary, width: 4)) : null,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                                      child: Icon(icon, size: 18, color: color),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: Text(title, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, color: ClayColors.textPrimary))),
                                              if (isUnread)
                                                Container(width: 8, height: 8, decoration: const BoxDecoration(color: ClayColors.primary, shape: BoxShape.circle)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(description, style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 6),
                                          Text(time, style: const TextStyle(fontSize: 10, color: ClayColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

String _humanizeType(String type) {
  return type.replaceAll('_', ' ').splitMapJoin(
    RegExp(r'\w+'),
    onMatch: (m) => '${m.group(0)![0].toUpperCase()}${m.group(0)!.substring(1)}',
  );
}

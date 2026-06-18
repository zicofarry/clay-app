import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/chat_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(chatRoomsProvider.notifier).loadRooms());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = ref.read(chatRoomsProvider);
    if (!state.hasLoaded && !state.isLoading) {
      Future.microtask(() => ref.read(chatRoomsProvider.notifier).loadRooms());
    }
  }

  String _formatOrderType(String? type) {
    switch (type) {
      case 'ride':
        return 'ClayRide';
      case 'delivery':
        return 'ClaySend';
      case 'food':
        return 'ClayFood';
      case 'waste':
        return 'ClayWaste';
      case 'car':
        return 'ClayCar';
      case 'pet':
        return 'ClayPet';
      case 'care':
        return 'ClayCare';
      case 'direct':
        return 'Direct Chat';
      default:
        return type ?? 'Chat';
    }
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'now';
      if (diff.inHours < 1) return '${diff.inMinutes}m';
      if (diff.inDays < 1) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }

  IconData _iconForOrderType(String? type) {
    switch (type) {
      case 'ride':
        return Icons.directions_car;
      case 'delivery':
        return Icons.local_shipping;
      case 'food':
        return Icons.restaurant;
      case 'waste':
        return Icons.delete_outline;
      case 'direct':
        return Icons.person;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  void _showNewChatDialog() {
    final phoneC = TextEditingController();
    bool isCreating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chat Baru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Masukkan nomor telepon orang yang ingin kamu chat',
                    style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ClayColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, size: 20, color: ClayColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: phoneC,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration.collapsed(
                              hintText: '+6281234567890',
                              hintStyle: TextStyle(color: ClayColors.textSecondary, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isCreating
                          ? null
                          : () async {
                              final phone = phoneC.text.trim();
                              if (phone.isEmpty) return;
                              setSheetState(() => isCreating = true);
                              final result = await ref
                                  .read(chatRoomsProvider.notifier)
                                  .createDirectChat(phone);
                              if (!ctx.mounted) return;
                              Navigator.of(ctx).pop();
                              if (result != null && context.mounted) {
                                context.push(
                                  '/chat/${result['room_id']}',
                                  extra: result['recipient_name'],
                                );
                              } else {
                                final error = ref.read(chatRoomsProvider).error;
                                if (mounted && error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error), duration: const Duration(seconds: 3)),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ClayColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Mulai Chat',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: GestureDetector(
        onTap: _showNewChatDialog,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ClayColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ClayColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ClayColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => ref.read(chatRoomsProvider.notifier).refresh(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.refresh, size: 20, color: ClayColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isLoading && state.rooms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.rooms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: ClayColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              state.error!,
                              style: const TextStyle(color: ClayColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => ref.read(chatRoomsProvider.notifier).refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : state.rooms.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: ClayColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(36),
                                  ),
                                  child: const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 36,
                                    color: ClayColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Belum ada chat',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: ClayColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Chat akan muncul saat kamu order ride atau delivery',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ClayColors.textSecondary.withValues(alpha: 0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(chatRoomsProvider.notifier).loadRooms();
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: state.rooms.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                indent: 76,
                                color: Colors.grey.shade200,
                              ),
                              itemBuilder: (_, i) {
                                final room = state.rooms[i];
                                final lastMsg = room['last_message'] as Map<String, dynamic>?;
                                final unread = (room['unread_count'] as num?)?.toInt() ?? 0;
                                final orderType = room['order_type']?.toString() ?? '';
                                final status = room['status']?.toString() ?? '';
                                final roomId = room['id']?.toString() ?? '';
                                final displayName = room['_display_name']?.toString();

                                return ListTile(
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: status == 'active'
                                          ? ClayColors.primary.withValues(alpha: 0.12)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _iconForOrderType(orderType),
                                      size: 22,
                                      color: status == 'active' ? ClayColors.primary : ClayColors.textSecondary,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          (orderType == 'direct' && displayName != null && displayName.isNotEmpty)
                                              ? displayName
                                              : _formatOrderType(orderType),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: ClayColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (lastMsg != null)
                                        Text(
                                          _formatTime(lastMsg['created_at']?.toString()),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: ClayColors.textSecondary.withValues(alpha: 0.7),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            lastMsg?['content']?.toString() ?? 'Belum ada pesan',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: unread > 0
                                                  ? ClayColors.textPrimary
                                                  : ClayColors.textSecondary,
                                              fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (unread > 0) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: ClayColors.primary,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              unread.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    final name = (orderType == 'direct' && displayName != null && displayName.isNotEmpty)
                                        ? displayName
                                        : null;
                                    context.push('/chat/$roomId', extra: name);
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

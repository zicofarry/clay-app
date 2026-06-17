import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';
import '../../../../shared/widgets.dart';

final chatMessagesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final response = await ClayApi.instance.dio.get('/chat/messages');
    final data = response.data as Map<String, dynamic>;
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    final list = inner['data'] as List<dynamic>? ?? inner['messages'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputC = TextEditingController();
  final _scrollC = ScrollController();
  bool _sending = false;

  final _quickReplies = [
    'Saya sudah sampai',
    'Mohon tunggu sebentar',
    'Baik, terima kasih',
    'Di depan gedung mana?',
  ];

  @override
  void dispose() {
    _inputC.dispose();
    _scrollC.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollC.hasClients) {
        _scrollC.animateTo(
          _scrollC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ClayApi.instance.dio.post('/chat/messages', data: {
        'content': text.trim(),
        'recipient_id': null,
      });
      _inputC.clear();
      ref.invalidate(chatMessagesProvider);
      _scrollToBottom();
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map
          ? (data['message']?.toString() ?? e.message ?? 'Gagal mengirim pesan')
          : (e.message ?? 'Gagal mengirim pesan');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: $e'), duration: const Duration(seconds: 2)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider);
    final messages = messagesAsync.valueOrNull ?? [];
    final chatAvailable = messagesAsync.valueOrNull != null && messages.isNotEmpty;
    final triedLoading = !messagesAsync.isLoading && messagesAsync.valueOrNull != null;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            decoration: BoxDecoration(
              color: ClayColors.card,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ClayColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, size: 18, color: ClayColors.primary),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chat',
                      style: TextStyle(fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                    ),
                    Text(
                      chatAvailable ? 'Aktif' : 'Belum tersedia',
                      style: const TextStyle(fontSize: 11, color: ClayColors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages or empty state
          Expanded(
            child: messagesAsync.isLoading
                ? const Center(child: CircularProgressIndicator())
                : !triedLoading || messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: ClayColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                size: 32,
                                color: ClayColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Fitur chat akan segera tersedia',
                              style: TextStyle(
                                color: ClayColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Anda bisa menghubungi penumpang melalui telepon untuk saat ini',
                              style: TextStyle(
                                color: ClayColors.textSecondary.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollC,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final m = messages[i];
                          final isSent = m['is_sent'] == true ||
                              m['sender_type']?.toString() == 'driver' ||
                              m['direction']?.toString() == 'outbound';
                          final text = m['content']?.toString() ?? m['message']?.toString() ?? '';
                          final time = _formatTime(
                            m['created_at']?.toString() ?? m['timestamp']?.toString(),
                          );
                          final status = m['status']?.toString();
                          final isRead = status == 'read';

                          return Align(
                            alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSent ? ClayColors.primary : ClayColors.card,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isSent ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isSent ? Radius.zero : const Radius.circular(16),
                                ),
                                boxShadow: isSent
                                    ? null
                                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                              ),
                              child: Column(
                                crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSent ? Colors.white : ClayColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        time,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSent
                                              ? Colors.white.withValues(alpha: 0.7)
                                              : ClayColors.textSecondary,
                                        ),
                                      ),
                                      if (isSent && status != null) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          isRead ? Icons.done_all : Icons.done,
                                          size: 14,
                                          color: Colors.white.withValues(alpha: 0.7),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Quick replies (placeholder)
          if (chatAvailable)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _sendMessage(_quickReplies[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ClayColors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Text(
                      _quickReplies[i],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: ClayColors.card,
              border: Border(top: BorderSide(color: ClayColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: ClayColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _inputC,
                      enabled: chatAvailable,
                      decoration: InputDecoration.collapsed(
                        hintText: chatAvailable ? 'Ketik pesan...' : 'Chat belum tersedia',
                        hintStyle: const TextStyle(color: ClayColors.textSecondary, fontSize: 13),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: chatAvailable ? () => _sendMessage(_inputC.text) : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: chatAvailable ? ClayColors.primary : ClayColors.muted,
                      shape: BoxShape.circle,
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(
                            Icons.send,
                            size: 16,
                            color: chatAvailable ? Colors.white : ClayColors.textSecondary,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

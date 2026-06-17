import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = [
    _ChatMessage('customer', 'Halo Pak, saya sudah di depan lobby ya', '14:25', null),
    _ChatMessage('driver', 'Baik Bu, saya sedang dalam perjalanan. Sekitar 3 menit lagi sampai.', '14:26', 'read'),
    _ChatMessage('customer', 'Oke, saya pakai baju merah ya', '14:26', null),
    _ChatMessage('driver', 'Siap Bu, motor saya Honda Vario putih dengan plat B 1234 XYZ', '14:27', 'read'),
  ];
  final _inputC = TextEditingController();
  final _scrollC = ScrollController();

  final _quickReplies = ['Saya sudah sampai', 'Mohon tunggu sebentar', 'Baik, terima kasih', 'Di depan gedung mana?'];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage('driver', text, _now(), 'sent'));
    });
    _inputC.clear();
    Future.delayed(const Duration(milliseconds: 100), () => _scrollC.animateTo(_scrollC.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut));
  }

  String _now() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _inputC.dispose();
    _scrollC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            decoration: BoxDecoration(color: ClayColors.card, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
            child: Row(
              children: [
                GestureDetector(onTap: () {
                  if (Navigator.canPop(context)) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                }, child: Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.background, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.arrow_back, size: 18, color: ClayColors.textPrimary))),
                const SizedBox(width: 12),
                ClipRRect(borderRadius: BorderRadius.circular(18), child: CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop&crop=face',
                  width: 36, height: 36, fit: BoxFit.cover, placeholder: (_, __) => Container(width: 36, height: 36, color: ClayColors.muted), errorWidget: (_, __, ___) => Container(width: 36, height: 36, color: ClayColors.muted, child: const Icon(Icons.person)),
                )),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Sarah Putri', style: TextStyle(fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                  const Text('Penumpang', style: TextStyle(fontSize: 11, color: ClayColors.green)),
                ]),
                const Spacer(),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memanggil Sarah Putri...'), duration: Duration(seconds: 1))),
                  child: Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.background, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.phone_in_talk, size: 16, color: ClayColors.primary)),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollC,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isDriver = m.sender == 'driver';
                return Align(
                  alignment: isDriver ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDriver ? ClayColors.primary : ClayColors.card,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                        bottomLeft: isDriver ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isDriver ? Radius.zero : const Radius.circular(16),
                      ),
                      boxShadow: isDriver ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: isDriver ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(m.text, style: TextStyle(fontSize: 13, color: isDriver ? Colors.white : ClayColors.textPrimary)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(m.time, style: TextStyle(fontSize: 10, color: isDriver ? Colors.white.withValues(alpha: 0.7) : ClayColors.textSecondary)),
                            if (isDriver && m.status != null) ...[
                              const SizedBox(width: 4),
                              Icon(m.status == 'read' ? Icons.done_all : Icons.done, size: 14, color: Colors.white.withValues(alpha: 0.7)),
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

          // Quick replies
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
                  decoration: BoxDecoration(color: ClayColors.card, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: Text(_quickReplies[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ClayColors.textPrimary)),
                ),
              ),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(color: ClayColors.card, border: Border(top: BorderSide(color: ClayColors.divider))),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih gambar dari galeri...'), duration: Duration(seconds: 1))),
                  child: Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.background, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.image_outlined, size: 16, color: ClayColors.textSecondary)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 40, padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: ClayColors.background, borderRadius: BorderRadius.circular(20)),
                    child: TextField(
                      controller: _inputC,
                      decoration: const InputDecoration.collapsed(hintText: 'Ketik pesan...', hintStyle: TextStyle(color: ClayColors.textSecondary, fontSize: 13)),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_inputC.text),
                  child: Container(width: 36, height: 36, decoration: const BoxDecoration(color: ClayColors.primary, shape: BoxShape.circle), child: const Icon(Icons.send, size: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String sender, text, time;
  final String? status;
  _ChatMessage(this.sender, this.text, this.time, this.status);
}

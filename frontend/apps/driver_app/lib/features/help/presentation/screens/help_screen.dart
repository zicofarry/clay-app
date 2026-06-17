import 'package:flutter/material.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedFaq;
  final _searchC = TextEditingController();

  final _faqs = [
    ('Bagaimana cara mencairkan pendapatan?', 'Anda bisa mencairkan pendapatan melalui menu Pendapatan > Cairkan Dana. Minimal penarikan adalah Rp 50.000 dan akan diproses dalam 1x24 jam ke rekening yang terdaftar.'),
    ('Kenapa saya tidak mendapat order?', 'Pastikan status Anda sudah Online, GPS aktif, dan berada di area yang memiliki permintaan. Coba pergi ke area yang ditandai "Permintaan Tinggi" di peta.'),
    ('Bagaimana jika penumpang tidak muncul?', 'Tunggu minimal 5 menit di titik jemput, hubungi penumpang melalui chat atau telepon. Jika tidak ada respons, Anda bisa membatalkan perjalanan tanpa penalti.'),
    ('Bagaimana cara update dokumen?', 'Buka Profil > Dokumen, pilih dokumen yang ingin diperbarui. Upload foto dokumen dengan jelas dan tunggu verifikasi dalam 1-3 hari kerja.'),
  ];

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
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
                  const Text('Bantuan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Search
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: ClayColors.card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20, color: ClayColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchC,
                            decoration: const InputDecoration.collapsed(hintText: 'Cari pertanyaan...', hintStyle: TextStyle(color: ClayColors.textSecondary)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: _QuickHelpCard(
                          icon: Icons.chat_bubble_outline,
                          label: 'Live Chat',
                          sub: '24/7 Support',
                          color: ClayColors.primary,
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Menghubungkan ke Live Chat...'), duration: Duration(seconds: 1)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickHelpCard(
                          icon: Icons.phone_in_talk,
                          label: 'Telepon',
                          sub: '021-123-456',
                          color: ClayColors.green,
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Memanggil 021-123-456...'), duration: Duration(seconds: 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Categories
                  const Text('Kategori Bantuan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.directions_car,
                          label: 'Perjalanan',
                          count: '12 artikel',
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kategori bantuan Perjalanan dibuka...'), duration: Duration(seconds: 1)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.credit_card,
                          label: 'Pembayaran',
                          count: '8 artikel',
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kategori bantuan Pembayaran dibuka...'), duration: Duration(seconds: 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.shield,
                          label: 'Keamanan',
                          count: '6 artikel',
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kategori bantuan Keamanan dibuka...'), duration: Duration(seconds: 1)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.description,
                          label: 'Dokumen',
                          count: '5 artikel',
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kategori bantuan Dokumen dibuka...'), duration: Duration(seconds: 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // FAQs
                  const Text('Pertanyaan Umum', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                  const SizedBox(height: 8),
                  ..._faqs.asMap().entries.map((entry) {
                    final i = entry.key;
                    final faq = entry.value;
                    final expanded = _expandedFaq == i;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: ClayColors.card, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _expandedFaq = expanded ? null : i),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(width: 28, height: 28, decoration: BoxDecoration(color: ClayColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.help_outline, size: 16, color: ClayColors.primary)),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(faq.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textPrimary))),
                                  AnimatedRotation(
                                    turns: expanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: const Icon(Icons.expand_more, size: 20, color: ClayColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
                              child: Text(faq.$2, style: const TextStyle(fontSize: 13, color: ClayColors.textSecondary, height: 1.5)),
                            ),
                            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Contact support
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: ClayColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text('Masih butuh bantuan?', style: TextStyle(fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Tim support kami siap membantu Anda 24/7', style: TextStyle(fontSize: 12, color: ClayColors.textSecondary)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Menghubungi Tim Support...'), duration: Duration(seconds: 1)),
                          ),
                          child: Container(
                            width: double.infinity, height: 44,
                            decoration: BoxDecoration(color: ClayColors.primary, borderRadius: BorderRadius.circular(12)),
                            child: const Center(child: Text('Hubungi Support', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white))),
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

class _QuickHelpCard extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback? onTap;
  const _QuickHelpCard({required this.icon, required this.label, required this.sub, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: softShadow(),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
              Text(sub, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label, count;
  final VoidCallback? onTap;
  const _CategoryCard({required this.icon, required this.label, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: softShadow(),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.muted, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: ClayColors.textSecondary)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: ClayColors.textPrimary)),
              Text(count, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
            ])),
            const Icon(Icons.chevron_right, size: 16, color: ClayColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

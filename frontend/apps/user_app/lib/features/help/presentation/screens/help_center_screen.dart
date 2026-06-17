import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clay_ui/clay_ui.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faq = <_FaqItem>[
    _FaqItem(
      'Bagaimana cara memesan makanan?',
      'Pilih menu Makanan di beranda, pilih merchant favoritmu, tambahkan ke keranjang, lalu checkout. Pembayaran bisa dilakukan lewat e-wallet, transfer, atau COD.',
    ),
    _FaqItem(
      'Bagaimana cara memesan ride?',
      'Pilih menu Ride, masukkan lokasi jemput dan tujuan, pilih jenis kendaraan, lalu konfirmasi. Driver terdekat akan segera menerima pesananmu.',
    ),
    _FaqItem(
      'Bagaimana cara mengisi saldo wallet?',
      'Buka halaman Wallet (tap kartu saldo di beranda atau tab Wallet di bawah), tekan tombol "Top Up", pilih nominal, dan lanjutkan pembayaran.',
    ),
    _FaqItem(
      'Bagaimana cara transfer saldo ke pengguna lain?',
      'Di halaman Wallet, tekan tombol "Transfer", masukkan nomor HP penerima, nominal, dan catatan opsional. Minimal transfer Rp1.000.',
    ),
    _FaqItem(
      'Apa yang harus dilakukan jika pesanan tidak sampai?',
      'Buka riwayat pesanan, pilih pesanan bermasalah, lalu tekan "Lapor masalah". Tim kami akan menindaklanjuti dalam 1x24 jam.',
    ),
    _FaqItem(
      'Bagaimana cara mengubah alamat utama?',
      'Buka Akun → Alamat Tersimpan, lalu tekan ikon bintang di alamat yang ingin dijadikan utama.',
    ),
    _FaqItem(
      'Apakah data saya aman?',
      'Data pribadi kamu dienkripsi dan tidak dibagikan ke pihak ketiga tanpa izin. Baca lengkapnya di halaman Tentang → Kebijakan Privasi.',
    ),
  ];

  Future<void> _email(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'help@clay.example.com',
      query: 'subject=Bantuan%20Clay',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Email: help@clay.example.com')));
    }
  }

  Future<void> _whatsapp(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/6281234567890?text=Halo%20Clay%2C%20saya%20butuh%20bantuan');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('WA: +62 812-3456-7890')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ClayColors.primary, ClayColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.support_agent, color: Colors.white, size: 28),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Butuh bantuan?',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ContactChip(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        onTap: () => _email(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ContactChip(
                        icon: Icons.chat_bubble_outline,
                        label: 'WhatsApp',
                        onTap: () => _whatsapp(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pertanyaan Umum',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          for (final faq in _faq)
            _FaqTile(item: faq),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Jam operasional: Senin–Minggu, 07:00 – 22:00 WIB',
              style: TextStyle(fontSize: 11, color: ClayColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContactChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ClayColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ClayColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.help_outline, color: ClayColors.primary, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (_open) ...[
                const SizedBox(height: 10),
                Text(
                  widget.item.answer,
                  style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

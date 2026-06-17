import 'package:flutter/material.dart';
import 'package:clay_ui/clay_ui.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  static const List<_PaymentData> _items = [
    _PaymentData('BCA Virtual Account', 'Transfer bank otomatis', Icons.account_balance, Color(0xFF0060AF)),
    _PaymentData('Mandiri Virtual Account', 'Transfer bank otomatis', Icons.account_balance_outlined, Color(0xFF003D79)),
    _PaymentData('BNI Virtual Account', 'Transfer bank otomatis', Icons.account_balance_wallet_outlined, Color(0xFFEC6726)),
    _PaymentData('GoPay', 'E-wallet terintegrasi', Icons.wallet, Color(0xFF00AA13)),
    _PaymentData('OVO', 'E-wallet', Icons.wallet_outlined, Color(0xFF4C3494)),
    _PaymentData('ShopeePay', 'E-wallet', Icons.wallet_giftcard_outlined, Color(0xFFEE4D2D)),
    _PaymentData('DANA', 'E-wallet', Icons.account_balance_wallet, Color(0xFF118EEA)),
    _PaymentData('QRIS', 'Scan QR universal', Icons.qr_code_2, Color(0xFF1A1A1A)),
  ];

  void _showComingSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('$name akan segera tersedia'),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ClayColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ClayColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: ClayColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Integrasi payment gateway sedang dalam pengerjaan.',
                    style: TextStyle(fontSize: 12, color: ClayColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pilih metode pembayaran',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Semua metode di bawah akan aktif setelah verifikasi akun.',
            style: TextStyle(fontSize: 12, color: ClayColors.textSecondary),
          ),
          const SizedBox(height: 12),
          for (final item in _items)
            _PaymentTile(
              data: item,
              onTap: () => _showComingSoon(context, item.title),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showComingSoon(context, 'Tambah kartu'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kartu Kredit / Debit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ClayColors.primary,
                side: const BorderSide(color: ClayColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _PaymentData(this.title, this.subtitle, this.icon, this.color);
}

class _PaymentTile extends StatelessWidget {
  final _PaymentData data;
  final VoidCallback onTap;
  const _PaymentTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(data.icon, color: data.color, size: 22),
        ),
        title: Text(data.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(data.subtitle, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
    );
  }
}

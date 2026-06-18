import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/wallet_provider.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  final _amountController = TextEditingController();
  String _selectedChannel = 'bank_transfer';
  final _formKey = GlobalKey<FormState>();

  static const _channels = [
    {'value': 'bank_transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance_outlined},
    {'value': 'credit_card', 'label': 'Kartu Kredit', 'icon': Icons.credit_card},
    {'value': 'gopay', 'label': 'GoPay', 'icon': Icons.phone_android},
    {'value': 'ovo', 'label': 'OVO', 'icon': Icons.phone_android},
    {'value': 'dana', 'label': 'DANA', 'icon': Icons.phone_android},
  ];

  static const _quickAmounts = [50000, 100000, 200000, 500000, 1000000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatCurrency(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join('')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = _amountController.text.replaceAll('.', '').trim();
    final amount = int.tryParse(rawAmount) ?? 0;

    final result = await ref.read(walletProvider.notifier).topUp(
          amount: amount,
          channel: _selectedChannel,
        );

    if (!mounted) return;

    if (result != null) {
      final redirectUrl = result['redirect_url']?.toString();
      final txId = result['transaction_id']?.toString() ?? '';

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Top Up Dimulai'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nominal: ${_formatCurrency(amount)}'),
              const SizedBox(height: 4),
              Text('ID Transaksi: ${txId.length >= 8 ? txId.substring(0, 8).toUpperCase() : txId}'),
              if (redirectUrl != null && redirectUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Selesaikan pembayaran di halaman berikut:',
                  style: TextStyle(color: ClayColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  redirectUrl,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } else {
      final err = ref.read(walletProvider).actionError;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: Colors.red),
        );
        ref.read(walletProvider.notifier).clearActionError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final isLoading = walletState.isActionLoading;

    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        title: const Text('Top Up Clay Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF97C5F5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.white),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo saat ini', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          _formatCurrency(walletState.balance),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount field
              const Text(
                'Nominal Top Up',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 100000',
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ClayColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ClayColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ClayColors.primary, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Nominal wajib diisi';
                  final num = int.tryParse(val.replaceAll('.', '')) ?? 0;
                  if (num < 10000) return 'Minimal top up Rp 10.000';
                  if (num > 10000000) return 'Maksimal top up Rp 10.000.000';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Quick amount buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts.map((amt) {
                  return OutlinedButton(
                    onPressed: () {
                      _amountController.text = amt.toString();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ClayColors.primaryDark,
                      side: const BorderSide(color: ClayColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(_formatCurrency(amt), style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Channel selection
              const Text(
                'Metode Pembayaran',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 12),
              ..._channels.map((ch) {
                final isSelected = _selectedChannel == ch['value'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedChannel = ch['value'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? ClayColors.primary.withValues(alpha: 0.08) : Colors.white,
                      border: Border.all(
                        color: isSelected ? ClayColors.primary : ClayColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          ch['icon'] as IconData,
                          color: isSelected ? ClayColors.primaryDark : ClayColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          ch['label'] as String,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? ClayColors.primaryDark : ClayColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: ClayColors.primary, size: 20),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ClayColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Lanjutkan Top Up',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

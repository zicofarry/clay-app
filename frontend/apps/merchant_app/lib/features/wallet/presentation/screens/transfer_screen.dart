import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/wallet_provider.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _notesController.dispose();
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

  String _normalizePhone(String raw) {
    var phone = raw.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (phone.startsWith('0')) {
      phone = '+62${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      phone = '+62$phone';
    }
    return phone;
  }

  Future<void> _showConfirmDialog() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _normalizePhone(_phoneController.text);
    final amount = int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    final notes = _notesController.text.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Transfer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ConfirmRow(label: 'Penerima', value: phone),
            const SizedBox(height: 8),
            _ConfirmRow(label: 'Nominal', value: _formatCurrency(amount)),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              _ConfirmRow(label: 'Catatan', value: notes),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ClayColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _doTransfer(phone, amount, notes.isNotEmpty ? notes : null);
    }
  }

  Future<void> _doTransfer(String phone, int amount, String? notes) async {
    final result = await ref.read(walletProvider.notifier).transfer(
          recipientPhone: phone,
          amount: amount,
          notes: notes,
        );

    if (!mounted) return;

    if (result != null) {
      final balanceAfter = (result['sender_balance_after'] as num?)?.toInt();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Transfer Berhasil'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ConfirmRow(label: 'Ke', value: phone),
              const SizedBox(height: 6),
              _ConfirmRow(label: 'Nominal', value: _formatCurrency(amount)),
              if (balanceAfter != null) ...[
                const SizedBox(height: 6),
                _ConfirmRow(label: 'Saldo tersisa', value: _formatCurrency(balanceAfter)),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ClayColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
    } else {
      final err = ref.read(walletProvider).actionError;
      if (err != null && mounted) {
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
        title: const Text('Transfer Saldo'),
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
              // Balance info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF97C5F5)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.white),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo tersedia', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          _formatCurrency(walletState.balance),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Phone field
              const Text('Nomor HP Penerima', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '08xx / +628xx',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ClayColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ClayColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ClayColors.primary, width: 2)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Nomor HP wajib diisi';
                  final normalized = _normalizePhone(val);
                  final re = RegExp(r'^\+62[0-9]{9,12}$');
                  if (!re.hasMatch(normalized)) return 'Format nomor tidak valid (contoh: 0812xxxxxxxx)';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount field
              const Text('Nominal Transfer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Minimal Rp 1.000',
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ClayColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ClayColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ClayColors.primary, width: 2)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Nominal wajib diisi';
                  final amt = int.tryParse(val.replaceAll('.', '')) ?? 0;
                  if (amt < 1000) return 'Minimal transfer Rp 1.000';
                  if (amt > walletState.balance) return 'Saldo tidak mencukupi';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes field
              const Text('Catatan (Opsional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan untuk penerima...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ClayColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ClayColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ClayColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _showConfirmDialog,
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
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Lanjutkan Transfer',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(color: ClayColors.textSecondary, fontSize: 13)),
        ),
        const Text(': ', style: TextStyle(color: ClayColors.textSecondary)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

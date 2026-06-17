import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/wallet_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletStateProvider.notifier).loadWallet();
      ref.read(walletStateProvider.notifier).loadTransactions();
    });
  }

  String _formatCurrency(int amount) {
    final str = amount.abs().toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dompet')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(walletStateProvider.notifier).clearError();
          await Future.wait([
            ref.read(walletStateProvider.notifier).loadWallet(),
            ref.read(walletStateProvider.notifier).loadTransactions(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ClayColors.primary, ClayColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_formatCurrency(state.balance)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        _ActionChip(icon: Icons.add, label: 'Top Up', onTap: _showTopUpDialog),
                        const SizedBox(width: 12),
                        _ActionChip(icon: Icons.swap_horiz, label: 'Transfer', onTap: _showTransferDialog),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ClayColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: ClayColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.error!, style: const TextStyle(color: ClayColors.error, fontSize: 13))),
                  ],
                ),
              ),
            ],
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Riwayat Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (state.transactions.isNotEmpty)
                  Text('${state.transactions.length} transaksi', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            if (state.transactions.isEmpty && !state.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Belum ada transaksi', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
              )
            else
              ...state.transactions.map((t) => _buildTransactionCard(t)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> t) {
    final amount = (t['amount'] as num?)?.toInt() ?? 0;
    final isCredit = amount > 0;
    final desc = t['description']?.toString() ?? 'Transaksi';
    final date = t['created_at']?.toString() ?? '';
    final displayDate = date.isNotEmpty ? _formatDate(date) : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(desc, style: const TextStyle(fontSize: 13)),
        subtitle: Text(displayDate, style: const TextStyle(fontSize: 11)),
        trailing: Text(
          '${isCredit ? '+' : ''}Rp ${_formatCurrency(amount)}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  void _showTopUpDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Top Up'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: 'Rp ',
            hintText: 'Masukkan jumlah',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                ref.read(walletStateProvider.notifier).topUp(amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Top Up'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog() {
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transfer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                hintText: '+6281234567890',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: 'Masukkan jumlah',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              final amount = int.tryParse(amountController.text) ?? 0;
              if (phone.isEmpty || amount < 1000) return;
              Navigator.pop(ctx);
              final success = await ref.read(walletStateProvider.notifier).transfer(
                recipientPhone: phone,
                amount: amount,
                note: noteController.text.trim(),
              );
              if (mounted) {
                final s = ref.read(walletStateProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Transfer berhasil' : (s.error ?? 'Transfer gagal')),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

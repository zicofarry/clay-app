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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dompet')),
      body: ListView(
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
                  'Rp ${state.balance}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _ActionChip(icon: Icons.add, label: 'Top Up', onTap: _showTopUpDialog),
                    const SizedBox(width: 12),
                    _ActionChip(icon: Icons.swap_horiz, label: 'Transfer', onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Riwayat Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${state.transactions.length} transaksi', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ...state.transactions.map((t) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (t['amount'] as int) > 0
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                child: Icon(
                  (t['amount'] as int) > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  color: (t['amount'] as int) > 0 ? Colors.green : Colors.red,
                ),
              ),
              title: Text(t['desc'], style: const TextStyle(fontSize: 13)),
              subtitle: Text(t['date'], style: const TextStyle(fontSize: 11)),
              trailing: Text(
                '${(t['amount'] as int) > 0 ? '+' : ''}Rp ${t['amount']}'.replaceAll('-', ''),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: (t['amount'] as int) > 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
          )),
        ],
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
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../auth/presentation/providers/merchant_auth_provider.dart';

final _isOpenProvider = StateProvider<bool>((ref) => true);

class MerchantHomeScreen extends ConsumerWidget {
  const MerchantHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchant = ref.watch(merchantAuthProvider).merchant;
    final isOpen = ref.watch(_isOpenProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${merchant?['name'] ?? 'Merchant'}'),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => context.push('/report')),
          IconButton(icon: const Icon(Icons.person), onPressed: () => context.push('/profile')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [ClayColors.primary, ClayColors.primaryDark]), borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Selamat datang, ${merchant?['owner'] ?? 'Merchant'}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(merchant?['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${merchant?['rating'] ?? 0}', style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 16),
                const Icon(Icons.receipt_long, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text('${merchant?['total_orders'] ?? 0} pesanan', style: const TextStyle(color: Colors.white70)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(color: ClayColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: ClayColors.divider)),
            child: Row(children: [
              Icon(isOpen ? Icons.check_circle : Icons.cancel, color: isOpen ? Colors.green : Colors.red),
              const SizedBox(width: 12),
              Text('Toko ${isOpen ? "Buka" : "Tutup"}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(value: isOpen, activeColor: Colors.green, onChanged: (v) => ref.read(_isOpenProvider.notifier).state = v),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _ActionCard(Icons.restaurant_menu, 'Menu', Colors.orange, () => context.push('/menu'))),
            const SizedBox(width: 12),
            Expanded(child: _ActionCard(Icons.receipt_long, 'Pesanan', Colors.blue, () => context.push('/orders'))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _ActionCard(Icons.bar_chart, 'Laporan', Colors.purple, () => context.push('/report'))),
            const SizedBox(width: 12),
            Expanded(child: _ActionCard(Icons.person, 'Profil', Colors.green, () => context.push('/profile'))),
          ]),
          const SizedBox(height: 24),
          const Text('Pesanan Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...List.generate(3, (i) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: ClayColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.receipt, color: ClayColors.primary)),
              title: Text('Pesanan #ORD-${100 + i}'),
              subtitle: Text('Rp ${[25000, 45000, 32000][i]} • ${['Menunggu', 'Diproses', 'Selesai'][i]}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/order/ORD-${100 + i}'),
            ),
          )),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

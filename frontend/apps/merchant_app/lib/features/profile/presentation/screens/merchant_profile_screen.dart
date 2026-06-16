import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../auth/presentation/providers/merchant_auth_provider.dart';

class MerchantProfileScreen extends ConsumerWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(merchantAuthProvider).merchant;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Merchant')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: ClayColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: ClayColors.divider)),
            child: Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: ClayColors.primary, child: const Icon(Icons.store, color: Colors.white, size: 30)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m?['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    Text(m?['owner'] ?? '', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(' ${m?['rating'] ?? 0} • ${m?['total_orders'] ?? 0} pesanan'),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.phone), title: Text(m?['phone'] ?? ''), subtitle: const Text('Telepon')),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.category), title: Text(m?['category'] ?? ''), subtitle: const Text('Kategori')),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.location_on), title: Text(m?['address'] ?? ''), subtitle: const Text('Alamat')),
          ])),
          const SizedBox(height: 24),
          ClayButton(label: 'Keluar', backgroundColor: ClayColors.error, onPressed: () {
            ref.read(merchantAuthProvider.notifier).logout();
            context.go('/login');
          }),
        ],
      ),
    );
  }
}

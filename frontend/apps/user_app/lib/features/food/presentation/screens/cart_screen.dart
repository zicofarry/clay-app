import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/food_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foodStateProvider);
    final notifier = ref.read(foodStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: state.cart.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.cart.length + 2,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text('Pesanan Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  );
                }
                if (i == state.cart.length + 1) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Rp ${notifier.totalPrice}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ClayButton(
                          label: 'Pesan Sekarang',
                          onPressed: () => context.go('/food/checkout'),
                        ),
                      ],
                    ),
                  );
                }
                final entry = state.cart.entries.elementAt(i - 1);
                final item = state.menuItems.firstWhere((m) => m['id'] == entry.key);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text('Rp ${item['price']} x ${entry.value}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            if (entry.value <= 1) {
                              notifier.removeFromCart(entry.key);
                            } else {
                              notifier.addToCart(entry.key, -1);
                            }
                          },
                        ),
                        Text('${entry.value}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () => notifier.addToCart(entry.key, 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

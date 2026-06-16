import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/food_provider.dart';

class MenuScreen extends ConsumerStatefulWidget {
  final String merchantId;
  const MenuScreen({super.key, required this.merchantId});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(foodStateProvider.notifier).loadMenuItems(widget.merchantId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodStateProvider);
    final notifier = ref.read(foodStateProvider.notifier);
    final merchantName = GoRouterState.of(context).extra as String? ?? 'Menu';

    return Scaffold(
      appBar: AppBar(title: Text(merchantName)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.menuItems.length,
              itemBuilder: (_, i) {
                final item = state.menuItems[i];
                final qty = state.cart[item['id']] ?? 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: ClayColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.restaurant, color: ClayColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('Rp ${item['price']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                              Text(item['desc'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (qty > 0)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => notifier.addToCart(item['id'], -1),
                                constraints: const BoxConstraints(),
                              ),
                              Text('$qty', style: const TextStyle(fontWeight: FontWeight.w600)),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => notifier.addToCart(item['id'], 1),
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: ClayColors.primary),
                            onPressed: () => notifier.addToCart(item['id'], 1),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: notifier.totalItems > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClayButton(
                  label: 'Lihat Keranjang (${notifier.totalItems} item • Rp ${notifier.totalPrice})',
                  onPressed: () => context.go('/food/cart'),
                ),
              ),
            )
          : null,
    );
  }
}

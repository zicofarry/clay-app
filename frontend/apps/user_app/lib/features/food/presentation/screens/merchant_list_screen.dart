import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/food_provider.dart';

class MerchantListScreen extends ConsumerStatefulWidget {
  const MerchantListScreen({super.key});

  @override
  ConsumerState<MerchantListScreen> createState() => _MerchantListScreenState();
}

class _MerchantListScreenState extends ConsumerState<MerchantListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(foodStateProvider.notifier).loadMerchants());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('GoFood')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.merchants.length,
              itemBuilder: (_, i) {
                final m = state.merchants[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: ClayColors.primary.withValues(alpha: 0.1),
                      child: Text(m['name'][0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ClayColors.primary)),
                    ),
                    title: Text(m['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            Text(' ${m['rating']} • ${m['distance']}'),
                          ],
                        ),
                        Text('${m['category']} • ${m['eta']}'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/food/menu/${m['id']}', extra: m['name']),
                  ),
                );
              },
            ),
    );
  }
}

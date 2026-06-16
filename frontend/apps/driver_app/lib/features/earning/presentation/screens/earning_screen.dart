import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../data/mock_earning_repository.dart';

final earningProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, key) async {
  final repo = MockEarningRepository();
  if (key == 'today') return repo.getTodayEarning();
  return {'total': 0};
});

final earningHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return MockEarningRepository().getHistory();
});

class EarningScreen extends ConsumerWidget {
  const EarningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(earningProvider('today'));
    final history = ref.watch(earningHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pendapatan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          today.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error'),
            data: (d) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [ClayColors.primary, ClayColors.primaryDark]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Pendapatan Hari Ini', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('Rp ${d['total']}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat('${d['orders']}', 'Pesanan'),
                      _Stat('${d['hours']} jam', 'Online'),
                      _Stat('Rp ${d['tips']}', 'Tips'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Riwayat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          history.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (list) => Column(
              children: list.map((e) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text((e['date'] ?? '').toString()),
                  trailing: Text('Rp ${e['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${e['orders']} pesanan'),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }
}

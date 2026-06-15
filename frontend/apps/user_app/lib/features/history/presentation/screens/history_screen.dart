import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = [
      {'type': 'GoRide', 'date': '15 Jun 2026', 'desc': 'Jl. Sudirman → Jl. Thamrin', 'price': 25000, 'status': 'Selesai'},
      {'type': 'GoFood', 'date': '15 Jun 2026', 'desc': 'Bakso Merdeka', 'price': 30000, 'status': 'Selesai'},
      {'type': 'GoCar', 'date': '14 Jun 2026', 'desc': 'Jl. Kuningan → Jl. Senayan', 'price': 45000, 'status': 'Selesai'},
      {'type': 'GoFood', 'date': '13 Jun 2026', 'desc': 'Sate Pak Edi', 'price': 52000, 'status': 'Selesai'},
      {'type': 'GoSend', 'date': '12 Jun 2026', 'desc': 'Dokumen ke Kantor', 'price': 15000, 'status': 'Selesai'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (_, i) {
          final o = orders[i];
          final icon = o['type'] == 'GoRide' || o['type'] == 'GoCar'
              ? Icons.directions_car
              : o['type'] == 'GoFood' ? Icons.restaurant : Icons.inventory_2;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: ClayColors.primary.withValues(alpha: 0.1),
                child: Icon(icon, color: ClayColors.primary),
              ),
              title: Text('${(o['type'] ?? '').toString()} • ${(o['date'] ?? '').toString()}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text((o['desc'] ?? '').toString(), style: const TextStyle(fontSize: 12)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rp ${o['price']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text((o['status'] ?? '').toString(), style: const TextStyle(color: Colors.green, fontSize: 11)),
                ],
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:clay_ui/clay_ui.dart';

class DriversListScreen extends StatelessWidget {
  const DriversListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final drivers = List.generate(8, (i) => {
      'name': 'Driver ${i + 1}', 'phone': '+6281234567${i}', 'vehicle': 'Toyota Avanza', 'plate': 'B ${1000 + i} ABC', 'status': i % 4 == 0 ? 'offline' : 'online', 'rating': 4.5 + (i * 0.1),
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Driver')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: drivers.length,
        itemBuilder: (_, i) {
          final d = drivers[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.green.withValues(alpha: 0.1), child: const Icon(Icons.directions_car, color: Colors.green)),
              title: Text(d['name']),
              subtitle: Text('${d['vehicle']} • ${d['plate']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${d['rating']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (d['status'] == 'online' ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(d['status'], style: TextStyle(color: d['status'] == 'online' ? Colors.green : Colors.grey, fontSize: 10)),
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

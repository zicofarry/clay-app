import 'package:flutter/material.dart';
import 'package:clay_ui/clay_ui.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = List.generate(10, (i) => {
      'name': 'User ${i + 1}', 'phone': '+6281234567${i}', 'status': i % 3 == 0 ? 'suspended' : 'active', 'date': '2026-06-${10 + i}',
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Pengguna')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (_, i) {
          final u = users[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: ClayColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.person, color: ClayColors.primary)),
              title: Text(u['name']),
              subtitle: Text(u['phone']),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (u['status'] == 'active' ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(u['status'], style: TextStyle(color: u['status'] == 'active' ? Colors.green : Colors.red, fontSize: 12)),
              ),
            ),
          );
        },
      ),
    );
  }
}

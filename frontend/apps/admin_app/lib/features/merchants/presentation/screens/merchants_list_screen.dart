import 'package:flutter/material.dart';
import 'package:clay_ui/clay_ui.dart';

class MerchantsListScreen extends StatelessWidget {
  const MerchantsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final merchants = [
      {'name': 'Bakso Merdeka', 'owner': 'Pak Budi', 'category': 'Makanan', 'rating': 4.5, 'status': 'active'},
      {'name': 'Sate Pak Edi', 'owner': 'Pak Edi', 'category': 'Sate', 'rating': 4.8, 'status': 'active'},
      {'name': 'Nasi Goreng Mawar', 'owner': 'Bu Mawar', 'category': 'Nasi', 'rating': 4.3, 'status': 'suspended'},
      {'name': 'Ayam Geprek Joe', 'owner': 'Joe', 'category': 'Ayam', 'rating': 4.6, 'status': 'active'},
      {'name': 'Padang Sederhana', 'owner': 'Pak Rifai', 'category': 'Padang', 'rating': 4.4, 'status': 'active'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Merchant')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: merchants.length,
        itemBuilder: (_, i) {
          final m = merchants[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.orange.withValues(alpha: 0.1), child: const Icon(Icons.store, color: Colors.orange)),
              title: Text('${m['name']}'),
              subtitle: Text('${m['category']} • ${m['owner']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⭐ ${m['rating']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (m['status'] == 'active' ? Colors.green : Colors.red).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${m['status']}', style: TextStyle(color: m['status'] == 'active' ? Colors.green : Colors.red, fontSize: 10)),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../auth/presentation/providers/driver_auth_provider.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(driverAuthProvider).driver;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: ClayColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: ClayColors.divider)),
            child: Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: ClayColors.primary, child: const Icon(Icons.person, color: Colors.white, size: 30)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d?['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    Text(d?['phone'] ?? '', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(' ${d?['rating'] ?? 0} • ${d?['total_orders'] ?? 0} pesanan'),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.directions_car), title: Text(d?['vehicle'] ?? ''), subtitle: const Text('Kendaraan')),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.confirmation_number), title: Text(d?['plate'] ?? ''), subtitle: const Text('Plat Nomor')),
          ])),
          const SizedBox(height: 24),
          ClayButton(label: 'Keluar', backgroundColor: ClayColors.error, onPressed: () => context.go('/login')),
        ],
      ),
    );
  }
}

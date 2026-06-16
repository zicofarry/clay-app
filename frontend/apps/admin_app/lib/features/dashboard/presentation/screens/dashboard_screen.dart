import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.person), onPressed: () => context.go('/profile')),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [ClayColors.primary, ClayColors.primaryDark]), borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Selamat datang, Admin', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              const Text('Clay Platform', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _StatCard('Pengguna', '12.450', Icons.people, Colors.blue, () => context.go('/users'))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Driver', '2.340', Icons.directions_car, Colors.green, () => context.go('/drivers'))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatCard('Merchant', '890', Icons.store, Colors.orange, () => context.go('/merchants'))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Transaksi', '45.2K', Icons.receipt_long, Colors.purple, () {})),
          ]),
          const SizedBox(height: 24),
          const Text('Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.people, color: Colors.blue), title: const Text('Kelola Pengguna'), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/users')),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.directions_car, color: Colors.green), title: const Text('Kelola Driver'), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/drivers')),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.store, color: Colors.orange), title: const Text('Kelola Merchant'), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/merchants')),
          ])),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _StatCard(this.title, this.value, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: color),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ]),
        ),
      ),
    );
  }
}

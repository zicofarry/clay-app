import 'package:flutter/material.dart';
import 'package:clay_ui/clay_ui.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(child: _StatCard('Hari Ini', 'Rp 450.000', Icons.today, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Minggu Ini', 'Rp 2.8jt', Icons.weekend, Colors.green)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatCard('Bulan Ini', 'Rp 12.5jt', Icons.date_range, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Total', 'Rp 156jt', Icons.account_balance, Colors.purple)),
          ]),
          const SizedBox(height: 24),
          const Text('Pesanan Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            child: Column(children: [
              ListTile(title: const Text('Total Pesanan'), trailing: const Text('24', style: TextStyle(fontWeight: FontWeight.bold))),
              const Divider(height: 1),
              ListTile(title: const Text('Selesai'), trailing: const Text('18', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              const Divider(height: 1),
              ListTile(title: const Text('Dibatalkan'), trailing: const Text('3', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
              const Divider(height: 1),
              ListTile(title: const Text('Rata-rata Pesanan'), trailing: const Text('Rp 18.750', style: TextStyle(fontWeight: FontWeight.bold))),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Menu Terlaris', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...List.generate(4, (i) {
            final items = ['Bakso Besar', 'Mie Ayam', 'Es Teh', 'Pangsit Goreng'];
            final counts = [45, 38, 30, 22];
            return Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ClayColors.primary.withValues(alpha: 0.1),
                  child: Text('${i + 1}', style: const TextStyle(color: ClayColors.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text(items[i]),
                trailing: Text('${counts[i]}x', style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 20),
            const Spacer(),
          ]),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ]),
      ),
    );
  }
}

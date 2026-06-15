import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/ride_provider.dart';

class RideHomeScreen extends ConsumerStatefulWidget {
  const RideHomeScreen({super.key});

  @override
  ConsumerState<RideHomeScreen> createState() => _RideHomeScreenState();
}

class _RideHomeScreenState extends ConsumerState<RideHomeScreen> {
  final _pickupController = TextEditingController(text: 'Jl. Sudirman No. 1');
  final _destController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _destController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('GoRide')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ClayColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ClayColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          Container(width: 2, height: 30, color: ClayColors.divider),
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              controller: _pickupController,
                              decoration: const InputDecoration(
                                hintText: 'Lokasi jemput',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                            Divider(height: 1, color: ClayColors.divider),
                            TextField(
                              controller: _destController,
                              decoration: const InputDecoration(
                                hintText: 'Mau ke mana?',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ClayButton(
              label: 'Cari Driver',
              onPressed: _onSearch,
            ),
            if (state.estimate != null) ...[
              const SizedBox(height: 24),
              const Text('Pilih Layanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...((state.estimate!['services'] as List).map((s) => _ServiceCard(
                name: s['name'],
                price: 'Rp ${s['price']}',
                eta: '${s['eta']} menit',
                icon: s['icon'] == 'car' ? Icons.directions_car : Icons.motorcycle,
                onTap: () => _onSelectService(s),
              ))),
            ],
          ],
        ),
      ),
    );
  }

  void _onSearch() {
    ref.read(rideStateProvider.notifier).estimate(
      pickupLat: -6.2088, pickupLng: 106.8456,
      destLat: -6.3, destLng: 106.9,
    );
  }

  void _onSelectService(Map<String, dynamic> service) {
    ref.read(rideStateProvider.notifier).createOrder(
      pickupLat: -6.2088, pickupLng: 106.8456, pickupAddress: _pickupController.text,
      destLat: -6.3, destLng: 106.9, destAddress: _destController.text,
      serviceType: service['type'], price: service['price'],
    );

    ref.listen(rideStateProvider, (_, state) {
      if (state.activeOrder != null) {
        context.go('/ride/tracking');
      }
    });
  }
}

class _ServiceCard extends StatelessWidget {
  final String name, price, eta;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceCard({required this.name, required this.price, required this.eta, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: ClayColors.primary),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$price • $eta'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

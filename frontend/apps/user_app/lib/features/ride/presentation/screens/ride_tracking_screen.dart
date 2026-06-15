import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/ride_provider.dart';

class RideTrackingScreen extends ConsumerWidget {
  const RideTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rideStateProvider);
    final order = state.activeOrder ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perjalanan'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: ClayColors.primary.withValues(alpha: 0.1),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 80, color: ClayColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      order['status'] == 'driver_assigned' ? 'Driver dalam perjalanan' : 'Mencari driver...',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    if (order['status'] == 'driver_assigned') ...[
                      const SizedBox(height: 8),
                      const Text('Driver akan menjemput dalam 5 menit'),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                if (order['driver'] != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: ClayColors.primary,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order['driver']['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            Text('${order['driver']['vehicle']} • ${order['driver']['plate']}'),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    const Icon(Icons.gps_fixed, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(order['pickup_address'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(order['destination_address'] ?? '')),
                  ],
                ),
                const SizedBox(height: 20),
                ClayButton(
                  label: 'Hubungi Driver',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

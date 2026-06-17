import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/waste_provider.dart';

class WasteTrackingScreen extends ConsumerWidget {
  const WasteTrackingScreen({super.key});

  static const _statusSteps = ['assigned', 'on_pickup', 'picked_up', 'on_delivery'];
  static const _statusLabels = {
    'assigned': 'Kurir Ditugaskan',
    'on_pickup': 'Menuju Lokasi Jemput',
    'picked_up': 'Sampah Diambil',
    'on_delivery': 'Dalam Perjalanan ke TPS',
    'delivered': 'Terkirim ke TPS',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wasteStateProvider);

    ref.listen(wasteStateProvider, (prev, next) {
      if (next.orderStatus == 'delivered') {
        context.go('/waste/complete');
      }
      if (next.orderStatus == 'cancelled') {
        context.go('/waste');
      }
    });

    final isCancellable = state.orderStatus == 'assigned' || state.orderStatus == 'on_pickup';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: ClayColors.muted, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusLabels[state.orderStatus] ?? 'Status Penjemputan',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // ── Map ──
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    ((state.pickupLat ?? 0) + (state.destLat ?? 0)) / 2,
                    ((state.pickupLng ?? 0) + (state.destLng ?? 0)) / 2,
                  ),
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.clay.user_app',
                  ),
                  MarkerLayer(
                    markers: [
                      if (state.pickupLat != null)
                        Marker(point: LatLng(state.pickupLat!, state.pickupLng!), child: const Icon(Icons.radio_button_checked, color: Colors.green, size: 24)),
                      if (state.destLat != null)
                        Marker(point: LatLng(state.destLat!, state.destLng!), child: const Icon(Icons.location_on, color: Colors.red, size: 28)),
                    ],
                  ),
                  if (state.pickupLat != null && state.destLat != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [LatLng(state.pickupLat!, state.pickupLng!), LatLng(state.destLat!, state.destLng!)],
                          color: ClayColors.primary,
                          strokeWidth: 3,
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepper(state.orderStatus),

                    const SizedBox(height: 20),

                    // ── Driver info ──
                    if (state.driverInfo != null) ...[
                      const Text('Info Kurir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ClayColors.divider),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: ClayColors.muted,
                              backgroundImage: (state.driverInfo!['photo_url'] as String).isNotEmpty
                                  ? NetworkImage(state.driverInfo!['photo_url'] as String)
                                  : null,
                              child: (state.driverInfo!['photo_url'] as String).isEmpty
                                  ? const Icon(Icons.person, size: 24, color: ClayColors.textSecondary)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(state.driverInfo!['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  const Text('Kurir ClayWaste', style: TextStyle(fontSize: 13, color: ClayColors.textSecondary)),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: ClayColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.call_outlined, color: ClayColors.primary, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Waste + route info ──
                    const Text('Detail Penjemputan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: ClayColors.muted, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          Row(children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: ClayColors.green, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(state.pickupAddress, style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ]),
                          Padding(padding: const EdgeInsets.only(left: 3), child: Container(width: 2, height: 14, color: ClayColors.divider)),
                          Row(children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: ClayColors.accent, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(state.destAddress, style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ]),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Penjemput: ${state.senderName}', style: const TextStyle(fontSize: 13)),
                              Text(state.wasteCategory.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ClayColors.primaryDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Cancel button ──
            if (isCancellable)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: ClayButton(
                  label: 'Batalkan Penjemputan',
                  outlined: true,
                  isLoading: state.isLoading,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Batalkan Penjemputan?'),
                        content: const Text('Sampah belum diambil kurir. Yakin ingin membatalkan?'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tidak')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(wasteStateProvider.notifier).cancelOrder(reason: 'User cancelled');
                            },
                            child: const Text('Ya, Batalkan', style: TextStyle(color: ClayColors.accent)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(String currentStatus) {
    final currentIndex = _statusSteps.indexOf(currentStatus);
    final isDelivered = currentStatus == 'delivered';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ClayColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _statusSteps.length; i++) ...[
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (i <= currentIndex || isDelivered) ? ClayColors.primary : ClayColors.muted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    (i <= currentIndex || isDelivered) ? Icons.check : Icons.circle_outlined,
                    color: (i <= currentIndex || isDelivered) ? Colors.white : ClayColors.textSecondary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _statusLabels[_statusSteps[i]] ?? _statusSteps[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: (i == currentIndex || isDelivered) ? FontWeight.w600 : FontWeight.normal,
                    color: (i <= currentIndex || isDelivered) ? ClayColors.textPrimary : ClayColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (i < _statusSteps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 13),
                child: Container(
                  width: 2,
                  height: 20,
                  color: (i < currentIndex || isDelivered) ? ClayColors.primary : ClayColors.divider,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

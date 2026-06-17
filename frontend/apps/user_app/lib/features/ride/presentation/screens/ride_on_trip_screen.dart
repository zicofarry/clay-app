import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/ride_provider.dart';

class RideOnTripScreen extends ConsumerWidget {
  const RideOnTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rideStateProvider);
    final driver = state.driverInfo;

    // Listen for trip completion
    ref.listen(rideStateProvider, (prev, next) {
      if (next.orderStatus == 'completed') {
        context.go('/ride/complete');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Map ──
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      ((state.pickupLat ?? 0) + (state.destLat ?? 0)) / 2,
                      ((state.pickupLng ?? 0) + (state.destLng ?? 0)) / 2,
                    ),
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.clay.user_app',
                    ),
                    // Route
                    if (state.pickupLat != null && state.destLat != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              LatLng(state.pickupLat!, state.pickupLng!),
                              LatLng(state.destLat!, state.destLng!),
                            ],
                            color: ClayColors.primary,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Pickup (small grey)
                        if (state.pickupLat != null)
                          Marker(
                            point: LatLng(state.pickupLat!, state.pickupLng!),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        // Destination
                        if (state.destLat != null)
                          Marker(
                            point: LatLng(state.destLat!, state.destLng!),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Tujuan',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Icon(Icons.location_on, color: Colors.red, size: 28),
                              ],
                            ),
                          ),
                        // Driver (moving - simulated at midpoint)
                        if (state.pickupLat != null && state.destLat != null)
                          Marker(
                            point: LatLng(
                              (state.pickupLat! + state.destLat!) / 2,
                              (state.pickupLng! + state.destLng!) / 2,
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: ClayColors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: ClayColors.green.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.two_wheeler, color: Colors.white, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Status bar
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: ClayColors.green,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: ClayColors.green.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Dalam perjalanan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '~${state.durationMin} mnt',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom panel ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ClayColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Trip progress
                _TripProgress(
                  distanceKm: state.distanceKm,
                  durationMin: state.durationMin,
                ),

                const SizedBox(height: 16),

                // Driver info (compact)
                if (driver != null)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: ClayColors.primary.withValues(alpha: 0.15),
                        child: const Icon(Icons.person, color: ClayColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver['name'] as String? ?? 'Driver',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${driver['vehicle'] ?? ''} • ${driver['plate'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: ClayColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quick actions
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, color: ClayColors.primary, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: ClayColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline, color: ClayColors.primary, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: ClayColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Destination
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ClayColors.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: ClayColors.accent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Menuju',
                              style: TextStyle(fontSize: 11, color: ClayColors.textSecondary),
                            ),
                            Text(
                              state.destAddress,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Safety button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('Bagikan Trip', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ClayColors.textSecondary,
                          side: const BorderSide(color: ClayColors.divider),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.shield_outlined, size: 16, color: ClayColors.accent),
                        label: const Text('Darurat', style: TextStyle(fontSize: 13, color: ClayColors.accent)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ClayColors.accent,
                          side: const BorderSide(color: ClayColors.accent),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trip Progress Widget ──────────────────────────────────────────────────

class _TripProgress extends StatelessWidget {
  final double distanceKm;
  final int durationMin;

  const _TripProgress({required this.distanceKm, required this.durationMin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.35, // simulated 35% progress
            backgroundColor: ClayColors.divider,
            color: ClayColors.green,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.route, size: 14, color: ClayColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '$distanceKm km',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ClayColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: ClayColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '~$durationMin menit lagi',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ClayColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/ride_provider.dart';

class RideTrackingScreen extends ConsumerStatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideStateProvider);
    final driver = state.driverInfo;

    // Listen for status changes
    ref.listen(rideStateProvider, (prev, next) {
      if (next.orderStatus == 'on_trip') {
        context.go('/ride/on-trip');
      }
      if (next.orderStatus == 'cancelled') {
        context.go('/ride');
      }
    });

    final isOnPickup = state.orderStatus == 'on_pickup';
    final statusLabel = isOnPickup ? 'Driver telah tiba' : 'Driver menuju lokasi jemput';
    final statusColor = isOnPickup ? ClayColors.green : ClayColors.primary;

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
                      state.pickupLat ?? -6.9175,
                      state.pickupLng ?? 107.6191,
                    ),
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.clay.user_app',
                    ),
                    MarkerLayer(
                      markers: [
                        // Pickup marker
                        if (state.pickupLat != null)
                          Marker(
                            point: LatLng(state.pickupLat!, state.pickupLng!),
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
                                    'Jemput',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Icon(Icons.radio_button_checked, color: Colors.green, size: 20),
                              ],
                            ),
                          ),
                        // Destination marker
                        if (state.destLat != null)
                          Marker(
                            point: LatLng(state.destLat!, state.destLng!),
                            child: const Icon(Icons.location_on, color: Colors.red, size: 28),
                          ),
                        // Driver marker
                        if (driver != null)
                          Marker(
                            point: LatLng(
                              (driver['lat'] as num?)?.toDouble() ?? state.pickupLat ?? -6.9175,
                              (driver['lng'] as num?)?.toDouble() ?? state.pickupLng ?? 107.6191,
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: ClayColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: ClayColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.two_wheeler, color: Colors.white, size: 18),
                            ),
                          ),
                      ],
                    ),
                    // Route line
                    if (state.pickupLat != null && state.destLat != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              LatLng(state.pickupLat!, state.pickupLng!),
                              LatLng(state.destLat!, state.destLng!),
                            ],
                            color: ClayColors.primary.withValues(alpha: 0.5),
                            strokeWidth: 3,
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
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOnPickup ? Icons.check_circle : Icons.navigation,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            statusLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!isOnPickup && state.etaSeconds > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(state.etaSeconds / 60).ceil()} mnt',
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

                // OTP code (shown when on_pickup)
                if (isOnPickup && state.otpCode != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: ClayColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ClayColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Berikan kode ini ke driver',
                          style: TextStyle(
                            fontSize: 12,
                            color: ClayColors.warningDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.otpCode!,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                            color: ClayColors.warningDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Driver info
                if (driver != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: ClayColors.primary.withValues(alpha: 0.15),
                        child: const Icon(Icons.person, color: ClayColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver['name'] as String? ?? 'Driver',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${driver['vehicle'] ?? ''} • ${driver['plate'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: ClayColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rating badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ClayColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: ClayColors.warningDark, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              '${driver['rating'] ?? '4.8'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: ClayColors.warningDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Telepon'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ClayColors.primary,
                            side: const BorderSide(color: ClayColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Chat'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ClayColors.primary,
                            side: const BorderSide(color: ClayColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Route info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ClayColors.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: ClayColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.pickupAddress,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: ClayColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.destAddress,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Cancel button (only before on_trip)
                if (state.orderStatus != 'on_trip') ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _onCancel,
                    child: const Text(
                      'Batalkan Pesanan',
                      style: TextStyle(
                        color: ClayColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text(
          'Pembatalan setelah driver ditemukan mungkin dikenakan biaya.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(rideStateProvider.notifier).cancelOrder(reason: 'User cancelled after driver assigned');
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: ClayColors.accent)),
          ),
        ],
      ),
    );
  }
}

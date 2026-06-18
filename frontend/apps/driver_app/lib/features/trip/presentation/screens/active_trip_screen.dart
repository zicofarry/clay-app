import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as dev;
import '../../../../shared/widgets.dart';
import '../../../order/presentation/providers/order_provider.dart';

final tripStatusProvider = StateProvider<String>((ref) => 'on_pickup');

class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _startGpsStream();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startGpsStream() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final initial = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(initial.latitude, initial.longitude);
        });
        _mapController.move(_currentPosition!, 15);
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(_currentPosition!, _mapController.camera.zoom);
        }
      });
    } catch (e) {
      dev.log('GPS stream error: $e', name: 'ActiveTrip');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripStatus = ref.watch(tripStatusProvider);
    final orderState = ref.watch(orderProvider);
    final activeOrder = orderState.activeOrder ?? {};

    final fare = activeOrder['fare_estimate'] ?? activeOrder['fare_final'] ?? 0;
    final paymentMethod = activeOrder['payment_method']?.toString() ?? 'cash';
    final originAddress = activeOrder['origin_address']?.toString() ?? '-';
    final destAddress = activeOrder['dest_address']?.toString() ?? '-';
    final originLat = (activeOrder['origin_lat'] as num?)?.toDouble();
    final originLng = (activeOrder['origin_lng'] as num?)?.toDouble();
    final destLat = (activeOrder['dest_lat'] as num?)?.toDouble();
    final destLng = (activeOrder['dest_lng'] as num?)?.toDouble();
    final tripDetails = activeOrder['trip_details'] as Map<String, dynamic>?;
    final estDuration = tripDetails?['est_duration_min']?.toString() ?? '-';
    final paymentLabel = paymentMethod == 'gopay' ? 'GoPay' : 'Tunai';

    final statusConfig = switch (tripStatus) {
      'on_pickup' => _StatusConfig(
        title: 'Menuju Titik Jemput',
        subtitle: originAddress,
        eta: '$estDuration min',
        gradient: const [ClayColors.primary, ClayColors.primaryLight],
        action: 'Sudah di Lokasi',
        backendAction: 'arrived_at_pickup',
        nextStatus: 'start_trip',
      ),
      'start_trip' => _StatusConfig(
        title: 'Penumpang Sudah Naik',
        subtitle: 'Konfirmasi OTP untuk mulai trip',
        eta: '$estDuration min',
        gradient: const [ClayColors.green, ClayColors.greenDark],
        action: 'Mulai Perjalanan',
        backendAction: 'start_trip',
        nextStatus: 'on_trip',
      ),
      'on_trip' => _StatusConfig(
        title: 'Dalam Perjalanan',
        subtitle: 'Menuju $destAddress',
        eta: '$estDuration min',
        gradient: const [ClayColors.primary, ClayColors.primaryDark],
        action: 'Sampai di Tujuan',
        backendAction: 'complete_trip',
        nextStatus: 'completed',
      ),
      'completed' => _StatusConfig(
        title: 'Trip Selesai',
        subtitle: destAddress,
        eta: '-',
        gradient: const [ClayColors.warning, ClayColors.warningDark],
        action: 'Selesai',
        backendAction: '',
        nextStatus: '',
      ),
      _ => _StatusConfig(title: '', subtitle: '', eta: '', gradient: [], action: '', backendAction: '', nextStatus: ''),
    };

    final defaultCenter = LatLng(originLat ?? -6.9175, originLng ?? 107.6191);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition ?? defaultCenter,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.clay.driver_app',
                    ),
                    MarkerLayer(
                      markers: [
                        if (originLat != null && originLng != null)
                          Marker(
                            point: LatLng(originLat, originLng),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
                                  ),
                                  child: const Text('Jemput', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                                ),
                                const Icon(Icons.radio_button_checked, color: Colors.green, size: 22),
                              ],
                            ),
                          ),
                        if (destLat != null && destLng != null)
                          Marker(
                            point: LatLng(destLat, destLng),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
                                  ),
                                  child: const Text('Tujuan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                                ),
                                const Icon(Icons.location_on, color: Colors.red, size: 28),
                              ],
                            ),
                          ),
                        if (_currentPosition != null)
                          Marker(
                            point: _currentPosition!,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: ClayColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(color: ClayColors.primary.withValues(alpha: 0.4), blurRadius: 12),
                                ],
                              ),
                              child: const Icon(Icons.navigation, color: Colors.white, size: 20),
                            ),
                          ),
                      ],
                    ),
                    if (originLat != null && originLng != null && destLat != null && destLng != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              if (_currentPosition != null && tripStatus != 'on_trip') _currentPosition!,
                              LatLng(originLat, originLng),
                              LatLng(destLat, destLng),
                            ],
                            color: ClayColors.primary.withValues(alpha: 0.6),
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                  ],
                ),

                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: statusConfig.gradient),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: statusConfig.gradient.first.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(statusConfig.title, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
                              Text(statusConfig.subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Estimasi', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8))),
                            Text(statusConfig.eta, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  right: 16,
                  bottom: 16,
                  child: GestureDetector(
                    onTap: () => _showSafetyDialog(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ClayColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: ClayColors.accent.withValues(alpha: 0.3), blurRadius: 12)],
                      ),
                      child: const Icon(Icons.shield, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: ClayColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.person, size: 20, color: ClayColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Rp $fare - $paymentLabel', style: const TextStyle(fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                        Text(activeOrder['service_type']?.toString() ?? 'goride', style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                      ])),
                      GestureDetector(
                        onTap: () => context.go('/chat'),
                        child: Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.card, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]), child: const Icon(Icons.chat_bubble_outline, size: 16, color: ClayColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (tripStatus != 'completed')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: softShadow(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: ClayColors.green, shape: BoxShape.circle, boxShadow: [BoxShadow(color: ClayColors.green.withValues(alpha: 0.3), blurRadius: 4)])),
                            const SizedBox(height: 4),
                            Container(width: 2, height: 30, color: ClayColors.divider),
                            const SizedBox(height: 4),
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: ClayColors.accent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: ClayColors.accent.withValues(alpha: 0.3), blurRadius: 4)])),
                          ]),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Jemput', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                            Text(originAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textPrimary)),
                            const SizedBox(height: 20),
                            const Text('Tujuan', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                            Text(destAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textPrimary)),
                          ])),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () async {
                      final notifier = ref.read(orderProvider.notifier);
                      if (statusConfig.backendAction.isEmpty) {
                        notifier.completeOrder();
                        ref.read(tripStatusProvider.notifier).state = 'on_pickup';
                        if (context.mounted) context.go('/trip-complete');
                        return;
                      }
                      try {
                        await notifier.updateTripStatus(statusConfig.backendAction);
                        if (statusConfig.nextStatus.isEmpty) {
                          notifier.completeOrder();
                          ref.read(tripStatusProvider.notifier).state = 'on_pickup';
                          if (context.mounted) context.go('/trip-complete');
                        } else {
                          ref.read(tripStatusProvider.notifier).state = statusConfig.nextStatus;
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal memperbarui status: $e')),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(colors: statusConfig.gradient),
                        boxShadow: statusConfig.gradient.isNotEmpty
                            ? [BoxShadow(color: statusConfig.gradient.first.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]
                            : null,
                      ),
                      child: Center(child: Text(statusConfig.action, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showSafetyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [
        Icon(Icons.shield, color: ClayColors.accent),
        SizedBox(width: 8),
        Text('Keamanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SafetyOption(icon: Icons.emergency, label: 'Panggilan Darurat (112)', color: ClayColors.accent, onTap: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menghubungi 112...'), duration: Duration(seconds: 1))); }),
          const SizedBox(height: 8),
          _SafetyOption(icon: Icons.share_location, label: 'Bagikan Lokasi Real-time', color: ClayColors.primary, onTap: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lokasi dibagikan ke kontak darurat'), duration: Duration(seconds: 1))); }),
          const SizedBox(height: 8),
          _SafetyOption(icon: Icons.report, label: 'Laporkan Masalah', color: ClayColors.warning, onTap: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan terkirim'), duration: Duration(seconds: 1))); }),
        ],
      ),
    ),
  );
}

class _SafetyOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SafetyOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color))),
          Icon(Icons.chevron_right, size: 18, color: color),
        ]),
      ),
    );
  }
}

class _StatusConfig {
  final String title, subtitle, eta, action, backendAction, nextStatus;
  final List<Color> gradient;
  const _StatusConfig({required this.title, required this.subtitle, required this.eta, required this.gradient, required this.action, required this.backendAction, required this.nextStatus});
}

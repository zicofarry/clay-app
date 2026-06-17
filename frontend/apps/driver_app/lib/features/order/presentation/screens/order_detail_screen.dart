import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../../shared/widgets.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.incomingOrder ?? {};

    final serviceType = order['service_type']?.toString() ?? 'goride';
    final vehicleType = order['vehicle_type']?.toString() ?? 'motor';
    final fare = order['fare_estimate'] ?? order['fare_final'] ?? 0;
    final originAddress = order['origin_address']?.toString() ?? '-';
    final destAddress = order['dest_address']?.toString() ?? '-';
    final paymentMethod = order['payment_method']?.toString() ?? 'cash';
    final tripDetails = order['trip_details'] as Map<String, dynamic>?;
    final estDistance = tripDetails?['est_distance_km']?.toString() ?? '-';
    final estDuration = tripDetails?['est_duration_min']?.toString() ?? '-';

    final serviceLabel = serviceType == 'gocar' ? 'ClayCar' : 'ClayRide';
    final vehicleLabel = vehicleType == 'car' ? 'Mobil' : 'Motor';
    final paymentLabel = paymentMethod == 'gopay' ? 'GoPay' : 'Tunai';

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ClayColors.primary.withValues(alpha: 0.08),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ClayColors.primaryLight, ClayColors.background],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.2,
                    top: MediaQuery.of(context).size.height * 0.15,
                    child: _MapPin(label: 'Jemput', color: ClayColors.green),
                  ),
                  Positioned(
                    right: MediaQuery.of(context).size.width * 0.2,
                    top: MediaQuery.of(context).size.height * 0.35,
                    child: _MapPin(label: 'Tujuan', color: ClayColors.accent),
                  ),
                  Positioned(
                    top: 16, left: 20, right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Row(
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Order Masuk', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            const SizedBox(height: 2),
                            Text('$serviceLabel - $vehicleLabel', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                          ]),
                          const Spacer(),
                          Text('Rp $fare', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ClayColors.green)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(serviceLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: ClayColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.monetization_on, size: 14, color: ClayColors.primary),
                          const SizedBox(width: 4),
                          Text('Rp $fare', style: const TextStyle(fontWeight: FontWeight.bold, color: ClayColors.primary)),
                        ]),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: softShadow(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: ClayColors.green, shape: BoxShape.circle)),
                          Container(width: 2, height: 30, color: ClayColors.divider),
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: ClayColors.accent, shape: BoxShape.circle)),
                        ]),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Jemput', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                          Text(originAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textPrimary)),
                          const SizedBox(height: 16),
                          const Text('Tujuan', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                          Text(destAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textPrimary)),
                        ])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: ClayColors.muted, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _TripDetail(icon: Icons.navigation, value: '$estDistance km', label: 'Jarak'),
                      const _TripDetailDivider(),
                      _TripDetail(icon: Icons.access_time, value: '$estDuration min', label: 'Estimasi'),
                      const _TripDetailDivider(),
                      _TripDetail(icon: Icons.monetization_on, value: paymentLabel, label: 'Pembayaran'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              await ref.read(orderProvider.notifier).rejectOrder();
                              if (context.mounted) context.go('/home');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal menolak order: $e')),
                              );
                            }
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: ClayColors.divider), color: ClayColors.card),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.close, size: 18, color: ClayColors.textSecondary),
                              SizedBox(width: 6),
                              Text('Tolak', style: TextStyle(fontWeight: FontWeight.w600, color: ClayColors.textSecondary)),
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              await ref.read(orderProvider.notifier).acceptOrder();
                              if (context.mounted) context.go('/active-trip');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal menerima order: $e')),
                              );
                            }
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(colors: [ClayColors.green, ClayColors.greenDark]),
                              boxShadow: [BoxShadow(color: ClayColors.green.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                            ),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.check, size: 18, color: Colors.white),
                              SizedBox(width: 6),
                              Text('Terima Order', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;
  final Color color;
  const _MapPin({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12)]), child: const Icon(Icons.person, size: 18, color: Colors.white)),
        CustomPaint(
          size: const Size(12, 12),
          painter: _TrianglePainter(color),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TripDetail extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _TripDetail({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: ClayColors.primary),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
      ]),
      Text(label, style: const TextStyle(fontSize: 10, color: ClayColors.textSecondary)),
    ]);
  }
}

class _TripDetailDivider extends StatelessWidget {
  const _TripDetailDivider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 24, color: ClayColors.divider);
}

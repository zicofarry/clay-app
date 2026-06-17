import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/ride_provider.dart';

class RideSearchingScreen extends ConsumerStatefulWidget {
  const RideSearchingScreen({super.key});

  @override
  ConsumerState<RideSearchingScreen> createState() => _RideSearchingScreenState();
}

class _RideSearchingScreenState extends ConsumerState<RideSearchingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideStateProvider);

    // Listen for driver found
    ref.listen(rideStateProvider, (prev, next) {
      if (prev?.orderStatus != 'assigned' && next.orderStatus == 'assigned') {
        // Driver found, navigate to tracking
        context.go('/ride/tracking');
      }
      if (next.orderStatus == 'cancelled') {
        context.go('/ride');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const SizedBox(width: 40), // spacer
                  const Expanded(
                    child: Text(
                      'Mencari Driver',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ── Animation area ──
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Radar animation
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple circles
                        ...List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _pulseController,
                            builder: (_, __) {
                              final delay = index * 0.33;
                              final progress = (_pulseController.value + delay) % 1.0;
                              return Opacity(
                                opacity: (1.0 - progress).clamp(0.0, 0.5),
                                child: Container(
                                  width: 120 + (progress * 80),
                                  height: 120 + (progress * 80),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: ClayColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        // Rotating line
                        AnimatedBuilder(
                          animation: _rotateController,
                          builder: (_, child) {
                            return Transform.rotate(
                              angle: _rotateController.value * 2 * pi,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 120,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ClayColors.primary.withValues(alpha: 0.0),
                                  ClayColors.primary,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Center icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: ClayColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: ClayColors.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.two_wheeler,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Status text
                  const Text(
                    'Mencari driver terdekat...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mohon tunggu sebentar',
                    style: TextStyle(
                      fontSize: 14,
                      color: ClayColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Progress dots
                  _LoadingDots(),
                ],
              ),
            ),

            // ── Ride info card ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ClayColors.muted,
                borderRadius: BorderRadius.circular(14),
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
                  if (state.selectedService != null) ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.selectedService!['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Rp${_formatCurrency(state.selectedService!['fare_estimate'] as int)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Cancel button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ClayButton(
                label: 'Batalkan Pencarian',
                outlined: true,
                isLoading: state.isLoading,
                onPressed: () => _onCancel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text('Apakah kamu yakin ingin membatalkan pencarian driver?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(rideStateProvider.notifier).cancelOrder(reason: 'User cancelled during search');
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: ClayColors.accent)),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    final str = amount.abs().toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }
}

// ── Loading Dots Animation ────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final progress = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = progress < 0.5
                ? (progress * 2).clamp(0.3, 1.0)
                : ((1.0 - progress) * 2).clamp(0.3, 1.0);

            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: ClayColors.primary.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../location/presentation/screens/location_picker_screen.dart';
import '../providers/ride_provider.dart';

class RideHomeScreen extends ConsumerStatefulWidget {
  const RideHomeScreen({super.key});

  @override
  ConsumerState<RideHomeScreen> createState() => _RideHomeScreenState();
}

class _RideHomeScreenState extends ConsumerState<RideHomeScreen> {
  final _pickupController = TextEditingController();
  final _destController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset ride state when entering ride home
    Future.microtask(() {
      ref.read(rideStateProvider.notifier).resetRide();
    });
  }

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
      backgroundColor: ClayColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ClayColors.muted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Where you want to go today?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Location inputs ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ClayColors.muted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Green/Red dots
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: ClayColors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 28,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color: ClayColors.divider,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: ClayColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              // Pickup
                              GestureDetector(
                                onTap: () => _pickLocation(isPickup: true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          state.pickupAddress.isNotEmpty
                                              ? state.pickupAddress
                                              : 'Lokasi jemput',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: state.pickupAddress.isNotEmpty
                                                ? ClayColors.textPrimary
                                                : ClayColors.textSecondary,
                                            fontWeight: state.pickupAddress.isNotEmpty
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(Icons.my_location, size: 18, color: ClayColors.green),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Destination
                              GestureDetector(
                                onTap: () => _pickLocation(isPickup: false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          state.destAddress.isNotEmpty
                                              ? state.destAddress
                                              : 'Mau ke mana?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: state.destAddress.isNotEmpty
                                                ? ClayColors.textPrimary
                                                : ClayColors.textSecondary,
                                            fontWeight: state.destAddress.isNotEmpty
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(Icons.search, size: 18, color: ClayColors.accent),
                                    ],
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
            ),

            // ── Content ──
            Expanded(
              child: state.isLoading && state.estimate == null
                  ? const Center(child: CircularProgressIndicator(color: ClayColors.primary))
                  : state.estimate != null
                      ? _buildServiceList(state)
                      : _buildPromptMessage(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptMessage(RideState state) {
    final hasPickup = state.pickupLat != null;
    final hasDest = state.destLat != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasPickup && hasDest ? Icons.search : Icons.pin_drop_outlined,
              size: 64,
              color: ClayColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              !hasPickup
                  ? 'Pilih lokasi jemput'
                  : !hasDest
                      ? 'Pilih tujuan perjalanan'
                      : 'Siap mencari perjalanan',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ClayColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              !hasPickup
                  ? 'Ketuk "Lokasi jemput" di atas'
                  : !hasDest
                      ? 'Ketuk "Mau ke mana?" di atas'
                      : 'Klik tombol di bawah untuk melihat estimasi harga',
              style: const TextStyle(
                fontSize: 14,
                color: ClayColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasPickup && hasDest) ...[
              const SizedBox(height: 24),
              ClayButton(
                label: 'Cari Perjalanan',
                onPressed: () {
                  ref.read(rideStateProvider.notifier).estimateFare();
                },
              ),
            ],
            if (state.error != null) ...[
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: const TextStyle(color: ClayColors.error, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceList(RideState state) {
    final services = (state.estimate?['services'] as List?) ?? [];

    return Column(
      children: [
        // Distance & Duration info
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: ClayColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.route, size: 16, color: ClayColors.primaryDark),
              const SizedBox(width: 6),
              Text(
                '${state.distanceKm} km',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ClayColors.primaryDark,
                ),
              ),
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: ClayColors.primaryDark,
                  shape: BoxShape.circle,
                ),
              ),
              Icon(Icons.schedule, size: 16, color: ClayColors.primaryDark),
              const SizedBox(width: 6),
              Text(
                '~${state.durationMin} menit',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ClayColors.primaryDark,
                ),
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pilih Layanan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ClayColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Service list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index] as Map<String, dynamic>;
              final isSelected = state.selectedService?['vehicle_type'] == service['vehicle_type'];

              return _ServiceCard(
                name: service['name'] as String,
                fare: service['fare_estimate'] as int,
                etaMin: service['eta_min'] as int,
                icon: service['icon'] == 'car' ? Icons.directions_car : Icons.two_wheeler,
                isSelected: isSelected,
                onTap: () {
                  ref.read(rideStateProvider.notifier).selectService(service);
                },
              );
            },
          ),
        ),

        // Confirm button
        if (state.selectedService != null)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClayButton(
              label: 'Lanjutkan — Rp${_formatCurrency(state.selectedService!['fare_estimate'] as int)}',
              onPressed: () => context.push('/ride/confirm'),
            ),
          ),
      ],
    );
  }

  Future<void> _pickLocation({required bool isPickup}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result != null) {
      final lat = result['lat'] as double;
      final lng = result['lng'] as double;
      final address = result['address'] as String;

      if (isPickup) {
        ref.read(rideStateProvider.notifier).setPickupLocation(lat, lng, address);
      } else {
        ref.read(rideStateProvider.notifier).setDestLocation(lat, lng, address);
      }

      // Auto-estimate if both locations are set
      final state = ref.read(rideStateProvider);
      if (state.pickupLat != null && state.destLat != null) {
        ref.read(rideStateProvider.notifier).estimateFare();
      }
    }
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

// ── Service Card Widget ───────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final String name;
  final int fare;
  final int etaMin;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.name,
    required this.fare,
    required this.etaMin,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? ClayColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? ClayColors.primary : ClayColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ClayColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? ClayColors.primary.withValues(alpha: 0.15)
                    : ClayColors.muted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? ClayColors.primary : ClayColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isSelected ? ClayColors.primaryDark : ClayColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$etaMin menit',
                    style: const TextStyle(
                      fontSize: 13,
                      color: ClayColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Rp${_formatCurrency(fare)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isSelected ? ClayColors.primaryDark : ClayColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../location/presentation/screens/location_picker_screen.dart';
import '../providers/waste_provider.dart';

class WasteHomeScreen extends ConsumerStatefulWidget {
  const WasteHomeScreen({super.key});

  @override
  ConsumerState<WasteHomeScreen> createState() => _WasteHomeScreenState();
}

class _WasteHomeScreenState extends ConsumerState<WasteHomeScreen> {
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  static const _categories = [
    ('organik', 'Organik', Icons.eco_outlined),
    ('plastik', 'Plastik', Icons.water_drop_outlined),
    ('kertas', 'Kertas', Icons.newspaper_outlined),
    ('logam', 'Logam', Icons.hardware_outlined),
    ('b3', 'B3', Icons.warning_amber_outlined),
    ('lainnya', 'Lainnya', Icons.more_horiz),
  ];

  static const _sizes = [
    ('small', 'Kecil'),
    ('medium', 'Sedang'),
    ('large', 'Besar'),
  ];

  // Default TPS placeholder (Bandung) — used when user doesn't pick a dest.
  static const _defaultTpsLat = -6.914744;
  static const _defaultTpsLng = 107.609810;
  static const _defaultTpsAddress = 'TPS Terdekat (dipilih otomatis)';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(wasteStateProvider.notifier);
      notifier.resetWaste();
      notifier.setDestLocation(_defaultTpsLat, _defaultTpsLng, _defaultTpsAddress);
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wasteStateProvider);

    return Scaffold(
      backgroundColor: ClayColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ClayColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.recycling, color: ClayColors.primaryDark, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Jemput Sampahmu',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ── Location inputs ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ClayColors.muted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(color: ClayColors.green, shape: BoxShape.circle),
                            ),
                            Container(
                              width: 2,
                              height: 28,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(color: ClayColors.divider, borderRadius: BorderRadius.circular(1)),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(color: ClayColors.accent, shape: BoxShape.circle),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _pickLocation(isPickup: true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          state.pickupAddress.isNotEmpty ? state.pickupAddress : 'Lokasi jemput sampah',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: state.pickupAddress.isNotEmpty ? ClayColors.textPrimary : ClayColors.textSecondary,
                                            fontWeight: state.pickupAddress.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
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
                              GestureDetector(
                                onTap: () => _pickLocation(isPickup: false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          state.destAddress.isNotEmpty ? state.destAddress : _defaultTpsAddress,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: state.destAddress.isNotEmpty ? ClayColors.textPrimary : ClayColors.textSecondary,
                                            fontWeight: state.destAddress.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(Icons.place_outlined, size: 18, color: ClayColors.accent),
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.estimate != null) ...[
                            _buildEstimateCard(state),
                            const SizedBox(height: 20),
                          ],

                          // ── Jenis sampah ──
                          const Text(
                            'Jenis Sampah',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((c) {
                              final isSelected = state.wasteCategory == c.$1;
                              return GestureDetector(
                                onTap: () {
                                  ref.read(wasteStateProvider.notifier).setWasteInfo(category: c.$1);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? ClayColors.primary : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? ClayColors.primary : ClayColors.divider,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(c.$3, size: 16, color: isSelected ? Colors.white : ClayColors.textPrimary),
                                      const SizedBox(width: 6),
                                      Text(
                                        c.$2,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          color: isSelected ? Colors.white : ClayColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // ── Ukuran ──
                          const Text(
                            'Ukuran Karung / Container',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: _sizes.map((s) {
                              final isSelected = state.wasteSize == s.$1;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    ref.read(wasteStateProvider.notifier).setWasteInfo(size: s.$1);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? ClayColors.primary.withValues(alpha: 0.1) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? ClayColors.primary : ClayColors.divider,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          s.$1 == 'small'
                                              ? Icons.shopping_bag_outlined
                                              : s.$1 == 'medium'
                                                  ? Icons.shopping_bag
                                                  : Icons.shopping_basket,
                                          color: isSelected ? ClayColors.primary : ClayColors.textSecondary,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          s.$2,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            color: isSelected ? ClayColors.primary : ClayColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // ── Berat ──
                          const Text(
                            'Estimasi Berat (opsional)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Contoh: 2.5',
                              suffixText: 'kg',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onChanged: (v) {
                              final weight = double.tryParse(v) ?? 0;
                              ref.read(wasteStateProvider.notifier).setWasteInfo(weight: weight);
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── Catatan ──
                          const Text(
                            'Catatan untuk Kurir (opsional)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _notesController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Taruh di depan pagar, sampah organik dapur',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onChanged: (v) {
                              ref.read(wasteStateProvider.notifier).setWasteInfo(notes: v);
                            },
                          ),

                          const SizedBox(height: 20),

                          // ── Estimate / Continue button ──
                          if (_canEstimate(state))
                            ClayButton(
                              label: state.estimate != null ? 'Lanjutkan' : 'Cek Harga Jemput',
                              isLoading: state.isLoading,
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      if (state.estimate != null) {
                                        context.push('/waste/confirm');
                                      } else {
                                        ref.read(wasteStateProvider.notifier).estimateFare();
                                      }
                                    },
                            ),

                          if (state.error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              state.error!,
                              style: const TextStyle(color: ClayColors.error, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canEstimate(WasteState state) {
    return state.pickupLat != null &&
        state.destLat != null &&
        state.wasteCategory.isNotEmpty &&
        state.wasteSize.isNotEmpty;
  }

  Widget _buildEstimateCard(WasteState state) {
    final fare = state.estimate!['fare_estimate'] as int;
    final fareAfterPromo = state.estimate!['fare_after_promo'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClayColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ClayColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.route, size: 16, color: ClayColors.primaryDark),
              const SizedBox(width: 6),
              Text('${state.distanceKm} km', style: const TextStyle(fontWeight: FontWeight.w600, color: ClayColors.primaryDark)),
              Container(width: 4, height: 4, margin: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: ClayColors.primaryDark, shape: BoxShape.circle)),
              Icon(Icons.schedule, size: 16, color: ClayColors.primaryDark),
              const SizedBox(width: 6),
              Text('~${state.durationMin} menit', style: const TextStyle(fontWeight: FontWeight.w600, color: ClayColors.primaryDark)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Biaya Jemput', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (fareAfterPromo != fare) ...[
                    Text('Rp${_formatCurrency(fare)}', style: const TextStyle(fontSize: 13, color: ClayColors.textSecondary, decoration: TextDecoration.lineThrough)),
                  ],
                  Text('Rp${_formatCurrency(fareAfterPromo)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: ClayColors.primaryDark)),
                ],
              ),
            ],
          ),
        ],
      ),
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
        ref.read(wasteStateProvider.notifier).setPickupLocation(lat, lng, address);
      } else {
        ref.read(wasteStateProvider.notifier).setDestLocation(lat, lng, address);
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

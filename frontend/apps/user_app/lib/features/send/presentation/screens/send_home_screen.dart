import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../location/presentation/screens/location_picker_screen.dart';
import '../providers/send_provider.dart';

class SendHomeScreen extends ConsumerStatefulWidget {
  const SendHomeScreen({super.key});

  @override
  ConsumerState<SendHomeScreen> createState() => _SendHomeScreenState();
}

class _SendHomeScreenState extends ConsumerState<SendHomeScreen> {
  final _weightController = TextEditingController();
  final _descController = TextEditingController();

  static const _categories = [
    ('document', 'Dokumen'),
    ('food', 'Makanan'),
    ('electronics', 'Elektronik'),
    ('clothing', 'Pakaian'),
    ('fragile', 'Barang Rapuh'),
    ('other', 'Lainnya'),
  ];

  static const _sizes = [
    ('small', 'Kecil'),
    ('medium', 'Sedang'),
    ('large', 'Besar'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sendStateProvider.notifier).resetSend();
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendStateProvider);

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
                      const Text(
                        'Send a package',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Location inputs
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
                              GestureDetector(
                                onTap: () => _pickLocation(isPickup: true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          state.pickupAddress.isNotEmpty ? state.pickupAddress : 'Lokasi jemput',
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
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          state.destAddress.isNotEmpty ? state.destAddress : 'Alamat tujuan',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: state.destAddress.isNotEmpty ? ClayColors.textPrimary : ClayColors.textSecondary,
                                            fontWeight: state.destAddress.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Estimate result ──
                          if (state.estimate != null) ...[
                            _buildEstimateCard(state),
                            const SizedBox(height: 20),
                          ],

                          // ── Package category ──
                          const Text(
                            'Jenis Paket',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((c) {
                              final isSelected = state.packageCategory == c.$1;
                              return GestureDetector(
                                onTap: () {
                                  ref.read(sendStateProvider.notifier).setPackageInfo(category: c.$1);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? ClayColors.primary : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? ClayColors.primary : ClayColors.divider,
                                    ),
                                  ),
                                  child: Text(
                                    c.$2,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? Colors.white : ClayColors.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // ── Package size ──
                          const Text(
                            'Ukuran Paket',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: _sizes.map((s) {
                              final isSelected = state.packageSize == s.$1;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    ref.read(sendStateProvider.notifier).setPackageInfo(size: s.$1);
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
                                              ? Icons.inventory_2_outlined
                                              : s.$1 == 'medium'
                                                  ? Icons.inventory_outlined
                                                  : Icons.warehouse_outlined,
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

                          // ── Weight ──
                          const Text(
                            'Berat (opsional)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Contoh: 0.5',
                              suffixText: 'kg',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onChanged: (v) {
                              final weight = double.tryParse(v) ?? 0;
                              ref.read(sendStateProvider.notifier).setPackageInfo(weight: weight);
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── Description ──
                          const Text(
                            'Deskripsi (opsional)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _descController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Dokumen penting',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onChanged: (v) {
                              ref.read(sendStateProvider.notifier).setPackageInfo(description: v);
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── Fragile toggle ──
                          Row(
                            children: [
                              const Text(
                                'Barang Rapuh',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                              ),
                              const Spacer(),
                              Switch.adaptive(
                                value: state.isFragile,
                                activeColor: ClayColors.primary,
                                onChanged: (v) {
                                  ref.read(sendStateProvider.notifier).setPackageInfo(isFragile: v);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── Estimate / Continue button ──
                          if (_canEstimate(state))
                            ClayButton(
                              label: state.estimate != null ? 'Lanjutkan' : 'Estimasi Harga',
                              isLoading: state.isLoading,
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      if (state.estimate != null) {
                                        context.push('/send/confirm');
                                      } else {
                                        ref.read(sendStateProvider.notifier).estimateFare();
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

  bool _canEstimate(SendState state) {
    return state.pickupLat != null &&
        state.destLat != null &&
        state.packageCategory.isNotEmpty &&
        state.packageSize.isNotEmpty;
  }

  Widget _buildEstimateCard(SendState state) {
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
              const Text('Estimasi Ongkir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
        ref.read(sendStateProvider.notifier).setPickupLocation(lat, lng, address);
      } else {
        ref.read(sendStateProvider.notifier).setDestLocation(lat, lng, address);
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

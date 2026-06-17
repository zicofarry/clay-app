import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';
import '../../../../shared/widgets.dart';
import '../../../auth/presentation/providers/driver_auth_provider.dart';
import '../../../auth/data/driver_auth_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _vehicleTypeC = TextEditingController();
  final _vehicleBrandC = TextEditingController();
  final _vehicleModelC = TextEditingController();
  final _vehicleYearC = TextEditingController();
  final _vehicleColorC = TextEditingController();
  final _plateC = TextEditingController();

  String _email = '';
  bool _isSaving = false;
  bool _hasDriverProfile = false;

  @override
  void initState() {
    super.initState();
    final d = ref.read(driverAuthProvider).driver;
    _nameC.text = d?['name']?.toString() ?? '';
    _phoneC.text = d?['phone']?.toString() ?? '';
    _email = d?['email']?.toString() ?? RegistrationCache.email ?? '';
    _vehicleTypeC.text = d?['vehicle_type']?.toString() ?? d?['vehicle']?.toString() ?? '';
    _vehicleBrandC.text = d?['vehicle_brand']?.toString() ?? '';
    _vehicleModelC.text = d?['vehicle_model']?.toString() ?? '';
    _vehicleYearC.text = d?['vehicle_year']?.toString() ?? '';
    _vehicleColorC.text = d?['vehicle_color']?.toString() ?? '';
    _plateC.text = d?['plate']?.toString() ?? '';
    _hasDriverProfile = (_vehicleBrandC.text.isNotEmpty || _plateC.text.isNotEmpty);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final api = ClayApi.instance;
      try {
        await api.dio.get(ApiEndpoints.getProfile);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          try {
            await api.dio.post(ApiEndpoints.getProfile, data: {
              'full_name': _nameC.text.trim().isNotEmpty ? _nameC.text.trim() : 'Driver',
            });
          } catch (_) {}
        }
      }
      await ref.read(driverAuthProvider.notifier).refreshProfile();
      if (!mounted) return;
      final fresh = ref.read(driverAuthProvider).driver;
      if (fresh != null) {
        _nameC.text = fresh['name']?.toString() ?? _nameC.text;
        _phoneC.text = fresh['phone']?.toString() ?? _phoneC.text;
        _vehicleTypeC.text = fresh['vehicle_type']?.toString() ?? fresh['vehicle']?.toString() ?? _vehicleTypeC.text;
        _vehicleBrandC.text = fresh['vehicle_brand']?.toString() ?? _vehicleBrandC.text;
        _vehicleModelC.text = fresh['vehicle_model']?.toString() ?? _vehicleModelC.text;
        _vehicleYearC.text = fresh['vehicle_year']?.toString() ?? _vehicleYearC.text;
        _vehicleColorC.text = fresh['vehicle_color']?.toString() ?? _vehicleColorC.text;
        _plateC.text = fresh['plate']?.toString() ?? _plateC.text;
        setState(() {
          _hasDriverProfile = (_vehicleBrandC.text.isNotEmpty || _plateC.text.isNotEmpty);
        });
      }
    });
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _vehicleTypeC.dispose();
    _vehicleBrandC.dispose();
    _vehicleModelC.dispose();
    _vehicleYearC.dispose();
    _vehicleColorC.dispose();
    _plateC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    String? successMsg;
    String? errorMsg;
    bool userOk = false;
    bool driverOk = false;

    try {
      final api = ClayApi.instance;

      try {
        try {
          await api.dio.post(
            ApiEndpoints.updateProfile,
            data: {
              'full_name': _nameC.text.trim(),
            },
          );
          userOk = true;
        } on DioException {
          try {
            await api.dio.put(
              ApiEndpoints.updateProfile,
              data: {
                'full_name': _nameC.text.trim(),
              },
            );
            userOk = true;
          } on DioException catch (e) {
            final data = e.response?.data;
            errorMsg = data is Map
                ? (data['message']?.toString() ?? e.message ?? 'Gagal memperbarui data diri')
                : (e.message ?? 'Gagal memperbarui data diri');
          }
        }
      } catch (e) {
        errorMsg = e.toString();
      }

      final hasVehicleData = _vehicleBrandC.text.trim().isNotEmpty || _plateC.text.trim().isNotEmpty;

      if (userOk && hasVehicleData) {
          try {
            final ts = DateTime.now().millisecondsSinceEpoch.toString();
            final driverPayload = {
              'vehicle_type': _vehicleTypeC.text.trim().isNotEmpty ? _vehicleTypeC.text.trim() : 'motor',
              'vehicle_brand': _vehicleBrandC.text.trim(),
              'vehicle_model': _vehicleModelC.text.trim(),
              'vehicle_year': int.tryParse(_vehicleYearC.text.trim()) ?? 2024,
              'vehicle_color': _vehicleColorC.text.trim(),
              'plate_number': _plateC.text.trim(),
            };
            try {
              await api.dio.post(
                ApiEndpoints.driverRegister,
                data: {
                  ...driverPayload,
                  'sim_number': 'SIM-$ts',
                  'ktp_number': 'KTP-$ts',
                },
              );
              driverOk = true;
            } on DioException catch (e) {
              if (e.response?.statusCode == 409) {
                try {
                  await api.dio.get(ApiEndpoints.driverProfile);
                  await api.dio.put(
                    ApiEndpoints.driverProfile,
                    data: driverPayload,
                  );
                  driverOk = true;
                } on DioException {
                  errorMsg = 'Nomor plat "${_plateC.text.trim()}" sudah terdaftar. Gunakan plat lain.';
                }
              } else {
                rethrow;
              }
            }
        } on DioException catch (e) {
          final data = e.response?.data;
          errorMsg = data is Map
              ? (data['message']?.toString() ?? e.message ?? 'Gagal menyimpan data kendaraan')
              : (e.message ?? 'Gagal menyimpan data kendaraan');
        } catch (e) {
          errorMsg = e.toString();
        }
      } else if (userOk && !hasVehicleData) {
        driverOk = true;
      }

      if (userOk && driverOk) {
        successMsg = 'Profil berhasil diperbarui';

        final patch = <String, dynamic>{
          'name': _nameC.text.trim(),
          'phone': _phoneC.text.trim(),
        };
        if (hasVehicleData) {
          patch['vehicle_type'] = _vehicleTypeC.text.trim();
          patch['vehicle_brand'] = _vehicleBrandC.text.trim();
          patch['vehicle_model'] = _vehicleModelC.text.trim();
          patch['vehicle_year'] = _vehicleYearC.text.trim();
          patch['vehicle_color'] = _vehicleColorC.text.trim();
          patch['plate'] = _plateC.text.trim();
        }
        ref.read(driverAuthProvider.notifier).updateDriverProfile(patch);
        await ref.read(driverAuthProvider.notifier).refreshProfile();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        if (successMsg != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(successMsg), backgroundColor: ClayColors.green),
          );
          context.pop();
        } else if (errorMsg != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: ClayColors.accent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: softShadow(),
                      child: const Center(
                        child: Icon(Icons.arrow_back, size: 20, color: ClayColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Edit Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Data Diri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: softShadow(),
                      child: Column(
                        children: [
                          ClayTextField(
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama lengkap',
                            controller: _nameC,
                            prefixIcon: const Icon(Icons.person_outline, color: ClayColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: ClayColors.muted.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.email_outlined, size: 18, color: ClayColors.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Email', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
                                      const SizedBox(height: 2),
                                      Text(_email.isEmpty ? '-' : _email, style: const TextStyle(fontSize: 14, color: ClayColors.textPrimary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: ClayColors.muted.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 18, color: ClayColors.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Nomor Telepon', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
                                      const SizedBox(height: 2),
                                      Text(_phoneC.text.isEmpty ? '-' : _phoneC.text, style: const TextStyle(fontSize: 14, color: ClayColors.textPrimary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text('Data Kendaraan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: softShadow(),
                      child: Column(
                        children: [
                          ClayTextField(
                            label: 'Jenis Kendaraan',
                            hint: 'Motor / Mobil',
                            controller: _vehicleTypeC,
                            prefixIcon: const Icon(Icons.directions_car_outlined, color: ClayColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ClayTextField(
                            label: 'Merk',
                            hint: 'Masukkan merk kendaraan',
                            controller: _vehicleBrandC,
                            prefixIcon: const Icon(Icons.directions_car_outlined, color: ClayColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ClayTextField(
                            label: 'Model',
                            hint: 'Masukkan model kendaraan',
                            controller: _vehicleModelC,
                            prefixIcon: const Icon(Icons.directions_car_outlined, color: ClayColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ClayTextField(
                                  label: 'Tahun',
                                  hint: '2024',
                                  controller: _vehicleYearC,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: ClayColors.textSecondary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClayTextField(
                                  label: 'Warna',
                                  hint: 'Putih',
                                  controller: _vehicleColorC,
                                  prefixIcon: const Icon(Icons.palette_outlined, color: ClayColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClayTextField(
                            label: 'Nomor Plat',
                            hint: 'B 1234 XYZ',
                            controller: _plateC,
                            prefixIcon: const Icon(Icons.credit_card_outlined, color: ClayColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    ClayButton(
                      label: 'Simpan Perubahan',
                      onPressed: _save,
                      isLoading: _isSaving,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

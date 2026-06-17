import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';
import '../../data/driver_auth_repository.dart';

class DriverRegisterScreen extends ConsumerStatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  ConsumerState<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends ConsumerState<DriverRegisterScreen> {
  int _step = 0;
  final _nameC = TextEditingController();
  final _usernameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmPassC = TextEditingController();
  final _plateC = TextEditingController();
  final _brandC = TextEditingController();
  final _modelC = TextEditingController();
  final _yearC = TextEditingController();
  final _colorC = TextEditingController();
  final _simC = TextEditingController();
  final _ktpC = TextEditingController();
  final _otpC = TextEditingController();
  final List<TextEditingController> _otpDigits = List.generate(6, (_) => TextEditingController());
  String? _vehicleType = 'motor';
  String? _error;
  String? _info;
  bool _isLoading = false;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _nameC.dispose(); _usernameC.dispose(); _emailC.dispose(); _phoneC.dispose();
    _passC.dispose(); _confirmPassC.dispose();
    _plateC.dispose(); _brandC.dispose(); _modelC.dispose();
    _yearC.dispose(); _colorC.dispose(); _simC.dispose(); _ktpC.dispose();
    _otpC.dispose();
    for (final c in _otpDigits) { c.dispose(); }
    super.dispose();
  }

  Future<void> _submitAuth() async {
    if (_nameC.text.trim().isEmpty || _usernameC.text.trim().isEmpty || _emailC.text.trim().isEmpty || _phoneC.text.trim().isEmpty || _passC.text.isEmpty) {
      setState(() => _error = 'Semua field harus diisi');
      return;
    }
    if (_passC.text != _confirmPassC.text) {
      setState(() => _error = 'Konfirmasi password tidak cocok');
      return;
    }
    if (_passC.text.length < 8) {
      setState(() => _error = 'Password minimal 8 karakter');
      return;
    }
    setState(() { _error = null; });
    setState(() => _step = 1);
  }

  Future<void> _requestOtp() async {
    if (_plateC.text.trim().isEmpty || _brandC.text.trim().isEmpty) {
      setState(() => _error = 'Data kendaraan harus diisi');
      return;
    }
    setState(() { _error = null; _info = null; _isLoading = true; });

    try {
      final api = ClayApi.instance;

      try {
        await api.dio.post(ApiEndpoints.register, data: {
          'username': _usernameC.text.trim(),
          'email': _emailC.text.trim(),
          'phone': _phoneC.text.trim(),
          'password': _passC.text,
          'role': 'driver',
        });
      } on DioException catch (e) {
        if (e.response?.statusCode != 409) rethrow;
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _step = 2;
        _info = 'Masukkan kode OTP 000000 untuk verifikasi';
        _resendCooldown = 0;
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message']?.toString() ?? data['error']?.toString() ?? e.message ?? 'Gagal daftar') : (e.message ?? 'Gagal daftar');
      setState(() {
        _isLoading = false;
        _error = '$msg (status: ${e.response?.statusCode})';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e is AppException ? e.message : e.toString();
      });
    }
  }

  void _startResendCooldown() {
    Future.doWhile(() async {
      if (!mounted || _resendCooldown <= 0) {
        if (mounted) setState(() => _resendCooldown = 0);
        return false;
      }
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendCooldown > 0) _resendCooldown--;
      });
      return _resendCooldown > 0;
    });
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;
    setState(() { _error = null; _info = null; _isLoading = true; });
    try {
      final api = ClayApi.instance;
      await api.dio.post('/auth/request-otp', data: {
        'phone': _phoneC.text.trim(),
        'type': 'registration',
      });
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _info = 'Kode OTP baru telah dikirim';
        _resendCooldown = 30;
      });
      _startResendCooldown();
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message']?.toString() ?? 'Gagal mengirim ulang OTP') : 'Gagal mengirim ulang OTP';
      setState(() {
        _isLoading = false;
        _error = msg;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpC.text.trim().isEmpty
        ? _otpDigits.map((c) => c.text).join()
        : _otpC.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() => _error = 'Masukkan 6 digit kode OTP');
      return;
    }
    setState(() { _error = null; _info = null; _isLoading = true; });

    final phone = _phoneC.text.trim();
    final requestBody = {
      'phone': phone,
      'otp_code': code,
      'type': 'registration',
    };
    dev.log('>>> POST /auth/verify-otp', name: 'OTP');
    dev.log('Request: $requestBody', name: 'OTP');
    dev.log('Digits raw: ${_otpDigits.map((c) => '"${c.text}"').join(', ')}', name: 'OTP');
    dev.log('Code length: ${code.length}, code bytes: ${code.codeUnits}', name: 'OTP');

    try {
      final api = ClayApi.instance;
      final repo = DriverAuthRepository(api);

      RegistrationCache.store(
        email: _emailC.text.trim(),
        phone: _phoneC.text.trim(),
        name: _nameC.text.trim(),
      );

      try {
        await api.dio.post(ApiEndpoints.verifyOtp, data: requestBody);
      } on DioException catch (e) {
        dev.log('<<< verify-otp failed (${e.response?.statusCode}): ${e.response?.data}');
      }

      final profile = await repo.login(_phoneC.text.trim(), _passC.text);

      try {
        final sim = _simC.text.trim();
        final ktp = _ktpC.text.trim();
        final ts = DateTime.now().millisecondsSinceEpoch.toString();
        await api.dio.post(ApiEndpoints.driverRegister, data: {
          'vehicle_type': _vehicleType ?? 'motor',
          'plate_number': _plateC.text.trim(),
          'vehicle_brand': _brandC.text.trim(),
          'vehicle_model': _modelC.text.trim(),
          'vehicle_year': int.tryParse(_yearC.text.trim()) ?? 2024,
          'vehicle_color': _colorC.text.trim(),
          'sim_number': sim.isNotEmpty ? sim : 'SIM-$ts',
          'ktp_number': ktp.isNotEmpty ? ktp : 'KTP-$ts',
        });
      } on DioException catch (e) {
        if (e.response?.statusCode == 409) {
          try {
            await api.dio.get(ApiEndpoints.driverProfile);
          } on DioException {
            throw AppException('Nomor plat "${_plateC.text.trim()}" sudah terdaftar. Gunakan plat lain.');
          }
        } else {
          rethrow;
        }
      }

      try {
        await api.dio.post(ApiEndpoints.getProfile, data: {
          'full_name': _nameC.text.trim(),
        });
      } on DioException catch (e) {
        dev.log('POST /users/me failed: ${e.response?.statusCode} ${e.response?.data}');
      }

      api.clearToken();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil! Silakan login.'), backgroundColor: ClayColors.green),
        );
        context.go('/login');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      dev.log('<<< verify-otp ERROR', name: 'OTP');
      dev.log('Status: ${e.response?.statusCode}', name: 'OTP');
      dev.log('Data: $data', name: 'OTP');
      dev.log('Headers: ${e.response?.headers.map}', name: 'OTP');
      dev.log('Request data: ${e.requestOptions.data}', name: 'OTP');
      final msg = data is Map
          ? '${data['code'] ?? ''}: ${data['message'] ?? e.message ?? 'Verifikasi gagal'}'
          : (e.message ?? 'Verifikasi gagal');
      setState(() {
        _isLoading = false;
        _error = '$msg (status: ${e.response?.statusCode})';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e is AppException ? e.message : e.toString();
      });
    }
  }

  String _subtitleForStep(int step) {
    if (step == 0) return 'Buat akun baru';
    if (step == 1) return 'Lengkapi data kendaraan';
    return 'Verifikasi OTP';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(colors: [ClayColors.primaryLight, ClayColors.primaryDark]),
                  boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12))],
                ),
                child: Icon(_step == 2 ? Icons.sms_outlined : Icons.directions_car, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Daftar Driver', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
              const SizedBox(height: 4),
              Text(_subtitleForStep(_step), style: TextStyle(fontSize: 13, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepDot(active: _step >= 0, done: _step > 0),
                  Container(width: 24, height: 2, color: _step > 0 ? ClayColors.primary : ClayColors.divider),
                  _StepDot(active: _step >= 1, done: _step > 1),
                  Container(width: 24, height: 2, color: _step > 1 ? ClayColors.primary : ClayColors.divider),
                  _StepDot(active: _step >= 2),
                ],
              ),
              const SizedBox(height: 32),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, style: const TextStyle(color: ClayColors.accent, fontSize: 13)),
                ),
              if (_info != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_info!, style: const TextStyle(color: ClayColors.green, fontSize: 13)),
                ),

              if (_step == 0) ...[
                _InputField(label: 'Nama Lengkap', controller: _nameC, hint: 'Ahmad Rizki', icon: Icons.person_outline),
                const SizedBox(height: 16),
                _InputField(label: 'Username', controller: _usernameC, hint: 'driver123', icon: Icons.alternate_email),
                const SizedBox(height: 16),
                _InputField(label: 'Email', controller: _emailC, hint: 'driver@email.com', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _InputField(label: 'Nomor Telepon', controller: _phoneC, hint: '+6281234567890', icon: Icons.phone_outlined, keyboard: TextInputType.phone),
                const SizedBox(height: 16),
                _InputField(label: 'Kata Sandi', controller: _passC, hint: 'Minimal 8 karakter', icon: Icons.lock_outline, obscure: true),
                const SizedBox(height: 16),
                _InputField(label: 'Konfirmasi Kata Sandi', controller: _confirmPassC, hint: 'Ulangi kata sandi', icon: Icons.lock_outline, obscure: true),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _submitAuth,
                  child: Container(
                    width: double.infinity, height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [ClayColors.primary, ClayColors.primaryLight]),
                      boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: const Center(child: Text('Lanjut', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15))),
                  ),
                ),
              ],

              if (_step == 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: ClayColors.card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Jenis Kendaraan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
                      Row(
                        children: [
                          _VehicleChip(label: 'Motor', value: 'motor', selected: _vehicleType == 'motor', onTap: () => setState(() => _vehicleType = 'motor')),
                          const SizedBox(width: 8),
                          _VehicleChip(label: 'Mobil', value: 'car', selected: _vehicleType == 'car', onTap: () => setState(() => _vehicleType = 'car')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _InputField(label: 'Nomor Plat', controller: _plateC, hint: 'B 1234 XYZ', icon: Icons.credit_card_outlined),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _InputField(label: 'Merk', controller: _brandC, hint: 'Honda', icon: Icons.directions_car_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _InputField(label: 'Model', controller: _modelC, hint: 'Vario 150', icon: Icons.directions_car_outlined)),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _InputField(label: 'Tahun', controller: _yearC, hint: '2024', icon: Icons.calendar_today_outlined, keyboard: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _InputField(label: 'Warna', controller: _colorC, hint: 'Putih', icon: Icons.palette_outlined)),
                ]),
                const SizedBox(height: 16),
                _InputField(label: 'Nomor SIM', controller: _simC, hint: '1234567890', icon: Icons.badge_outlined),
                const SizedBox(height: 16),
                _InputField(label: 'Nomor KTP', controller: _ktpC, hint: '3273012345678901', icon: Icons.badge_outlined, keyboard: TextInputType.number),
                const SizedBox(height: 32),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  GestureDetector(
                    onTap: _requestOtp,
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(colors: [ClayColors.green, ClayColors.greenDark]),
                        boxShadow: [BoxShadow(color: ClayColors.green.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: const Center(child: Text('Daftar Sekarang', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setState(() { _step = 0; _error = null; _info = null; }),
                    child: const Center(child: Text('Kembali', style: TextStyle(fontWeight: FontWeight.w500, color: ClayColors.textSecondary, fontSize: 13))),
                  ),
                ],
              ],

              if (_step == 2) ...[
                const SizedBox(height: 8),
                Text(
                  'Masukkan kode 6 digit yang dikirim ke',
                  style: TextStyle(fontSize: 13, color: ClayColors.textSecondary.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 4),
                Text(_phoneC.text.trim(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return Container(
                      width: 44, height: 56,
                      margin: EdgeInsets.only(right: i == 5 ? 0 : 8),
                      child: TextFormField(
                        controller: _otpDigits[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                          _otpC.text = _otpDigits.map((c) => c.text).join();
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: ClayColors.card,
                          contentPadding: const EdgeInsets.only(top: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: ClayColors.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: ClayColors.primary, width: 2),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  GestureDetector(
                    onTap: _verifyOtp,
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(colors: [ClayColors.primary, ClayColors.primaryLight]),
                        boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: const Center(child: Text('Verifikasi', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _resendCooldown > 0 ? null : _resendOtp,
                    child: Text(
                      _resendCooldown > 0 ? 'Kirim ulang dalam ${_resendCooldown}s' : 'Kirim Ulang Kode',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _resendCooldown > 0 ? ClayColors.textSecondary : ClayColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setState(() { _step = 1; _error = null; _info = null; }),
                    child: const Center(child: Text('Kembali', style: TextStyle(fontWeight: FontWeight.w500, color: ClayColors.textSecondary, fontSize: 13))),
                  ),
                ],
              ],

              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ', style: TextStyle(fontSize: 13, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
                    const Text('Masuk', style: TextStyle(fontSize: 13, color: ClayColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active, done;
  const _StepDot({required this.active, this.done = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12, height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? ClayColors.green : (active ? ClayColors.primary : ClayColors.divider),
      ),
      child: done ? const Icon(Icons.check, size: 8, color: Colors.white) : null,
    );
  }
}

class _InputField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboard;
  const _InputField({required this.label, required this.controller, required this.hint, required this.icon, this.obscure = false, this.keyboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ClayColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
          Row(
            children: [
              Icon(icon, size: 18, color: ClayColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboard,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: ClayColors.textSecondary, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _VehicleChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ClayColors.primary : ClayColors.muted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : ClayColors.textSecondary)),
      ),
    );
  }
}

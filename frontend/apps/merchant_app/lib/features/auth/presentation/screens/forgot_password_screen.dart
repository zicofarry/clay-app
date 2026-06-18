import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/merchant_auth_provider.dart';

enum ForgotPasswordStep {
  phoneInput,
  otpVerify,
  resetPassword,
  success,
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.phoneInput;

  final _phoneFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _phoneC = TextEditingController();
  final _otpC = TextEditingController();
  final List<TextEditingController> _otpDigits = List.generate(6, (_) => TextEditingController());
  
  final _newPasswordC = TextEditingController();
  final _confirmPasswordC = TextEditingController();

  String? _resetToken;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _phoneC.dispose();
    _otpC.dispose();
    for (final c in _otpDigits) {
      c.dispose();
    }
    _newPasswordC.dispose();
    _confirmPasswordC.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendCooldown > 0) _resendCooldown--;
      });
      return _resendCooldown > 0;
    });
  }

  Future<void> _handleSendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;
    
    final phone = _phoneC.text.trim();
    final ok = await ref.read(merchantAuthProvider.notifier).sendForgotPasswordOtp(phone);
    if (ok && mounted) {
      setState(() {
        _currentStep = ForgotPasswordStep.otpVerify;
      });
      _startResendCooldown();
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpC.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit kode OTP'), backgroundColor: Colors.orange),
      );
      return;
    }

    final phone = _phoneC.text.trim();
    final token = await ref.read(merchantAuthProvider.notifier).verifyOtpForReset(phone, code);
    if (token != null && mounted) {
      setState(() {
        _resetToken = token;
        _currentStep = ForgotPasswordStep.resetPassword;
      });
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    if (_resetToken == null) return;

    final phone = _phoneC.text.trim();
    final ok = await ref.read(merchantAuthProvider.notifier).resetPassword(
      phone: phone,
      resetToken: _resetToken!,
      newPassword: _newPasswordC.text,
    );

    if (ok && mounted) {
      setState(() {
        _currentStep = ForgotPasswordStep.success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(merchantAuthProvider);

    ref.listen(merchantAuthProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: ClayColors.error),
        );
      }
    });

    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep != ForgotPasswordStep.success
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: ClayColors.textPrimary),
                onPressed: () {
                  if (_currentStep == ForgotPasswordStep.otpVerify) {
                    setState(() => _currentStep = ForgotPasswordStep.phoneInput);
                  } else if (_currentStep == ForgotPasswordStep.resetPassword) {
                    setState(() => _currentStep = ForgotPasswordStep.otpVerify);
                  } else {
                    context.pop();
                  }
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentStep == ForgotPasswordStep.phoneInput)
                  _buildPhoneInputSection(authState)
                else if (_currentStep == ForgotPasswordStep.otpVerify)
                  _buildOtpVerifySection(authState)
                else if (_currentStep == ForgotPasswordStep.resetPassword)
                  _buildResetPasswordSection(authState)
                else if (_currentStep == ForgotPasswordStep.success)
                  _buildSuccessSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // View 1: Input Phone
  Widget _buildPhoneInputSection(MerchantAuthState state) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ClayColors.primaryDark.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.lock_reset, size: 38, color: ClayColors.primaryDark),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lupa Kata Sandi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan nomor telepon terdaftar Anda. Kami akan mengirimkan kode OTP untuk mengatur ulang kata sandi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: ClayColors.textSecondary.withValues(alpha: 0.8), height: 1.4),
          ),
          const SizedBox(height: 32),
          ClayTextField(
            label: 'Nomor Telepon',
            hint: 'Contoh: +628123456789',
            controller: _phoneC,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Nomor HP harus diisi';
              final clean = val.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
              if (clean.length < 9) return 'Nomor HP tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ClayButton(
            label: 'Kirim OTP',
            isLoading: state.isLoading,
            onPressed: _handleSendOtp,
          ),
        ],
      ),
    );
  }

  // View 2: OTP Verify
  Widget _buildOtpVerifySection(MerchantAuthState state) {
    return Column(
      children: [
        const Text(
          'Kode OTP Telah Dikirim',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: ClayColors.textSecondary, fontSize: 13, height: 1.4),
            children: [
              const TextSpan(text: 'Masukkan 6 digit kode yang dikirim ke nomor\n'),
              TextSpan(
                text: _phoneC.text.trim(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // OTP Boxes Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            return Container(
              width: 44,
              height: 52,
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
                  } else if (v.isEmpty && i > 0) {
                    FocusScope.of(context).previousFocus();
                  }
                  _otpC.text = _otpDigits.map((c) => c.text).join();
                },
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ClayColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ClayColors.primaryDark, width: 2),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        const Text(
          'Gunakan OTP "000000" untuk demo/testing',
          style: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),

        ClayButton(
          label: 'Verifikasi OTP',
          isLoading: state.isLoading,
          onPressed: _handleVerifyOtp,
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _resendCooldown > 0 ? null : _handleSendOtp,
              child: Text(
                _resendCooldown > 0 ? 'Kirim ulang OTP (${_resendCooldown}s)' : 'Kirim Ulang OTP',
                style: TextStyle(
                  color: _resendCooldown > 0 ? ClayColors.textSecondary : ClayColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 16, color: ClayColors.divider),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentStep = ForgotPasswordStep.phoneInput;
                  for (final c in _otpDigits) {
                    c.clear();
                  }
                  _otpC.clear();
                });
              },
              child: const Text(
                'Ganti Nomor HP',
                style: TextStyle(color: ClayColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // View 3: Reset Password
  Widget _buildResetPasswordSection(MerchantAuthState state) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        children: [
          const Text(
            'Atur Ulang Kata Sandi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan masukkan kata sandi baru Anda.',
            style: TextStyle(fontSize: 13, color: ClayColors.textSecondary.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 32),
          ClayTextField(
            label: 'Kata Sandi Baru',
            hint: 'Minimal 6 karakter',
            controller: _newPasswordC,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Kata sandi baru harus diisi';
              if (val.length < 6) return 'Kata sandi minimal 6 karakter';
              return null;
            },
          ),
          const SizedBox(height: 16),
          ClayTextField(
            label: 'Konfirmasi Kata Sandi Baru',
            hint: 'Ulangi kata sandi baru',
            controller: _confirmPasswordC,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Konfirmasi kata sandi harus diisi';
              if (val != _newPasswordC.text) return 'Kata sandi tidak cocok';
              return null;
            },
          ),
          const SizedBox(height: 28),
          ClayButton(
            label: 'Simpan Kata Sandi',
            isLoading: state.isLoading,
            onPressed: _handleResetPassword,
          ),
        ],
      ),
    );
  }

  // View 4: Success Screen
  Widget _buildSuccessSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
        ),
        const SizedBox(height: 24),
        const Text(
          'Kata Sandi Berhasil Diubah',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Kata sandi Anda telah berhasil diperbarui. Silakan gunakan kata sandi baru Anda untuk masuk.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: ClayColors.textSecondary.withValues(alpha: 0.8), height: 1.4),
        ),
        const SizedBox(height: 32),
        ClayButton(
          label: 'Kembali Ke Halaman Login',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}

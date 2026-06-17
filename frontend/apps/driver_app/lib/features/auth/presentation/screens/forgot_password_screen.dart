import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';
import '../../../../shared/widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _inputC = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _inputC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _inputC.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email atau nomor telepon'), backgroundColor: ClayColors.accent),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final isEmail = value.contains('@');
      await ClayApi.instance.dio.post(
        'auth/forgot-password',
        data: isEmail ? {'email': value} : {'phone': value},
      );

      if (mounted) setState(() => _isSubmitted = true);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map
          ? (data['message']?.toString() ?? e.message ?? 'Gagal mengirim link reset')
          : (e.message ?? 'Gagal mengirim link reset');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: ClayColors.accent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              const SizedBox(height: 60),

              // Icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(colors: [ClayColors.primaryLight, ClayColors.primaryDark]),
                  boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12))],
                ),
                child: const Icon(Icons.lock_reset, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 24),

              const Text(
                'Lupa Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                _isSubmitted
                    ? 'Link reset password telah dikirim'
                    : 'Masukkan email atau nomor telepon untuk reset password',
                style: TextStyle(fontSize: 13, color: ClayColors.textSecondary.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              if (_isSubmitted) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: softShadow(),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ClayColors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(Icons.check_circle, size: 32, color: ClayColors.green),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Cek email atau SMS Anda',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kami telah mengirimkan link reset password ke ${_inputC.text.trim()}',
                        style: const TextStyle(fontSize: 13, color: ClayColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                ClayButton(
                  label: 'Kirim Ulang',
                  onPressed: () => setState(() => _isSubmitted = false),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ClayColors.primary, width: 1.5),
                      color: ClayColors.card,
                    ),
                    child: const Center(
                      child: Text('Kembali ke Login', style: TextStyle(fontWeight: FontWeight.w600, color: ClayColors.primary, fontSize: 15)),
                    ),
                  ),
                ),
              ] else ...[
                Container(
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
                      Text('Email / Nomor Telepon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 18, color: ClayColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _inputC,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'email@example.com atau +6281234567890',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: ClayColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _isSubmitting ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [ClayColors.primary, ClayColors.primaryLight]),
                      boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Kirim Link Reset', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ingat password? ', style: TextStyle(fontSize: 13, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
                      const Text('Masuk', style: TextStyle(fontSize: 13, color: ClayColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

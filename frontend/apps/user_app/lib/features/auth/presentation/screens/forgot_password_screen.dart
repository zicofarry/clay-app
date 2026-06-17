import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!)),
        );
        ref.read(authStateProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ClayColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: ClayColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lupa Kata Sandi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ClayColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan nomor telepon yang terdaftar. Kami akan mengirim kode OTP untuk mereset kata sandi.',
                  style: TextStyle(
                    fontSize: 14,
                    color: ClayColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                ClayTextField(
                  label: 'Nomor Telepon',
                  hint: 'Sama seperti saat daftar',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Masukkan nomor telepon' : null,
                ),
                const SizedBox(height: 32),
                ClayButton(
                  label: 'Kirim Kode OTP',
                  isLoading: authState.isLoading,
                  onPressed: _onSendOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authStateProvider.notifier).forgotPassword(
        _phoneController.text.trim(),
      );

      if (success && mounted) {
        context.push('/reset-password', extra: {
          'phone': _phoneController.text.trim(),
        });
      }
    }
  }
}

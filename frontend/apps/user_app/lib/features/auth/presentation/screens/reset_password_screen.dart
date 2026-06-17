import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String resetToken;
  const ResetPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.resetToken,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (prev, state) {
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
                  'Buat Kata Sandi Baru',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ClayColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nomor: ${widget.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ClayColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                ClayTextField(
                  label: 'Kata Sandi Baru',
                  hint: 'Masukkan kata sandi baru',
                  controller: _newPasswordController,
                  obscureText: !_showNewPassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_showNewPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Masukkan kata sandi baru';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ClayTextField(
                  label: 'Konfirmasi Kata Sandi',
                  hint: 'Ulangi kata sandi baru',
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Konfirmasi kata sandi';
                    if (v != _newPasswordController.text) return 'Kata sandi tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: ClayColors.error),
                    ),
                  ),
                ClayButton(
                  label: 'Simpan Kata Sandi',
                  isLoading: authState.isLoading,
                  onPressed: _onReset,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authStateProvider.notifier).resetPassword(
        phone: widget.phoneNumber,
        resetToken: widget.resetToken,
        newPassword: _newPasswordController.text,
      );

      final state = ref.read(authStateProvider);
      if (state.error == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kata sandi berhasil direset')),
        );
        context.go('/login');
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (_, state) {
      if (state.authResponse != null) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: ClayColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/logo/logo_utama.png',
                  height: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Clay',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ClayColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk untuk melanjutkan',
                  style: TextStyle(
                    fontSize: 16,
                    color: ClayColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                ClayTextField(
                  label: 'Nomor Telepon',
                  hint: '+6281234567890',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Masukkan nomor telepon' : null,
                ),
                const SizedBox(height: 20),
                ClayTextField(
                  label: 'Kata Sandi',
                  hint: 'Masukkan kata sandi',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Masukkan kata sandi' : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Lupa kata sandi?'),
                  ),
                ),
                const SizedBox(height: 24),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: ClayColors.error),
                    ),
                  ),
                ClayButton(
                  label: 'Masuk',
                  isLoading: authState.isLoading,
                  onPressed: _onLogin,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? '),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Daftar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authStateProvider.notifier).login(
        _phoneController.text.trim(),
        _passwordController.text,
      );
    }
  }
}

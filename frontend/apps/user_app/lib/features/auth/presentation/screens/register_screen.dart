import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
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
      appBar: AppBar(
        title: const Text('Daftar'),
        backgroundColor: Colors.transparent,
        foregroundColor: ClayColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),
                ClayTextField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Masukkan nama lengkap' : null,
                ),
                const SizedBox(height: 20),
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
                  hint: 'Minimal 8 karakter',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Masukkan kata sandi';
                    if (v.length < 8) return 'Minimal 8 karakter';
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
                  label: 'Daftar',
                  isLoading: authState.isLoading,
                  onPressed: _onRegister,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? '),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Masuk'),
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

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authStateProvider.notifier).register(
        phone: _phoneController.text.trim(),
        name: _nameController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}

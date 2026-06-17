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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (prev, state) {
      if (state.authResponse != null) {
        if (GoRouterState.of(context).uri.toString() == '/register') {
          context.go('/home');
        }
      } else if (state.registered && !state.isLoading) {
        if (GoRouterState.of(context).uri.toString() == '/register') {
          final contact = state.contact ?? '';
          context.push('/otp-verification', extra: {
            'contact': contact,
            'purpose': 'registration',
          });
        }
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
                  hint: 'Contoh: John Doe',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Masukkan nama lengkap' : null,
                ),
                const SizedBox(height: 20),
                ClayTextField(
                  label: 'Username',
                  hint: 'Contoh: johndoe123',
                  controller: _usernameController,
                  prefixIcon: const Icon(Icons.alternate_email_outlined),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Masukkan username' : null,
                ),
                const SizedBox(height: 20),
                ClayTextField(
                  label: 'Email',
                  hint: 'johndoe@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 20),
                ClayTextField(
                  label: 'Nomor Telepon',
                  hint: '0812 3456 7890',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
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
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();

      if (email.isEmpty && phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email atau nomor telepon harus diisi')),
        );
        return;
      }

      ref.read(authStateProvider.notifier).register(
        fullName: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: email.isNotEmpty ? email : null,
        phone: phone.isNotEmpty ? phone : null,
        password: _passwordController.text,
      );
    }
  }
}

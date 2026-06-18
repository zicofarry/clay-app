import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/merchant_auth_provider.dart';

class MerchantLoginScreen extends ConsumerStatefulWidget {
  const MerchantLoginScreen({super.key});

  @override
  ConsumerState<MerchantLoginScreen> createState() => _MerchantLoginScreenState();
}

class _MerchantLoginScreenState extends ConsumerState<MerchantLoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _phoneC = TextEditingController();
  final _passC = TextEditingController();

  @override
  void dispose() {
    _phoneC.dispose();
    _passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(merchantAuthProvider);

    ref.listen(merchantAuthProvider, (_, state) {
      if (state.merchant != null) {
        context.go('/home');
      } else if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: ClayColors.error),
        );
      }
    });

    return Scaffold(
      backgroundColor: ClayColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Logo & Header
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
                  child: const Icon(Icons.store, size: 38, color: ClayColors.primaryDark),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Clay Merchant',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                ),
                Text(
                  'Kelola resto Anda dengan mudah',
                  style: TextStyle(fontSize: 13, color: ClayColors.textSecondary.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 40),

                // Password Login Form
                Form(
                  key: _loginFormKey,
                  child: Column(
                    children: [
                      ClayTextField(
                        label: 'Username / Nomor Telepon',
                        hint: 'Masukkan username atau HP',
                        controller: _phoneC,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Harus diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      ClayTextField(
                        label: 'Kata Sandi',
                        hint: 'Masukkan kata sandi',
                        controller: _passC,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        validator: (val) => val == null || val.isEmpty ? 'Harus diisi' : null,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: const Text(
                            'Lupa Kata Sandi?',
                            style: TextStyle(
                              color: ClayColors.primaryDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ClayButton(
                        label: 'Masuk Ke Toko',
                        isLoading: authState.isLoading,
                        onPressed: () {
                          if (_loginFormKey.currentState?.validate() ?? false) {
                            ref.read(merchantAuthProvider.notifier).login(
                                  _phoneC.text.trim(),
                                  _passC.text,
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/driver_auth_provider.dart';

class DriverLoginScreen extends ConsumerStatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  ConsumerState<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends ConsumerState<DriverLoginScreen> {
  final _phoneC = TextEditingController();
  final _passC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneC.dispose();
    _passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverAuthProvider);

    ref.listen(driverAuthProvider, (_, state) {
      if (state.driver != null) context.go('/home');
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
                const SizedBox(height: 80),
                // Logo area
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(colors: [ClayColors.primaryLight, ClayColors.primaryDark]),
                    boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12))],
                  ),
                  child: const Icon(Icons.directions_car, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text('Clay Driver', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                const SizedBox(height: 8),
                Text('Masuk untuk mulai bekerja', style: TextStyle(fontSize: 14, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
                const SizedBox(height: 48),

                // Phone field
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
                      Text('Nomor Telepon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
                      TextFormField(
                        controller: _phoneC,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '+6281234567890',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: ClayColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Password field
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
                      Text('Kata Sandi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ClayColors.textSecondary.withValues(alpha: 0.8))),
                      TextFormField(
                        controller: _passC,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan kata sandi',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: ClayColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(state.error!, style: const TextStyle(color: ClayColors.accent, fontSize: 13)),
                  ),

                // Login button
                GestureDetector(
                  onTap: state.isLoading ? null : () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ref.read(driverAuthProvider.notifier).login(_phoneC.text.trim(), _passC.text);
                    }
                  },
                  child: Container(
                    width: double.infinity, height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [ClayColors.primary, ClayColors.primaryLight]),
                      boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Center(
                      child: state.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Masuk sebagai Driver', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
                    ),
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

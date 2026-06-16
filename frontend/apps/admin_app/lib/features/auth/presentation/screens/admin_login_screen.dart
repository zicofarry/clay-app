import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/admin_auth_provider.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _phoneC = TextEditingController(text: 'admin@clay.com');
  final _passC = TextEditingController(text: 'admin123');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() { _phoneC.dispose(); _passC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminAuthProvider);
    ref.listen(adminAuthProvider, (_, state) { if (state.admin != null) context.go('/dashboard'); });

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
                Icon(Icons.admin_panel_settings, size: 80, color: ClayColors.primary),
                const SizedBox(height: 16),
                Text('Clay Admin', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ClayColors.primary)),
                const SizedBox(height: 48),
                ClayTextField(label: 'Email / Telepon', controller: _phoneC, prefixIcon: const Icon(Icons.email_outlined)),
                const SizedBox(height: 20),
                ClayTextField(label: 'Kata Sandi', controller: _passC, obscureText: true, prefixIcon: const Icon(Icons.lock_outlined)),
                const SizedBox(height: 32),
                if (state.error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(state.error!, style: const TextStyle(color: ClayColors.error))),
                ClayButton(label: 'Masuk sebagai Admin', isLoading: state.isLoading, onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) ref.read(adminAuthProvider.notifier).login(_phoneC.text.trim(), _passC.text);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

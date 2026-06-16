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
    final state = ref.watch(merchantAuthProvider);

    ref.listen(merchantAuthProvider, (_, state) {
      if (state.merchant != null) context.go('/home');
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
                Icon(Icons.store, size: 80, color: ClayColors.primary),
                const SizedBox(height: 16),
                Text('Clay Merchant', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ClayColors.primary)),
                const SizedBox(height: 48),
                ClayTextField(label: 'Nomor Telepon', hint: '+6281234567890', controller: _phoneC, keyboardType: TextInputType.phone, prefixIcon: const Icon(Icons.phone_outlined)),
                const SizedBox(height: 20),
                ClayTextField(label: 'Kata Sandi', hint: 'Masukkan kata sandi', controller: _passC, obscureText: true, prefixIcon: const Icon(Icons.lock_outlined)),
                const SizedBox(height: 32),
                if (state.error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(state.error!, style: const TextStyle(color: ClayColors.error))),
                ClayButton(label: 'Masuk sebagai Merchant', isLoading: state.isLoading, onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) ref.read(merchantAuthProvider.notifier).login(_phoneC.text.trim(), _passC.text);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

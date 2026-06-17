import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';
import '../../../../shared/widgets.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPassC = TextEditingController();
  final _newPassC = TextEditingController();
  final _confirmPassC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _oldPassC.dispose();
    _newPassC.dispose();
    _confirmPassC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      await ClayApi.instance.dio.put(
        'auth/change-password',
        data: {
          'old_password': _oldPassC.text,
          'new_password': _newPassC.text,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diubah'),
            backgroundColor: ClayColors.green,
          ),
        );
        context.pop();
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map
          ? (data['message']?.toString() ?? e.message ?? 'Gagal mengubah password')
          : (e.message ?? 'Gagal mengubah password');
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        context.pop();
                      } else {
                        context.go('/settings');
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: softShadow(),
                      child: const Center(
                        child: Icon(Icons.arrow_back, size: 20, color: ClayColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Ubah Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: softShadow(),
                        child: Column(
                          children: [
                            ClayTextField(
                              label: 'Password Lama',
                              hint: 'Masukkan password lama',
                              controller: _oldPassC,
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock_outline, color: ClayColors.textSecondary),
                              validator: (v) => (v == null || v.isEmpty) ? 'Password lama wajib diisi' : null,
                            ),
                            const SizedBox(height: 20),
                            ClayTextField(
                              label: 'Password Baru',
                              hint: 'Minimal 6 karakter',
                              controller: _newPassC,
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock_outline, color: ClayColors.textSecondary),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password baru wajib diisi';
                                if (v.length < 6) return 'Password minimal 6 karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            ClayTextField(
                              label: 'Konfirmasi Password Baru',
                              hint: 'Ulangi password baru',
                              controller: _confirmPassC,
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock_outline, color: ClayColors.textSecondary),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                                if (v != _newPassC.text) return 'Password tidak cocok';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      ClayButton(
                        label: 'Simpan Password',
                        onPressed: _submit,
                        isLoading: _isSubmitting,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

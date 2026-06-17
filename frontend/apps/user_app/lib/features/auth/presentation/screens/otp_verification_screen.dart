import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  String _otpCode = '';

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _updateOtpCode() {
    setState(() {
      _otpCode = _otpControllers.map((c) => c.text).join();
    });
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.sms_outlined,
                  size: 64,
                  color: ClayColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Verifikasi OTP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ClayColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan kode OTP yang dikirim ke\n${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ClayColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 336,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        height: 56,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (v) {
                            if (v.isNotEmpty) {
                              if (index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              }
                            } else {
                              if (index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            }
                            _updateOtpCode();
                          },
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: ClayColors.primary, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: ClayColors.primary, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: ClayColors.primary, width: 2),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                if (_otpCode.isNotEmpty && _otpCode.length < 6)
                  Text(
                    'Kode OTP harus 6 digit',
                    style: TextStyle(color: ClayColors.error, fontSize: 12),
                  ),
                const Spacer(),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: ClayColors.error),
                    ),
                  ),
                ClayButton(
                  label: 'Verifikasi',
                  isLoading: authState.isLoading,
                  onPressed: _onVerify,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onVerify() async {
    if (_otpCode.length != 6) return;

    final resetToken = await ref.read(authStateProvider.notifier).verifyResetOtp(
      widget.phoneNumber,
      _otpCode,
    );

    if (resetToken != null && mounted) {
      context.push('/reset-password', extra: {
        'phone': widget.phoneNumber,
        'resetToken': resetToken,
      });
    }
  }
}

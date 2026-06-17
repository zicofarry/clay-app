import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String contact;
  final String purpose; // 'registration' or 'reset'

  const OtpVerificationScreen({
    super.key,
    required this.contact,
    this.purpose = 'reset',
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  String _otpCode = '';
  String? _localError;

  // Timers
  Timer? _validityTimer;
  Timer? _resendTimer;
  int _validitySeconds = 300; // 5 minutes
  int _resendSeconds = 60;    // 60 seconds resend cooldown

  // Animation for Shaking
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startTimers();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: const ShakeCurve()))
        .animate(_shakeController);
  }

  void _startTimers() {
    setState(() {
      _validitySeconds = 300;
      _resendSeconds = 60;
      _localError = null;
    });

    _validityTimer?.cancel();
    _resendTimer?.cancel();

    _validityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_validitySeconds > 0) {
        setState(() {
          _validitySeconds--;
        });
      } else {
        setState(() {
          _localError = 'Kode OTP telah kedaluwarsa. Silakan kirim ulang kode baru.';
        });
        timer.cancel();
      }
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _validityTimer?.cancel();
    _resendTimer?.cancel();
    _shakeController.dispose();
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
      if (_localError != null) {
        _localError = null;
      }
    });

    // Auto-verify once 6 digits are typed and timer is valid
    if (_otpCode.length == 6 && _validitySeconds > 0) {
      _onVerify();
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleResend() async {
    if (_resendSeconds > 0) return;

    final success = await ref.read(authStateProvider.notifier).resendOtp(
      widget.contact,
      widget.purpose,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Kode OTP baru telah dikirim!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      // Reset inputs
      for (final c in _otpControllers) {
        c.clear();
      }
      setState(() {
        _otpCode = '';
      });
      _focusNodes[0].requestFocus();
      _startTimers();
    }
  }

  void _focusFirstEmptyBox() {
    int firstEmptyIndex = 0;
    for (int i = 0; i < 6; i++) {
      if (_otpControllers[i].text.isEmpty) {
        firstEmptyIndex = i;
        break;
      }
    }
    if (firstEmptyIndex == 6) {
      firstEmptyIndex = 5;
    }
    _focusNodes[firstEmptyIndex].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (prev, state) {
      if (state.authResponse != null &&
          widget.purpose == 'registration' &&
          prev?.authResponse == null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(24),
            icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
            title: const Text(
              'Verifikasi Berhasil',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: ClayColors.textPrimary),
            ),
            content: const Text(
              'Selamat! Akun Anda telah berhasil diverifikasi dan aktif. Tap tombol di bawah untuk mulai menggunakan Clay.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: ClayColors.textSecondary, height: 1.4),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              SizedBox(
                width: double.infinity,
                child: ClayButton(
                  label: 'Masuk Ke Aplikasi',
                  onPressed: () {
                    ref.read(authStateProvider.notifier).clearRegistration();
                    Navigator.of(ctx).pop();
                    context.go('/home');
                  },
                ),
              ),
            ],
          ),
        );
      }
      if (state.error != null && !state.isOtpVerified) {
        setState(() {
          _localError = state.error;
          for (final c in _otpControllers) {
            c.clear();
          }
          _otpCode = '';
        });
        _shakeController.forward(from: 0.0);
        _focusNodes[0].requestFocus();
        ref.read(authStateProvider.notifier).clearError();
      } else if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: ClayColors.error,
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      }
    });

    final isExpired = _validitySeconds == 0;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && widget.purpose == 'registration') {
          ref.read(authStateProvider.notifier).clearRegistration();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ClayColors.textPrimary),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Masukkan OTP',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: ClayColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: ClayColors.textSecondary,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Kami mengirim kode verifikasi 6 digit ke '),
                        TextSpan(
                          text: widget.contact,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ClayColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            final hasError = _localError != null;
                            return SizedBox(
                              width: 46,
                              height: 54,
                              child: TextFormField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: hasError ? ClayColors.error : ClayColors.textPrimary,
                                ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(6),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onTap: _focusFirstEmptyBox,
                                onChanged: (v) {
                                  if (v.length > 1) {
                                    final pasted = v.trim();
                                    for (int i = 0; i < 6; i++) {
                                      if (i < pasted.length) {
                                        _otpControllers[i].text = pasted[i];
                                      } else {
                                        _otpControllers[i].clear();
                                      }
                                    }
                                    _focusNodes[5].requestFocus();
                                    _updateOtpCode();
                                    return;
                                  }
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
                                  fillColor: ClayColors.muted,
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: hasError ? ClayColors.error : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: hasError ? ClayColors.error : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: hasError ? ClayColors.error : ClayColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_localError != null)
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: ClayColors.error, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _localError!,
                            style: const TextStyle(
                              color: ClayColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: ClayColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              isExpired
                                  ? 'Kode OTP kedaluwarsa'
                                  : 'Kode OTP berlaku selama ${_formatTime(_validitySeconds)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isExpired ? ClayColors.error : ClayColors.textSecondary,
                                fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_resendSeconds > 0)
                          Text(
                            'Kirim ulang kode dalam ${_resendSeconds}s',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ClayColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _handleResend,
                            style: TextButton.styleFrom(
                              foregroundColor: ClayColors.primaryDark,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'Kirim ulang OTP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ClayButton(
                    label: 'Verifikasi',
                    isLoading: authState.isLoading,
                    onPressed: (_otpCode.length == 6 && !isExpired && !authState.isOtpVerified && !authState.isLoading) ? _onVerify : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onVerify() async {
    if (_otpCode.length != 6) return;

    final currentAuthState = ref.read(authStateProvider);
    if (currentAuthState.isLoading || currentAuthState.isOtpVerified) return;

    if (widget.purpose == 'registration') {
      await ref.read(authStateProvider.notifier).verifyRegistrationOtp(_otpCode);
    } else {
      final resetToken = await ref.read(authStateProvider.notifier).verifyResetOtp(
        widget.contact,
        _otpCode,
      );

      if (resetToken != null && mounted) {
        context.push('/reset-password', extra: {
          'phone': widget.contact,
          'resetToken': resetToken,
        });
      }
    }
  }
}

class ShakeCurve extends Curve {
  const ShakeCurve();

  @override
  double transformInternal(double t) {
    // Sine wave for shaking effect
    return sin(t * 3 * pi);
  }
}

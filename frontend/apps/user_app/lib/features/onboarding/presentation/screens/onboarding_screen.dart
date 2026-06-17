import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Image.asset(
                'assets/logo/logo_utama.png',
                height: 40,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/onboarding/welcome_img.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Text(
                'Selamat datang di CLAY!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ClayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Semua kebutuhan harian jadi lebih gampang. Mau pesan, kirim, atau jalan? Tinggal buka CLAY.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: ClayColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              ClayButton(
                label: 'Masuk',
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 12),
              ClayButton(
                label: 'Belum punya akun? Daftar dulu',
                outlined: true,
                onPressed: () => context.go('/register'),
              ),
              const SizedBox(height: 24),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Dengan masuk atau mendaftar, kamu menyetujui ',
                      style: TextStyle(
                        fontSize: 12,
                        color: ClayColors.textSecondary,
                      ),
                    ),
                    TextSpan(
                      text: 'Ketentuan layanan',
                      style: TextStyle(
                        fontSize: 12,
                        color: ClayColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' dan ',
                      style: TextStyle(
                        fontSize: 12,
                        color: ClayColors.textSecondary,
                      ),
                    ),
                    TextSpan(
                      text: 'Kebijakan privasi',
                      style: TextStyle(
                        fontSize: 12,
                        color: ClayColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' CLAY.',
                      style: TextStyle(
                        fontSize: 12,
                        color: ClayColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

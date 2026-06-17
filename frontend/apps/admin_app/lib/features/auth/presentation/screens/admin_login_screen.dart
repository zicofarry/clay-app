import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  bool _obscurePassword = true;

  @override
  void dispose() { 
    _phoneC.dispose(); 
    _passC.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminAuthProvider);
    ref.listen(adminAuthProvider, (_, state) { 
      if (state.admin != null) context.go('/dashboard'); 
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF757575);
    final inputBgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA);
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE0E0E0);
    const primaryBlue = Color(0xFF7BB4E3);
    const softBlue = Color(0xFFD6E8F9);

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: inputBgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      hintStyle: TextStyle(color: subTextColor, fontSize: 14),
      prefixIconColor: subTextColor,
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_rounded, color: primaryBlue, size: 40),
                    const SizedBox(width: 10),
                    Text(
                      'CLAY',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      ' Admin',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 60),
                
                // Illustration placeholder
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: softBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryBlue.withOpacity(0.3), width: 8),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, size: 60, color: primaryBlue),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Selamat datang di CLAY!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Silakan masuk untuk mengakses panel kendali dan mengelola layanan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 48),

                // Form
                TextFormField(
                  controller: _phoneC,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                  decoration: inputDecoration.copyWith(
                    hintText: 'Email atau Telepon',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? 'Tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passC,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                  decoration: inputDecoration.copyWith(
                    hintText: 'Kata Sandi',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: subTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Tidak boleh kosong' : null,
                ),
                
                const SizedBox(height: 32),

                if (state.error != null) 
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFD32F2F), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Login Button
                ElevatedButton(
                  onPressed: state.isLoading ? null : () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ref.read(adminAuthProvider.notifier).login(_phoneC.text.trim(), _passC.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: softBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100), // Stadium border like image
                    ),
                  ),
                  child: state.isLoading 
                    ? const SizedBox(
                        width: 24, height: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        'Masuk',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
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

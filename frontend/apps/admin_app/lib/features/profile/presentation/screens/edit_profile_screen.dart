import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/admin_auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  String selectedRole = 'Super Admin';
  String selectedTimezone = 'Waktu Indonesia Barat (WIB)';
  String selectedLang = 'Bahasa Indonesia';

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(adminAuthProvider).admin;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF757575);
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE0E0E0);
    const softBlue = Color(0xFFD6E8F9);
    const primaryBlue = Color(0xFF7BB4E3);

    InputDecoration inputDecoration(String hint, [bool isDropdown = false]) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: subTextColor.withOpacity(0.5)),
        filled: true,
        fillColor: isDark ? Colors.white10 : const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isDropdown ? 12 : 14),
      );
    }

    Widget label(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Edit Profil Admin', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: softBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryBlue.withOpacity(0.3), width: 4),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, size: 50, color: primaryBlue),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Text('Informasi Pribadi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label('Nama Lengkap'),
                  TextFormField(
                    initialValue: a?['name'] ?? 'Clay Admin',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    decoration: inputDecoration('Masukkan nama lengkap'),
                  ),
                  const SizedBox(height: 16),
                  
                  label('Nomor Telepon'),
                  TextFormField(
                    initialValue: '+6281234567890',
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    decoration: inputDecoration('Masukkan nomor telepon aktif'),
                  ),
                  const SizedBox(height: 16),

                  label('Alamat Email'),
                  TextFormField(
                    initialValue: a?['email'] ?? 'admin@clay.com',
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    decoration: inputDecoration('Masukkan email'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text('Informasi Jabatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label('ID Karyawan / Admin ID'),
                  TextFormField(
                    initialValue: 'ADM-2026-001',
                    enabled: false,
                    style: TextStyle(color: subTextColor, fontWeight: FontWeight.w600),
                    decoration: inputDecoration('ID Otomatis').copyWith(
                      fillColor: isDark ? Colors.white10.withOpacity(0.02) : Colors.grey.withOpacity(0.05),
                      suffixIcon: Icon(Icons.lock_rounded, size: 16, color: subTextColor.withOpacity(0.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  label('Peran Akses (Role)'),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: subTextColor),
                    decoration: inputDecoration('', true),
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    items: ['Super Admin', 'Admin Operasional', 'Customer Support', 'Keuangan']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedRole = v!),
                  ),
                  const SizedBox(height: 16),
                  
                  label('Divisi Terkait'),
                  TextFormField(
                    initialValue: 'Manajemen Pusat',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    decoration: inputDecoration('Masukkan nama divisi'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text('Preferensi Sistem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label('Zona Waktu Dashboard'),
                  DropdownButtonFormField<String>(
                    value: selectedTimezone,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: subTextColor),
                    decoration: inputDecoration('', true),
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    items: ['Waktu Indonesia Barat (WIB)', 'Waktu Indonesia Tengah (WITA)', 'Waktu Indonesia Timur (WIT)', 'UTC (Global)']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedTimezone = v!),
                  ),
                  const SizedBox(height: 16),
                  
                  label('Bahasa Tampilan'),
                  DropdownButtonFormField<String>(
                    value: selectedLang,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: subTextColor),
                    decoration: inputDecoration('', true),
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    items: ['Bahasa Indonesia', 'English (US)']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedLang = v!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text('Keamanan Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label('Kata Sandi Baru (Opsional)'),
                  TextFormField(
                    obscureText: true,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    decoration: inputDecoration('Masukkan kata sandi baru').copyWith(
                      suffixIcon: Icon(Icons.visibility_off_rounded, color: subTextColor, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  label('Konfirmasi Kata Sandi'),
                  TextFormField(
                    obscureText: true,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    decoration: inputDecoration('Ulangi kata sandi baru').copyWith(
                      suffixIcon: Icon(Icons.visibility_off_rounded, color: subTextColor, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Color(0xFF4CAF50)),
                );
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

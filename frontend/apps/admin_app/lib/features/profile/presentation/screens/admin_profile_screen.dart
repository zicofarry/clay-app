import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/admin_auth_provider.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(adminAuthProvider).admin;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF757575);
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE0E0E0);
    const softBlue = Color(0xFFD6E8F9);
    const primaryBlue = Color(0xFF7BB4E3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Profil Admin', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card
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
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: softBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryBlue.withOpacity(0.3), width: 4),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, size: 36, color: primaryBlue),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a?['name'] ?? 'Clay Admin',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (a?['role'] ?? 'Super Admin').toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Details Card
            Container(
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
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.email_outlined, color: subTextColor),
                    ),
                    title: Text(a?['email'] ?? 'admin@clay.com', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Email Resmi', style: TextStyle(color: subTextColor, fontSize: 13)),
                    ),
                  ),
                  Divider(color: borderColor, height: 1, indent: 20, endIndent: 20),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.security_rounded, color: subTextColor),
                    ),
                    title: Text('Akses Penuh', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Hak Akses', style: TextStyle(color: subTextColor, fontSize: 13)),
                    ),
                  ),
                  Divider(color: borderColor, height: 1, indent: 20, endIndent: 20),
                  ListTile(
                    onTap: () => context.push('/admin-management'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.people_alt_rounded, color: primaryBlue),
                    ),
                    title: Text('Manajemen Tim', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Kelola akses admin', style: TextStyle(color: subTextColor, fontSize: 13)),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: subTextColor),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Edit Profile Button
            ElevatedButton(
              onPressed: () => context.push('/edit-profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: softBlue,
                foregroundColor: primaryBlue,
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Edit Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Logout Button
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEBEE),
                foregroundColor: const Color(0xFFD32F2F),
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: const BorderSide(color: Color(0xFFFFCDD2)),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Keluar Akun',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for internal admins
    final admins = [
      {'name': 'Budi Santoso', 'email': 'budi.admin@clay.com', 'role': 'Super Admin', 'status': 'Aktif'},
      {'name': 'Rina Melati', 'email': 'rina.cs@clay.com', 'role': 'Customer Support', 'status': 'Aktif'},
      {'name': 'Ahmad Fauzi', 'email': 'ahmad.ops@clay.com', 'role': 'Operasional', 'status': 'Aktif'},
      {'name': 'Dewi Lestari', 'email': 'dewi.fin@clay.com', 'role': 'Keuangan', 'status': 'Nonaktif'},
    ];

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
        title: Text('Manajemen Tim Admin', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur tambah admin segera hadir!'), backgroundColor: primaryBlue),
          );
        },
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Tambah Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: admins.length,
        itemBuilder: (context, index) {
          final admin = admins[index];
          final isAktif = admin['status'] == 'Aktif';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                if (!isDark)
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isAktif ? softBlue : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shield_rounded, color: isAktif ? primaryBlue : Colors.grey),
              ),
              title: Text(
                admin['name']!,
                style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(admin['email']!, style: TextStyle(color: subTextColor, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          admin['role']!.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFE65100),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAktif ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          admin['status']!.toUpperCase(),
                          style: TextStyle(
                            color: isAktif ? const Color(0xFF4CAF50) : const Color(0xFFD32F2F),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: subTextColor),
                color: cardColor,
                onSelected: (value) {
                  if (value == 'Log') {
                    context.push('/audit-log');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Aksi $value untuk ${admin['name']}!'), backgroundColor: primaryBlue),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Edit', child: Text('Edit Hak Akses')),
                  const PopupMenuItem(value: 'Suspend', child: Text('Nonaktifkan')),
                  const PopupMenuItem(value: 'Log', child: Text('Lihat Aktivitas')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

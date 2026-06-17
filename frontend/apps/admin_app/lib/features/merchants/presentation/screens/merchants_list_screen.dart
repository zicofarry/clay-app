import 'package:flutter/material.dart';

class MerchantsListScreen extends StatelessWidget {
  const MerchantsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final merchants = [
      {'name': 'Bakso Merdeka', 'owner': 'Pak Budi', 'category': 'Makanan', 'rating': 4.5, 'status': 'active'},
      {'name': 'Sate Pak Edi', 'owner': 'Pak Edi', 'category': 'Sate', 'rating': 4.8, 'status': 'active'},
      {'name': 'Nasi Goreng Mawar', 'owner': 'Bu Mawar', 'category': 'Nasi', 'rating': 4.3, 'status': 'suspended'},
      {'name': 'Ayam Geprek Joe', 'owner': 'Joe', 'category': 'Ayam', 'rating': 4.6, 'status': 'active'},
      {'name': 'Padang Sederhana', 'owner': 'Pak Rifai', 'category': 'Padang', 'rating': 4.4, 'status': 'active'},
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
        title: Text('Merchant', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: merchants.length,
        itemBuilder: (_, i) {
          final m = merchants[i];
          final isActive = m['status'] == 'active';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                if (!isDark)
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.storefront_rounded, color: primaryBlue),
              ),
              title: Text('${m['name']}', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${m['category']} • ${m['owner']}', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('${m['rating']}', style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${m['status']}'.toUpperCase(),
                      style: TextStyle(
                        color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFD32F2F),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

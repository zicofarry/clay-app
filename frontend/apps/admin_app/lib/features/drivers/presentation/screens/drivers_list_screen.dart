import 'package:flutter/material.dart';

class DriversListScreen extends StatelessWidget {
  const DriversListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final drivers = List.generate(8, (i) => {
      'name': 'Driver ${i + 1}', 'phone': '+6281234567${i}', 'vehicle': 'Toyota Avanza', 'plate': 'B ${1000 + i} ABC', 'status': i % 4 == 0 ? 'offline' : 'online', 'rating': 4.5 + (i * 0.1),
    });

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
        title: Text('Driver', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: drivers.length,
        itemBuilder: (_, i) {
          final d = drivers[i];
          final isOnline = d['status'] == 'online';
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
                child: const Icon(Icons.directions_car_rounded, color: primaryBlue),
              ),
              title: Text('${d['name']}', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${d['vehicle']} • ${d['plate']}', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
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
                      Text('${d['rating']}', style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isOnline ? const Color(0xFFE8F5E9) : isDark ? Colors.white10 : const Color(0xFFF5F5F5)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${d['status']}'.toUpperCase(),
                      style: TextStyle(
                        color: isOnline ? const Color(0xFF4CAF50) : subTextColor,
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

import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<Map<String, dynamic>> notifications;

  @override
  void initState() {
    super.initState();
    notifications = [
      {'id': 1, 'title': 'Sistem Berhasil Diperbarui', 'desc': 'Pembaruan sistem v1.2.0 selesai', 'time': 'Baru saja', 'isUnread': true, 'icon': Icons.system_update_rounded, 'color': const Color(0xFF4FC3F7)},
      {'id': 2, 'title': 'Merchant Baru Mendaftar', 'desc': 'Toko Kopi Senja menunggu verifikasi.', 'time': '2 jam yang lalu', 'isUnread': true, 'icon': Icons.storefront_rounded, 'color': const Color(0xFFFFA726)},
      {'id': 3, 'title': 'Peringatan Server', 'desc': 'Penggunaan CPU server mencapai 80%', 'time': 'Kemarin', 'isUnread': false, 'icon': Icons.warning_rounded, 'color': const Color(0xFFD32F2F)},
      {'id': 4, 'title': 'Driver Laporan Masalah', 'desc': 'Budi Setiawan melaporkan masalah aplikasi', 'time': 'Kemarin', 'isUnread': false, 'icon': Icons.report_problem_rounded, 'color': const Color(0xFFAB47BC)},
    ];
  }

  void _markAsRead(int index) {
    if (notifications[index]['isUnread'] == true) {
      setState(() {
        notifications[index] = {
          ...notifications[index],
          'isUnread': false,
        };
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = {
          ...notifications[i],
          'isUnread': false,
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Tandai semua dibaca',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: _markAllAsRead,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: notifications.length,
        itemBuilder: (_, i) {
          final n = notifications[i];
          final isUnread = n['isUnread'] as bool;
          final color = n['color'] as Color;

          return GestureDetector(
            onTap: () => _markAsRead(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isUnread ? softBlue.withOpacity(0.3) : cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isUnread ? primaryBlue.withOpacity(0.5) : borderColor),
                boxShadow: [
                  if (!isDark && !isUnread)
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(n['icon'] as IconData, color: color),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text('${n['title']}', style: TextStyle(fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600, color: textColor, fontSize: 14))),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${n['desc']}', style: TextStyle(color: subTextColor, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('${n['time']}', style: TextStyle(color: subTextColor.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

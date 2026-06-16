import 'package:flutter/material.dart';

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for Inbox
    final tickets = [
      {'id': 'TCK-1029', 'user': 'Siska (User)', 'subject': 'Makanan belum sampai', 'time': '10:45', 'status': 'Open', 'isUnread': true},
      {'id': 'TCK-1028', 'user': 'Budi (Driver)', 'subject': 'Titik jemput tidak sesuai map', 'time': '09:12', 'status': 'In Progress', 'isUnread': false},
      {'id': 'TCK-1027', 'user': 'Kopi Senja (Merchant)', 'subject': 'Cara ubah jam buka toko?', 'time': 'Kemarin', 'status': 'Resolved', 'isUnread': false},
      {'id': 'TCK-1026', 'user': 'Ahmad (User)', 'subject': 'Driver minta cancel', 'time': 'Kemarin', 'status': 'Resolved', 'isUnread': false},
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF757575);
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE0E0E0);
    const primaryBlue = Color(0xFF7BB4E3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Customer Support', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Cari tiket atau nama pengguna...',
                hintStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.search_rounded, color: subTextColor),
                filled: true,
                fillColor: isDark ? Colors.white10 : const Color(0xFFF5F7FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilter('Semua Tiket', true, primaryBlue, isDark),
                _buildFilter('Open (1)', false, const Color(0xFFD32F2F), isDark),
                _buildFilter('In Progress', false, const Color(0xFFF57C00), isDark),
                _buildFilter('Resolved', false, const Color(0xFF4CAF50), isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ticket List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final t = tickets[index];
                final isUnread = t['isUnread'] as bool;

                Color statusColor;
                if (t['status'] == 'Open') statusColor = const Color(0xFFD32F2F);
                else if (t['status'] == 'In Progress') statusColor = const Color(0xFFF57C00);
                else statusColor = const Color(0xFF4CAF50);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isUnread ? primaryBlue.withOpacity(0.5) : borderColor),
                    boxShadow: [if (!isDark && !isUnread) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isDark ? Colors.white10 : const Color(0xFFF0F0F0),
                      child: Icon(Icons.person_rounded, color: subTextColor),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t['user'] as String, style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 14)),
                        Text(t['time'] as String, style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(t['subject'] as String, style: TextStyle(color: isUnread ? textColor : subTextColor, fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(t['status'] as String, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    trailing: isUnread ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle)) : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(String label, bool isActive, Color activeColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? activeColor : (isDark ? Colors.white10 : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? activeColor : (isDark ? Colors.white10 : const Color(0xFFE0E0E0))),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF757575)),
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

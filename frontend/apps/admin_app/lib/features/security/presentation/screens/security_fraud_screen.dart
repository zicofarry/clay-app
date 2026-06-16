import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SecurityFraudScreen extends StatelessWidget {
  const SecurityFraudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data based on the /security/admin/fraud-flags API
    final frauds = [
      {'id': 'FF-902', 'user': 'User-821 (Ahmad)', 'type': 'Multiple Accounts', 'risk': 'High', 'status': 'Pending', 'date': 'Hari ini'},
      {'id': 'FF-901', 'user': 'Driver-104 (Budi)', 'type': 'GPS Spoofing', 'risk': 'Critical', 'status': 'Pending', 'date': 'Hari ini'},
      {'id': 'FF-900', 'user': 'Merchant-33 (Kopi Senja)', 'type': 'Fake Orders', 'risk': 'High', 'status': 'Resolved', 'date': 'Kemarin'},
      {'id': 'FF-899', 'user': 'User-112 (Siska)', 'type': 'Suspicious Login', 'risk': 'Low', 'status': 'Resolved', 'date': 'Kemarin'},
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF757575);
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE0E0E0);
    const primaryBlue = Color(0xFF7BB4E3);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text('Keamanan & Fraud', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
          backgroundColor: bgColor,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: textColor),
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: primaryBlue,
            labelColor: primaryBlue,
            unselectedLabelColor: subTextColor,
            dividerColor: borderColor,
            tabs: const [
              Tab(text: 'Fraud Flags'),
              Tab(text: 'IP Blacklist'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Fraud Flags
            ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: frauds.length,
              itemBuilder: (context, index) {
                final f = frauds[index];
                final isPending = f['status'] == 'Pending';
                
                Color riskColor;
                if (f['risk'] == 'Critical') riskColor = const Color(0xFFD32F2F);
                else if (f['risk'] == 'High') riskColor = const Color(0xFFE65100);
                else riskColor = const Color(0xFFFBC02D);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${f['id']} • ${f['date']}', style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text('${f['risk']} Risk', style: TextStyle(color: riskColor, fontSize: 10, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('${f['user']}', style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 15)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 14, color: subTextColor),
                            const SizedBox(width: 4),
                            Text('${f['type']}', style: TextStyle(color: subTextColor, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (isPending)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.push('/fraud-detail'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: textColor,
                                    side: BorderSide(color: borderColor),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Detail'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Resolve'),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                            alignment: Alignment.center,
                            child: const Text('Resolved', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Tab 2: IP Blacklist (Simple Placeholder)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_rounded, size: 80, color: subTextColor.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('IP Blacklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  Text('Kelola daftar IP Address yang diblokir.', style: TextStyle(color: subTextColor)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah IP'),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
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

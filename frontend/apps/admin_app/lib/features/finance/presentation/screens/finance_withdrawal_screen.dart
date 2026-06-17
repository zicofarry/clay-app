import 'package:flutter/material.dart';

class FinanceWithdrawalScreen extends StatelessWidget {
  const FinanceWithdrawalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for Withdrawals
    final requests = [
      {'id': 'WD-099', 'user': 'Driver Budi', 'bank': 'BCA •••• 1234', 'amount': 'Rp 150.000', 'time': 'Hari ini, 09:15', 'status': 'Pending'},
      {'id': 'WD-098', 'user': 'Kopi Senja', 'bank': 'Mandiri •••• 5521', 'amount': 'Rp 850.000', 'time': 'Hari ini, 08:30', 'status': 'Pending'},
      {'id': 'WD-097', 'user': 'Driver Ahmad', 'bank': 'BNI •••• 9901', 'amount': 'Rp 50.000', 'time': 'Kemarin', 'status': 'Approved'},
      {'id': 'WD-096', 'user': 'Ayam Geprek Joe', 'bank': 'BRI •••• 4422', 'amount': 'Rp 1.200.000', 'time': 'Kemarin', 'status': 'Rejected'},
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
        title: Text('Pencairan Dana', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final isPending = req['status'] == 'Pending';
          
          Color statusColor;
          if (isPending) statusColor = const Color(0xFFF57C00);
          else if (req['status'] == 'Approved') statusColor = const Color(0xFF4CAF50);
          else statusColor = const Color(0xFFD32F2F);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${req['id']} • ${req['time']}', style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(req['status'] as String, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFD6E8F9), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req['user'] as String, style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(req['bank'] as String, style: TextStyle(color: subTextColor, fontSize: 13)),
                          ],
                        ),
                      ),
                      Text(req['amount'] as String, style: TextStyle(fontWeight: FontWeight.w800, color: textColor, fontSize: 16)),
                    ],
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD32F2F),
                              side: const BorderSide(color: Color(0xFFFFCDD2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Tolak'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Setujui Transfer'),
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

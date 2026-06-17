import 'package:flutter/material.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'id': 'TRX-9921', 'type': 'ClayRide', 'user': 'Budi S.', 'amount': 'Rp 12.000', 'status': 'success', 'date': 'Hari ini, 08:45'},
      {'id': 'TRX-9920', 'type': 'ClayFood', 'user': 'Siska', 'amount': 'Rp 45.000', 'status': 'success', 'date': 'Hari ini, 07:30'},
      {'id': 'TRX-9919', 'type': 'ClayWallet', 'user': 'Ahmad', 'amount': 'Rp 150.000', 'status': 'pending', 'date': 'Kemarin, 20:15'},
      {'id': 'TRX-9918', 'type': 'ClayCar', 'user': 'Diana', 'amount': 'Rp 42.000', 'status': 'success', 'date': 'Kemarin, 18:00'},
      {'id': 'TRX-9917', 'type': 'ClaySend', 'user': 'Rina M.', 'amount': 'Rp 15.000', 'status': 'failed', 'date': 'Kemarin, 14:20'},
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
        title: Text('Transaksi', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: transactions.length,
        itemBuilder: (_, i) {
          final t = transactions[i];
          final isSuccess = t['status'] == 'success';
          final isPending = t['status'] == 'pending';
          
          Color statusColor;
          Color statusBg;
          if (isSuccess) {
            statusColor = const Color(0xFF4CAF50);
            statusBg = const Color(0xFFE8F5E9);
          } else if (isPending) {
            statusColor = const Color(0xFFFFA000);
            statusBg = const Color(0xFFFFF8E1);
          } else {
            statusColor = const Color(0xFFD32F2F);
            statusBg = const Color(0xFFFFEBEE);
          }

          IconData getIcon(String type) {
            if (type == 'ClayRide') return Icons.two_wheeler_rounded;
            if (type == 'ClayFood') return Icons.fastfood_rounded;
            if (type == 'ClayWallet') return Icons.account_balance_wallet_rounded;
            if (type == 'ClayCar') return Icons.directions_car_rounded;
            return Icons.local_shipping_rounded;
          }

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
                child: Icon(getIcon(t['type'] as String), color: primaryBlue),
              ),
              title: Text('${t['type']} • ${t['user']}', style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 14)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${t['id']} • ${t['date']}', style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${t['amount']}', style: TextStyle(fontWeight: FontWeight.w800, color: textColor, fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${t['status']}'.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
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

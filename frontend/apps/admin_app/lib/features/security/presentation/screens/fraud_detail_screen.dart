import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FraudDetailScreen extends StatelessWidget {
  const FraudDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy detail data
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF757575);
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE0E0E0);
    const primaryBlue = Color(0xFF7BB4E3);
    const dangerColor = Color(0xFFD32F2F);
    
    Widget _buildSection(String title, Widget content) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 24),
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
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 16),
            content,
          ],
        ),
      );
    }

    Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(label, style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? textColor,
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Detail Fraud (FF-901)', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
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
            // Warning Header
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: dangerColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Risiko Kritis (Critical)', style: TextStyle(color: dangerColor, fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Tindakan segera diperlukan untuk akun ini.', style: TextStyle(color: dangerColor.withOpacity(0.8), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildSection(
              'Informasi Akun',
              Column(
                children: [
                  _buildDetailRow('ID Pengguna', 'Driver-104 (Budi Santoso)', isBold: true),
                  _buildDetailRow('Status', 'Aktif', valueColor: const Color(0xFF4CAF50), isBold: true),
                  _buildDetailRow('Bergabung', '12 Jan 2024'),
                  _buildDetailRow('Total Trip', '420 Trip'),
                ],
              ),
            ),

            _buildSection(
              'Detail Indikasi Fraud',
              Column(
                children: [
                  _buildDetailRow('Tipe Fraud', 'GPS Spoofing (Lokasi Palsu)', isBold: true),
                  _buildDetailRow('Terdeteksi', 'Hari ini, 08:15 WIB'),
                  _buildDetailRow('Sumber Laporan', 'System Auto-Detection'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Log Bukti Sistem:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subTextColor)),
                        const SizedBox(height: 6),
                        const Text(
                          '1. Terdeteksi aplikasi Mock Location (Fake GPS) aktif bersamaan dengan penerimaan order TRX-1002.\n'
                          '2. Perpindahan kordinat sejauh 5KM dalam 2 detik (Tidk wajar).',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Akun ditangguhkan!'), backgroundColor: dangerColor),
                      );
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: dangerColor,
                      side: const BorderSide(color: dangerColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Suspend Akun', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tanda Fraud diselesaikan (Resolved).'), backgroundColor: Color(0xFF4CAF50)),
                      );
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Resolve (Aman)', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

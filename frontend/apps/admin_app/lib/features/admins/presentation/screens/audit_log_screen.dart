import 'package:flutter/material.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _selectedFilter = 'Semua';

  // Dummy data based on the /audit/admin/logs API
  final allLogs = [
    {'id': 'LOG-006', 'actor': 'Rina Melati', 'action': 'ADMIN_LOGIN', 'resource': 'Session-88', 'details': 'Logged in successfully', 'time': 'Hari ini, 11:00', 'ip': '10.0.0.45'},
    {'id': 'LOG-001', 'actor': 'Budi Santoso', 'action': 'UPDATE_MERCHANT_STATUS', 'resource': 'Merchant-192', 'details': 'Status changed from PENDING to ACTIVE', 'time': 'Hari ini, 10:45', 'ip': '192.168.1.12'},
    {'id': 'LOG-002', 'actor': 'Rina Melati', 'action': 'RESOLVE_FRAUD_FLAG', 'resource': 'FraudFlag-84', 'details': 'Marked suspicious transaction as safe', 'time': 'Hari ini, 09:30', 'ip': '10.0.0.45'},
    {'id': 'LOG-003', 'actor': 'Ahmad Fauzi', 'action': 'SUSPEND_DRIVER', 'resource': 'Driver-505', 'details': 'Suspended due to multiple complaints', 'time': 'Kemarin, 16:20', 'ip': '192.168.1.5'},
    {'id': 'LOG-004', 'actor': 'System', 'action': 'ADD_IP_BLACKLIST', 'resource': 'IP-Block-99', 'details': 'Auto-blocked IP 203.0.113.42 due to brute force', 'time': 'Kemarin, 14:10', 'ip': 'localhost'},
    {'id': 'LOG-005', 'actor': 'Budi Santoso', 'action': 'EXPORT_AUDIT_LOGS', 'resource': 'ExportJob-12', 'details': 'Exported logs for Q1 2026', 'time': '14 Jun 2026, 11:00', 'ip': '192.168.1.12'},
  ];

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

    // Apply filtering
    final logs = allLogs.where((log) {
      if (_selectedFilter == 'Semua') return true;
      if (_selectedFilter == 'Auth & Login' && log['action']!.contains('LOGIN')) return true;
      if (_selectedFilter == 'Fraud & Security' && (log['action']!.contains('FRAUD') || log['action']!.contains('BLACKLIST'))) return true;
      if (_selectedFilter == 'Status Update' && (log['action']!.contains('STATUS') || log['action']!.contains('SUSPEND'))) return true;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Audit Logs', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Export Logs',
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Memulai proses export log...'), backgroundColor: primaryBlue),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', isDark),
                  _buildFilterChip('Auth & Login', isDark),
                  _buildFilterChip('Fraud & Security', isDark),
                  _buildFilterChip('Status Update', isDark),
                ],
              ),
            ),
          ),
          
          // Log List
          Expanded(
            child: logs.isEmpty
              ? Center(
                  child: Text('Tidak ada log untuk filter ini.', style: TextStyle(color: subTextColor)),
                )
              : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                
                IconData getIcon(String action) {
                  if (action.contains('FRAUD') || action.contains('BLACKLIST') || action.contains('SUSPEND')) return Icons.security_rounded;
                  if (action.contains('EXPORT')) return Icons.file_download_rounded;
                  return Icons.manage_accounts_rounded;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
                              child: Icon(getIcon(log['action']!), color: primaryBlue, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log['action']!, style: TextStyle(fontWeight: FontWeight.w800, color: textColor, fontSize: 13, letterSpacing: 0.5)),
                                  Text('Oleh: ${log['actor']} • IP: ${log['ip']}', style: TextStyle(color: subTextColor, fontSize: 11)),
                                ],
                              ),
                            ),
                            Text(log['time']!, style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target: ${log['resource']}', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('${log['details']}', style: TextStyle(color: subTextColor, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isActive = _selectedFilter == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF7BB4E3) : (isDark ? Colors.white10 : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? const Color(0xFF7BB4E3) : (isDark ? Colors.white10 : const Color(0xFFE0E0E0))),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF757575)),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

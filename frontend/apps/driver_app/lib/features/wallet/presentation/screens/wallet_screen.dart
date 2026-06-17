import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../shared/widgets.dart';

final walletProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final response = await ClayApi.instance.dio.get('/wallet');
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>? ?? data;
  } on DioException catch (e) {
    final msg = (e.response?.data as Map<String, dynamic>?)?['message']?.toString() ?? e.message ?? 'Gagal memuat dompet';
    throw Exception(msg);
  }
});

final walletTransactionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final response = await ClayApi.instance.dio.get('/wallet/transactions');
    final data = response.data as Map<String, dynamic>;
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    final list = inner['data'] as List<dynamic>? ?? inner['transactions'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  } on DioException catch (e) {
    final msg = (e.response?.data as Map<String, dynamic>?)?['message']?.toString() ?? e.message ?? 'Gagal memuat transaksi';
    throw Exception(msg);
  }
});

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    final wallet = walletAsync.valueOrNull ?? {};
    final balance = wallet['balance'] ?? 0;
    final pendingBalance = wallet['pending_balance'] ?? 0;
    final totalEarned = wallet['total_earned'] ?? 0;
    final totalWithdrawn = wallet['total_withdrawn'] ?? 0;

    final transactions = transactionsAsync.valueOrNull ?? [];

    String _formatAmount(dynamic amount) {
      final value = (amount ?? 0) is int ? amount as int : int.tryParse(amount.toString()) ?? 0;
      return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }

    String _formatTime(String? createdAt) {
      if (createdAt == null) return '-';
      try {
        final dt = DateTime.parse(createdAt);
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inSeconds < 60) return 'Baru saja';
        if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
        if (diff.inHours < 24) return '${diff.inHours} jam lalu';
        if (diff.inDays < 7) return '${diff.inDays} hari lalu';
        if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
        return '${(diff.inDays / 30).floor()} bulan lalu';
      } catch (_) {
        return createdAt;
      }
    }

    Color _typeColor(String type) {
      switch (type) {
        case 'credit':
          return ClayColors.green;
        case 'debit':
          return ClayColors.accent;
        case 'topup':
          return ClayColors.primary;
        case 'withdrawal':
          return ClayColors.purple;
        default:
          return ClayColors.textSecondary;
      }
    }

    IconData _typeIcon(String type) {
      switch (type) {
        case 'credit':
          return Icons.arrow_downward;
        case 'debit':
          return Icons.arrow_upward;
        case 'topup':
          return Icons.add_circle_outline;
        case 'withdrawal':
          return Icons.account_balance;
        default:
          return Icons.swap_horiz;
      }
    }

    Color _statusColor(String status) {
      switch (status) {
        case 'completed':
          return ClayColors.green;
        case 'pending':
          return ClayColors.warning;
        case 'failed':
          return ClayColors.accent;
        default:
          return ClayColors.textSecondary;
      }
    }

    String _statusLabel(String status) {
      switch (status) {
        case 'completed':
          return 'Selesai';
        case 'pending':
          return 'Tertunda';
        case 'failed':
          return 'Gagal';
        default:
          return status;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(onTap: () { if (Navigator.canPop(context)) { context.pop(); } else { context.go('/home'); } }, child: Container(width: 40, height: 40, decoration: softShadow(), child: const Center(child: Icon(Icons.arrow_back, size: 20, color: ClayColors.textPrimary)))),
                  const SizedBox(width: 12),
                  const Text('Dompet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: walletAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(colors: [ClayColors.primary, ClayColors.primaryLight, ClayColors.primary]),
                            boxShadow: [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Saldo Tersedia', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 4),
                              Text(_formatAmount(balance), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _WalletMiniStat(icon: Icons.hourglass_empty, label: 'Tertunda', value: _formatAmount(pendingBalance)),
                                  const SizedBox(width: 12),
                                  _WalletMiniStat(icon: Icons.trending_up, label: 'Total Diperoleh', value: _formatAmount(totalEarned)),
                                  const SizedBox(width: 12),
                                  _WalletMiniStat(icon: Icons.arrow_circle_up, label: 'Ditarik', value: _formatAmount(totalWithdrawn)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur penarikan segera tersedia'), duration: Duration(seconds: 2))),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: softShadow(),
                            child: const Row(
                              children: [
                                Icon(Icons.account_balance_wallet, size: 20, color: ClayColors.green),
                                SizedBox(width: 12),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cairkan Dana', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                                    Text('Tarik saldo ke rekening bank', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                                  ],
                                )),
                                Icon(Icons.chevron_right, color: ClayColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const SectionHeader(title: 'Riwayat Transaksi'),
                        const SizedBox(height: 8),
                        if (transactionsAsync.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (transactions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text('Belum ada transaksi', style: TextStyle(color: ClayColors.textSecondary, fontSize: 13)),
                            ),
                          )
                        else
                          ...transactions.map((t) {
                            final type = t['type']?.toString() ?? 'credit';
                            final amount = t['amount'] ?? 0;
                            final description = t['description']?.toString() ?? type;
                            final status = t['status']?.toString() ?? 'completed';
                            final createdAt = t['created_at']?.toString();
                            final color = _typeColor(type);
                            final icon = _typeIcon(type);
                            final prefix = type == 'credit' || type == 'topup' ? '+' : '-';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: softShadow(),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                    child: Icon(icon, size: 16, color: color),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(_formatTime(createdAt), style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                              child: Text(_statusLabel(status), style: TextStyle(fontSize: 9, color: _statusColor(status), fontWeight: FontWeight.w500)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text('$prefix${_formatAmount(amount)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletMiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _WalletMiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

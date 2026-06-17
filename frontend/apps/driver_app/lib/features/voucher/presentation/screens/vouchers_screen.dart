import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../shared/widgets.dart';

final vouchersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final response = await ClayApi.instance.dio.get('/promotions');
    final data = response.data as Map<String, dynamic>;
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    final list = inner['data'] as List<dynamic>? ?? inner['promotions'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return [];
    final msg = (e.response?.data as Map<String, dynamic>?)?['message']?.toString() ?? e.message ?? 'Gagal memuat voucher';
    throw Exception(msg);
  }
});

class VouchersScreen extends ConsumerWidget {
  const VouchersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vouchersAsync = ref.watch(vouchersProvider);
    final vouchers = vouchersAsync.valueOrNull ?? [];

    Color _statusColor(String status) {
      switch (status) {
        case 'active':
          return ClayColors.green;
        case 'expired':
          return ClayColors.textSecondary;
        case 'used':
          return ClayColors.primary;
        default:
          return ClayColors.textSecondary;
      }
    }

    String _statusLabel(String status) {
      switch (status) {
        case 'active':
          return 'Aktif';
        case 'expired':
          return 'Kedaluwarsa';
        case 'used':
          return 'Sudah Dipakai';
        default:
          return status;
      }
    }

    IconData _statusIcon(String status) {
      switch (status) {
        case 'active':
          return Icons.check_circle_outline;
        case 'expired':
          return Icons.timer_off_outlined;
        case 'used':
          return Icons.redeem;
        default:
          return Icons.local_offer_outlined;
      }
    }

    String _discountLabel(String type, dynamic value) {
      if (type == 'percentage') return '$value%';
      final intVal = value is int ? value : int.tryParse(value.toString()) ?? 0;
      return 'Rp ${intVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }

    String _formatDate(String? dateStr) {
      if (dateStr == null) return '-';
      try {
        final dt = DateTime.parse(dateStr);
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
        return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {
        return dateStr;
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
                  const Text('Voucher & Promo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: vouchersAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vouchers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_offer_outlined, size: 48, color: ClayColors.textSecondary.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              const Text('Belum ada voucher tersedia', style: TextStyle(color: ClayColors.textSecondary, fontSize: 14)),
                              const SizedBox(height: 4),
                              const Text('Voucher baru akan muncul di sini', style: TextStyle(color: ClayColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: vouchers.length,
                          itemBuilder: (context, index) {
                            final v = vouchers[index];
                            final title = v['title']?.toString() ?? 'Voucher';
                            final description = v['description']?.toString() ?? '';
                            final discountType = v['discount_type']?.toString() ?? 'fixed';
                            final discountValue = v['discount_value'] ?? 0;
                            final validUntil = v['valid_until']?.toString();
                            final status = v['status']?.toString() ?? 'active';
                            final color = _statusColor(status);
                            final icon = _statusIcon(status);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: softShadow(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                        child: Icon(icon, size: 20, color: color),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            if (description.isNotEmpty)
                                              Text(description, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                        child: Text(_statusLabel(status), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(color: ClayColors.muted, borderRadius: BorderRadius.circular(10)),
                                    child: Row(
                                      children: [
                                        Text(_discountLabel(discountType, discountValue), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                                        const Spacer(),
                                        Text('Berlaku s/d ${_formatDate(validUntil)}', style: const TextStyle(fontSize: 10, color: ClayColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

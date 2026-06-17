import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';
import '../../../../shared/widgets.dart';

final driverDocumentsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final response = await ClayApi.instance.dio.get(ApiEndpoints.driverProfile);
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>? ?? data;
  } on DioException catch (e) {
    throw Exception(e.response?.data is Map
        ? (e.response!.data['message']?.toString() ?? 'Gagal memuat dokumen')
        : 'Gagal memuat dokumen');
  }
});

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(driverDocumentsProvider);

    return Scaffold(
      backgroundColor: ClayColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: softShadow(),
                      child: const Center(
                        child: Icon(Icons.arrow_back, size: 20, color: ClayColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Dokumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: docsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: ClayColors.accent.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(e.toString(), style: const TextStyle(color: ClayColors.textSecondary, fontSize: 13), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                data: (d) {
                  final simNumber = d['sim_number']?.toString() ?? '-';
                  final ktpNumber = d['ktp_number']?.toString() ?? '-';
                  final verificationStatus = d['verification_status']?.toString() ?? 'pending';

                  final (statusLabel, statusColor) = switch (verificationStatus) {
                    'verified' => ('Terverifikasi', ClayColors.green),
                    'pending' => ('Menunggu Verifikasi', ClayColors.warning),
                    'rejected' => ('Ditolak', ClayColors.accent),
                    _ => (verificationStatus, ClayColors.textSecondary),
                  };

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Status card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: softShadow(),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                verificationStatus == 'verified'
                                    ? Icons.verified
                                    : verificationStatus == 'rejected'
                                        ? Icons.cancel_outlined
                                        : Icons.hourglass_top,
                                size: 24,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Status Verifikasi', style: TextStyle(fontSize: 12, color: ClayColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // SIM
                      const Text('SIM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                      const SizedBox(height: 8),
                      _DocumentCard(
                        icon: Icons.badge_outlined,
                        title: 'Surat Izin Mengemudi',
                        number: simNumber,
                        statusColor: statusColor,
                        statusLabel: statusLabel,
                      ),
                      const SizedBox(height: 20),

                      // KTP
                      const Text('KTP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                      const SizedBox(height: 8),
                      _DocumentCard(
                        icon: Icons.credit_card_outlined,
                        title: 'Kartu Tanda Penduduk',
                        number: ktpNumber,
                        statusColor: statusColor,
                        statusLabel: statusLabel,
                      ),
                      const SizedBox(height: 24),

                      // Upload note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ClayColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ClayColors.warning.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 20, color: ClayColors.warning),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Upload dokumen segera tersedia',
                                style: TextStyle(fontSize: 13, color: ClayColors.warning, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
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

class _DocumentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String number;
  final Color statusColor;
  final String statusLabel;

  const _DocumentCard({
    required this.icon,
    required this.title,
    required this.number,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: softShadow(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ClayColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: ClayColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: ClayColors.textPrimary)),
                const SizedBox(height: 4),
                Text(number, style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

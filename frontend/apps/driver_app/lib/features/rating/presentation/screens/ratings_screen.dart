import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../shared/widgets.dart';

final driverRatingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final response = await ClayApi.instance.dio.get('/drivers/me');
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>? ?? data;
  } on DioException catch (e) {
    final msg = (e.response?.data as Map<String, dynamic>?)?['message']?.toString() ?? e.message ?? 'Gagal memuat rating';
    throw Exception(msg);
  }
});

class RatingsScreen extends ConsumerWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsAsync = ref.watch(driverRatingsProvider);
    final data = ratingsAsync.valueOrNull ?? {};

    final ratingAvg = (data['rating_avg'] ?? data['rating'] ?? 0.0).toDouble();
    final totalTrips = data['total_trips'] ?? data['total_orders'] ?? 0;
    final distribution = data['rating_distribution'] as Map<String, dynamic>?;

    Color _ratingColor(double rating) {
      if (rating >= 4) return ClayColors.green;
      if (rating >= 3) return ClayColors.warning;
      return ClayColors.accent;
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
                  const Text('Rating Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: ratingsAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(colors: [_ratingColor(ratingAvg).withValues(alpha: 0.8), _ratingColor(ratingAvg), _ratingColor(ratingAvg).withValues(alpha: 0.8)]),
                            boxShadow: [BoxShadow(color: _ratingColor(ratingAvg).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: Column(
                            children: [
                              Text(ratingAvg.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (i) {
                                  final starRating = i + 1;
                                  final diff = ratingAvg - starRating;
                                  IconData icon;
                                  if (diff >= 0) {
                                    icon = Icons.star;
                                  } else if (diff >= -0.5) {
                                    icon = Icons.star_half;
                                  } else {
                                    icon = Icons.star_border;
                                  }
                                  return Icon(icon, size: 24, color: Colors.white.withValues(alpha: 0.9));
                                }),
                              ),
                              const SizedBox(height: 12),
                              Text('$totalTrips trip', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (distribution != null) ...[
                          const SectionHeader(title: 'Distribusi Rating'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: softShadow(),
                            child: Column(
                              children: List.generate(5, (i) {
                                final star = 5 - i;
                                final count = (distribution['$star'] ?? 0) is int
                                    ? (distribution['$star'] ?? 0) as int
                                    : int.tryParse((distribution['$star'] ?? 0).toString()) ?? 0;
                                final totalRatings = distribution.values.fold<int>(0, (sum, v) {
                                  final val = v is int ? v : int.tryParse(v.toString()) ?? 0;
                                  return sum + val;
                                });
                                final fraction = totalRatings > 0 ? count / totalRatings : 0.0;
                                final barColor = star >= 4 ? ClayColors.green : (star == 3 ? ClayColors.warning : ClayColors.accent);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('$star', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                                            const Icon(Icons.star, size: 12, color: ClayColors.warning),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: fraction,
                                            backgroundColor: ClayColors.muted,
                                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                            minHeight: 8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 24,
                                        child: Text('$count', style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary), textAlign: TextAlign.end),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        const SectionHeader(title: 'Riwayat Rating'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: softShadow(),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(Icons.rate_review_outlined, size: 36, color: ClayColors.textSecondary),
                                SizedBox(height: 8),
                                Text('Riwayat rating detail segera tersedia', style: TextStyle(color: ClayColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
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

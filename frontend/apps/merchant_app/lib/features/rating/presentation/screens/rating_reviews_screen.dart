import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/rating_provider.dart';

class RatingReviewsScreen extends ConsumerStatefulWidget {
  const RatingReviewsScreen({super.key});

  @override
  ConsumerState<RatingReviewsScreen> createState() => _RatingReviewsScreenState();
}

class _RatingReviewsScreenState extends ConsumerState<RatingReviewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(receivedRatingsProvider.notifier).loadRatings(refresh: true);
    });
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(dt);
      
      if (diff.inDays > 30) {
        return '${dt.day}/${dt.month}/${dt.year}';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} hari yang lalu';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} jam yang lalu';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (_) {
      return dateStr;
    }
  }

  Color _getRandomAvatarColor(String name) {
    final colors = [
      Colors.blue.shade400,
      Colors.indigo.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
    ];
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receivedRatingsProvider);

    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        title: const Text('Rating & Ulasan Toko'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        color: ClayColors.primary,
        onRefresh: () => ref.read(receivedRatingsProvider.notifier).loadRatings(refresh: true),
        child: state.isLoading && state.ratings.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Overall Summary Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Big score
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Text(
                                      state.averageScore.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: ClayColors.textPrimary,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        final isFilled = index < state.averageScore.round();
                                        return Icon(
                                          isFilled ? Icons.star : Icons.star_border,
                                          color: Colors.amber,
                                          size: 18,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Dari ${state.totalRatings} ulasan',
                                      style: const TextStyle(
                                        color: ClayColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Vertical divider
                              Container(
                                width: 1,
                                height: 80,
                                color: Colors.grey.shade200,
                              ),
                              
                              // Distribution bars
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Column(
                                    children: List.generate(5, (index) {
                                      final score = 5 - index;
                                      final count = state.scoreDistribution[score] ?? 0;
                                      final ratio = state.totalRatings > 0 ? count / state.totalRatings : 0.0;
                                      
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            Text(
                                              '$score',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: ClayColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.star, color: Colors.amber, size: 12),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: ratio,
                                                  backgroundColor: Colors.grey.shade100,
                                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                                  minHeight: 6,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 16,
                                              child: Text(
                                                '$count',
                                                textAlign: TextAlign.end,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: ClayColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Popular Tags Section
                  if (state.tagCounts.isNotEmpty) ...[
                    const Text(
                      'Topik Populer dari Pelanggan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.tagCounts.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: ClayColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: ClayColors.primary.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: ClayColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${entry.value})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ClayColors.primaryDark.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 3. Reviews List Section
                  const Text(
                    'Daftar Ulasan Pelanggan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  
                  if (state.ratings.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'Belum ada ulasan yang diterima',
                            style: TextStyle(color: ClayColors.textSecondary),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: state.ratings.map((review) {
                        final raterName = review['rater_name']?.toString() ?? 'Pelanggan';
                        final score = (review['score'] as num?)?.toInt() ?? 5;
                        final reviewText = review['review_text']?.toString() ?? review['comment']?.toString() ?? '';
                        final tags = (review['tags'] as List?)?.cast<String>() ?? [];
                        final time = _timeAgo(review['created_at']?.toString());
                        final initial = raterName.isNotEmpty ? raterName[0].toUpperCase() : 'P';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: _getRandomAvatarColor(raterName),
                                  child: Text(
                                    initial,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Name & Stars
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            raterName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: ClayColors.textPrimary,
                                            ),
                                          ),
                                          Row(
                                            children: List.generate(5, (idx) {
                                              return Icon(
                                                idx < score ? Icons.star : Icons.star_border,
                                                color: Colors.amber,
                                                size: 14,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      // Time
                                      Text(
                                        time,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: ClayColors.textSecondary,
                                        ),
                                      ),
                                      
                                      // Tags
                                      if (tags.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: tags.map((t) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.grey.shade200),
                                              ),
                                              child: Text(
                                                t,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],

                                      // Review text
                                      if (reviewText.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          reviewText,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.4,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}

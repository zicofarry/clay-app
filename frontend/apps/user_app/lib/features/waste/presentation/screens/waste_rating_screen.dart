import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/waste_provider.dart';

class WasteRatingScreen extends ConsumerStatefulWidget {
  const WasteRatingScreen({super.key});

  @override
  ConsumerState<WasteRatingScreen> createState() => _WasteRatingScreenState();
}

class _WasteRatingScreenState extends ConsumerState<WasteRatingScreen> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  final Set<String> _selectedTags = {};

  static const _tags = [
    ('careful', 'Hati-hati'),
    ('on_time', 'Tepat Waktu'),
    ('friendly', 'Ramah'),
    ('fast', 'Cepat'),
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wasteStateProvider);
    final driverName = state.driverInfo?['name'] as String? ?? 'Kurir';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ── Header ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: ClayColors.muted, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Beri Rating', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 40),

              // ── Driver avatar ──
              CircleAvatar(
                radius: 36,
                backgroundColor: ClayColors.muted,
                backgroundImage: (state.driverInfo?['photo_url'] as String? ?? '').isNotEmpty
                    ? NetworkImage(state.driverInfo!['photo_url'] as String)
                    : null,
                child: (state.driverInfo?['photo_url'] as String? ?? '').isEmpty
                    ? const Icon(Icons.person, size: 36, color: ClayColors.textSecondary)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(driverName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const Text('Kurir ClayWaste', style: TextStyle(fontSize: 14, color: ClayColors.textSecondary)),

              const SizedBox(height: 28),

              // ── Stars ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _ratingLabels[_rating] ?? '',
                style: const TextStyle(fontSize: 14, color: ClayColors.textSecondary),
              ),

              const SizedBox(height: 28),

              // ── Tags ──
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((t) {
                  final isSelected = _selectedTags.contains(t.$1);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedTags.remove(t.$1);
                        } else {
                          _selectedTags.add(t.$1);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? ClayColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? ClayColors.primary : ClayColors.divider),
                      ),
                      child: Text(
                        t.$2,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : ClayColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ── Comment ──
              TextField(
                controller: _commentCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar (opsional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),

              const Spacer(),

              // ── Submit ──
              ClayButton(
                label: 'Kirim Rating',
                isLoading: state.isLoading,
                onPressed: state.isLoading ? null : _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() async {
    await ref.read(wasteStateProvider.notifier).submitRating(
      score: _rating,
      comment: _commentCtrl.text.trim(),
      tags: _selectedTags.toList(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terima kasih atas rating kamu!'), backgroundColor: Colors.green),
    );
    ref.read(wasteStateProvider.notifier).resetWaste();
    context.go('/home');
  }

  static const _ratingLabels = {
    1: 'Sangat Buruk',
    2: 'Buruk',
    3: 'Biasa',
    4: 'Bagus',
    5: 'Sangat Bagus',
  };
}

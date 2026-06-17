import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/ride_provider.dart';

class RideRatingScreen extends ConsumerStatefulWidget {
  const RideRatingScreen({super.key});

  @override
  ConsumerState<RideRatingScreen> createState() => _RideRatingScreenState();
}

class _RideRatingScreenState extends ConsumerState<RideRatingScreen>
    with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  final Set<String> _selectedTags = {};
  final _commentController = TextEditingController();
  late final AnimationController _starController;

  static const _tags = [
    'Ramah',
    'Rapi',
    'Aman',
    'Tepat Waktu',
    'Kendaraan Bersih',
    'Komunikatif',
    'Tahu Jalan',
    'AC Sejuk',
  ];

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

  }

  @override
  void dispose() {
    _commentController.dispose();
    _starController.dispose();
    super.dispose();
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Buruk';
      case 2:
        return 'Kurang';
      case 3:
        return 'Cukup';
      case 4:
        return 'Bagus';
      case 5:
        return 'Luar Biasa!';
      default:
        return '';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return ClayColors.accent;
      case 2:
        return ClayColors.warning;
      case 3:
        return ClayColors.warningDark;
      case 4:
        return ClayColors.green;
      case 5:
        return ClayColors.green;
      default:
        return ClayColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideStateProvider);
    final driver = state.driverInfo;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  const Expanded(
                    child: Text(
                      'Beri Rating',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _skip(),
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        fontSize: 14,
                        color: ClayColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // ── Driver avatar ──
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: ClayColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ClayColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: ClayColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      driver?['name'] as String? ?? 'Driver',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${driver?['vehicle'] ?? ''} • ${driver?['plate'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: ClayColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Star rating ──
                    const Text(
                      'Bagaimana perjalananmu?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNum = index + 1;
                        final isSelected = starNum <= _selectedRating;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedRating = starNum);
                            _starController.forward(from: 0);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedScale(
                              scale: isSelected ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isSelected ? Icons.star : Icons.star_border,
                                color: isSelected
                                    ? ClayColors.warningDark
                                    : ClayColors.divider,
                                size: 44,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    if (_selectedRating > 0) ...[
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _getRatingLabel(_selectedRating),
                          key: ValueKey(_selectedRating),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _getRatingColor(_selectedRating),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── Quick tags ──
                    if (_selectedRating > 0) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Apa yang kamu suka?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          final isActive = _selectedTags.contains(tag);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isActive) {
                                  _selectedTags.remove(tag);
                                } else {
                                  _selectedTags.add(tag);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? ClayColors.primary.withValues(alpha: 0.12)
                                    : ClayColors.muted,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? ClayColors.primary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                  color: isActive
                                      ? ClayColors.primaryDark
                                      : ClayColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // ── Comment ──
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Komentar (opsional)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _commentController,
                        maxLines: 3,
                        maxLength: 200,
                        decoration: InputDecoration(
                          hintText: 'Tulis komentarmu...',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: ClayColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: ClayColors.muted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: ClayColors.primary),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                          counterStyle: const TextStyle(
                            fontSize: 11,
                            color: ClayColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Submit button ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClayButton(
                label: _selectedRating > 0 ? 'Kirim Rating' : 'Pilih rating dulu',
                isLoading: state.isLoading,
                onPressed: _selectedRating > 0 ? _onSubmit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() async {
    await ref.read(rideStateProvider.notifier).submitRating(
          score: _selectedRating,
          comment: _commentController.text,
          tags: _selectedTags.toList(),
        );

    if (mounted) {
      // Show thank you snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Terima kasih atas ratingnya! 🎉'),
          backgroundColor: ClayColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      ref.read(rideStateProvider.notifier).resetRide();
      context.go('/home');
    }
  }

  void _skip() {
    ref.read(rideStateProvider.notifier).resetRide();
    context.go('/home');
  }
}

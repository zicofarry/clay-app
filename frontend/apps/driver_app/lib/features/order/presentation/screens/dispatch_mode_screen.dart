import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../../shared/widgets.dart';
import '../../../home/presentation/screens/driver_home_screen.dart';
import '../providers/order_provider.dart';

final selectedDispatchModeProvider = StateProvider<String?>((ref) => null);

class DispatchModeScreen extends ConsumerStatefulWidget {
  const DispatchModeScreen({super.key});

  @override
  ConsumerState<DispatchModeScreen> createState() => _DispatchModeScreenState();
}

class _DispatchModeScreenState extends ConsumerState<DispatchModeScreen> {
  bool _isGoingOnline = false;

  Future<void> _goOnline() async {
    final mode = ref.read(selectedDispatchModeProvider);
    if (mode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis layanan terlebih dahulu')),
      );
      return;
    }
    setState(() => _isGoingOnline = true);
    try {
      final repo = ref.read(orderRepositoryProvider);
      await repo.setDispatchMode(mode);
      await repo.goOnline(serviceType: mode);
      ref.read(isOnlineProvider.notifier).state = true;
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoingOnline = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMode = ref.watch(selectedDispatchModeProvider);

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
                  const Text('Pilih Layanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const Text(
                    'Pilih jenis layanan yang ingin Anda jalankan hari ini',
                    style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  _DispatchCard(
                    icon: Icons.directions_car,
                    title: 'Ride',
                    subtitle: 'Transportasi penumpang',
                    color: ClayColors.primary,
                    isSelected: selectedMode == 'ride',
                    onTap: () => ref.read(selectedDispatchModeProvider.notifier).state = 'ride',
                  ),
                  const SizedBox(height: 12),

                  _DispatchCard(
                    icon: Icons.restaurant,
                    title: 'Food',
                    subtitle: 'Antar makanan',
                    color: ClayColors.warning,
                    isSelected: selectedMode == 'food',
                    onTap: () => ref.read(selectedDispatchModeProvider.notifier).state = 'food',
                  ),
                  const SizedBox(height: 12),

                  _DispatchCard(
                    icon: Icons.local_shipping,
                    title: 'Delivery',
                    subtitle: 'Antar paket',
                    color: ClayColors.green,
                    isSelected: selectedMode == 'delivery',
                    onTap: () => ref.read(selectedDispatchModeProvider.notifier).state = 'delivery',
                  ),
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: _isGoingOnline ? null : _goOnline,
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: selectedMode != null
                            ? const LinearGradient(colors: [ClayColors.green, ClayColors.greenDark])
                            : null,
                        color: selectedMode != null ? null : ClayColors.muted,
                        boxShadow: selectedMode != null
                            ? [BoxShadow(color: ClayColors.green.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]
                            : null,
                      ),
                      child: Center(
                        child: _isGoingOnline
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.power_settings_new, size: 20, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mulai Online',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: selectedMode != null ? Colors.white : ClayColors.textSecondary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
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

class _DispatchCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DispatchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : ClayColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 28, color: isSelected ? Colors.white : color),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ClayColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary)),
            ])),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isSelected ? color : ClayColors.muted,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? color : ClayColors.divider, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

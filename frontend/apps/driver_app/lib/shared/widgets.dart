import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';

BoxDecoration softShadow({Color? color}) {
  return BoxDecoration(
    color: color ?? ClayColors.card,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
    ],
  );
}

BoxDecoration elevatedShadow({Color? color}) {
  return BoxDecoration(
    color: color ?? Colors.transparent,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8)),
      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
    ],
  );
}

class DriverBottomNav extends StatelessWidget {
  final String current;

  const DriverBottomNav({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('/home', Icons.directions_car_outlined, 'Beranda'),
      ('/history', Icons.access_time_rounded, 'Riwayat'),
      ('/earnings', Icons.account_balance_wallet_outlined, 'Pendapatan'),
      ('/profile', Icons.person_outline, 'Profil'),
    ];

    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final active = item.$1 == current;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!active) context.go(item.$1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.$2, size: 24, color: active ? ClayColors.primary : ClayColors.textSecondary),
                        const SizedBox(height: 4),
                        Text(item.$3, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: active ? ClayColors.primary : ClayColors.textSecondary)),
                        if (active) ...[
                          const SizedBox(height: 4),
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: ClayColors.primary, shape: BoxShape.circle)),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(actionLabel!, style: const TextStyle(fontSize: 12, color: ClayColors.primary, fontWeight: FontWeight.w500)),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right, size: 14, color: ClayColors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

class ClayToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ClayToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 28,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? ClayColors.primary : ClayColors.muted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),
        ),
      ),
    );
  }
}

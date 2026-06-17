import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/preferences_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bahasa')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ClayColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.translate, color: ClayColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pilih bahasa yang kamu gunakan sehari-hari.',
                    style: TextStyle(fontSize: 12, color: ClayColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final entry in LanguageNotifier.supported)
            _LanguageTile(
              code: entry.key,
              label: entry.value,
              isSelected: current.code == entry.key,
              onTap: () => _select(context, ref, entry.key),
            ),
          const SizedBox(height: 24),
          const Text(
            'Catatan: Konten aplikasi masih sebagian dalam Bahasa Indonesia. Pilihan ini disimpan di perangkat dan dikirim ke server.',
            style: TextStyle(fontSize: 11, color: ClayColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _select(BuildContext context, WidgetRef ref, String code) async {
    final ok = await ref.read(languageProvider.notifier).setLanguage(code);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(ok ? 'Bahasa disimpan' : 'Bahasa disimpan di perangkat (gagal sync ke server)'),
        backgroundColor: ok ? Colors.green : Colors.orange,
      ));
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _LanguageTile({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _flag {
    switch (code) {
      case 'id':
        return Icons.flag;
      case 'en':
        return Icons.flag_outlined;
      default:
        return Icons.language;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isSelected ? ClayColors.primary : ClayColors.divider),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (isSelected ? ClayColors.primary : Colors.grey).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_flag, color: isSelected ? ClayColors.primary : Colors.grey.shade700),
        ),
        title: Text(label, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
        subtitle: Text(code == 'id' ? 'Bahasa utama' : 'Secondary language',
            style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: ClayColors.primary)
            : const Icon(Icons.circle_outlined, color: Colors.grey, size: 22),
      ),
    );
  }
}

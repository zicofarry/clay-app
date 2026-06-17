import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clay_ui/clay_ui.dart';

class AvatarPickerSheet extends StatelessWidget {
  final bool hasExisting;
  const AvatarPickerSheet({super.key, required this.hasExisting});

  static Future<XFile?> show(BuildContext context, {bool hasExisting = false}) async {
    return showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerSheet(hasExisting: hasExisting),
    );
  }

  Future<XFile?> _pick(ImageSource src) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: src,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return file;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: ClayColors.divider, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Ubah Foto Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text(
            'Pilih sumber foto',
            style: TextStyle(fontSize: 12, color: ClayColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PickOption(
                icon: Icons.camera_alt_outlined,
                iconColor: Colors.blue,
                label: 'Kamera',
                onTap: () async {
                  final file = await _pick(ImageSource.camera);
                  if (!context.mounted) return;
                  Navigator.of(context).pop(file);
                },
              ),
              _PickOption(
                icon: Icons.photo_library_outlined,
                iconColor: Colors.purple,
                label: 'Galeri',
                onTap: () async {
                  final file = await _pick(ImageSource.gallery);
                  if (!context.mounted) return;
                  Navigator.of(context).pop(file);
                },
              ),
              if (hasExisting)
                _PickOption(
                  icon: Icons.delete_outline,
                  iconColor: ClayColors.error,
                  label: 'Hapus',
                  onTap: () => Navigator.of(context).pop(null),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal', style: TextStyle(color: ClayColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _PickOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  const _PickOption({required this.icon, required this.iconColor, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

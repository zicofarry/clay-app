import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clay_ui/clay_ui.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _packageName = 'com.clay.user_app';
  static const _playStoreUrl = 'https://play.google.com/store/apps/details?id=$_packageName';
  static const _websiteUrl = 'https://clay.example.com';
  static const _privacyUrl = 'https://clay.example.com/privacy';
  static const _termsUrl = 'https://clay.example.com/terms';

  Future<void> _open(String url, BuildContext ctx, String label) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (ctx.mounted) {
      ScaffoldMessenger.of(ctx)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Tidak bisa membuka $label')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ClayColors.primary, ClayColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: ClayColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('Clay', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Versi 1.0.0 (build 1)',
              style: TextStyle(fontSize: 12, color: ClayColors.textSecondary),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: InkWell(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: '1.0.0+1'));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('Versi disalin')));
              },
              child: const Text(
                'Tap untuk salin versi',
                style: TextStyle(fontSize: 10, color: ClayColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _AboutCard(
            children: [
              _AboutTile(
                icon: Icons.public,
                iconColor: Colors.green,
                title: 'Website',
                subtitle: 'clay.example.com',
                onTap: () => _open(_websiteUrl, context, 'website'),
              ),
              _AboutTile(
                icon: Icons.star_rounded,
                iconColor: Colors.amber,
                title: 'Beri Rating',
                subtitle: 'Google Play Store',
                onTap: () => _open(_playStoreUrl, context, 'Play Store'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AboutCard(
            children: [
              _AboutTile(
                icon: Icons.shield_outlined,
                iconColor: Colors.indigo,
                title: 'Kebijakan Privasi',
                onTap: () => _open(_privacyUrl, context, 'kebijakan privasi'),
              ),
              _AboutTile(
                icon: Icons.description_outlined,
                iconColor: Colors.blue,
                title: 'Syarat & Ketentuan',
                onTap: () => _open(_termsUrl, context, 'syarat & ketentuan'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              '© 2026 Clay Platform. All rights reserved.',
              style: TextStyle(fontSize: 11, color: ClayColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final List<_AboutTile> children;
  const _AboutCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 56, color: ClayColors.divider),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _AboutTile({required this.icon, required this.iconColor, required this.title, required this.onTap, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary))
          : null,
      trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
    );
  }
}

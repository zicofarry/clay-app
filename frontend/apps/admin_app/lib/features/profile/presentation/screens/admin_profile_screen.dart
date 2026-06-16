import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../auth/presentation/providers/admin_auth_provider.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(adminAuthProvider).admin;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: ClayColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: ClayColors.divider)),
            child: Row(children: [
              CircleAvatar(radius: 30, backgroundColor: ClayColors.primary, child: const Icon(Icons.admin_panel_settings, size: 30, color: Colors.white)),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a?['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                Text(a?['role'] ?? '', style: const TextStyle(color: Colors.grey)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.email), title: Text(a?['email'] ?? ''), subtitle: const Text('Email')),
          ])),
          const SizedBox(height: 24),
          ClayButton(label: 'Keluar', backgroundColor: ClayColors.error, onPressed: () => context.go('/login')),
        ],
      ),
    );
  }
}

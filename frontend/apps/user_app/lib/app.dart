import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import 'routing/app_router.dart';

class UserApp extends ConsumerWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Clay - User',
      debugShowCheckedModeBanner: false,
      theme: ClayTheme.light,
      routerConfig: router,
    );
  }
}

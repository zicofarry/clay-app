import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/admin_login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/users/presentation/screens/users_screen.dart';
import '../features/drivers/presentation/screens/drivers_list_screen.dart';
import '../features/merchants/presentation/screens/merchants_list_screen.dart';
import '../features/profile/presentation/screens/admin_profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const AdminLoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/users', builder: (_, __) => const UsersScreen()),
      GoRoute(path: '/drivers', builder: (_, __) => const DriversListScreen()),
      GoRoute(path: '/merchants', builder: (_, __) => const MerchantsListScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const AdminProfileScreen()),
    ],
  );
});

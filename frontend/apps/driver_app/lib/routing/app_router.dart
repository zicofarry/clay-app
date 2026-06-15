import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/driver_login_screen.dart';
import '../features/home/presentation/screens/driver_home_screen.dart';
import '../features/order/presentation/screens/order_detail_screen.dart';
import '../features/earning/presentation/screens/earning_screen.dart';
import '../features/profile/presentation/screens/driver_profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const DriverLoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const DriverHomeScreen()),
      GoRoute(path: '/order/:id', builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/earning', builder: (_, __) => const EarningScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const DriverProfileScreen()),
    ],
  );
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/driver_login_screen.dart';
import '../features/home/presentation/screens/driver_home_screen.dart';
import '../features/order/presentation/screens/order_detail_screen.dart';
import '../features/earning/presentation/screens/earning_screen.dart';
import '../features/profile/presentation/screens/driver_profile_screen.dart';
import '../features/trip/presentation/screens/active_trip_screen.dart';
import '../features/trip/presentation/screens/trip_complete_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/history/presentation/screens/history_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/help/presentation/screens/help_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const DriverLoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const DriverHomeScreen()),
      GoRoute(path: '/order/:id', builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/earnings', builder: (_, __) => const EarningScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const DriverProfileScreen()),
      GoRoute(path: '/active-trip', builder: (_, __) => const ActiveTripScreen()),
      GoRoute(path: '/trip-complete', builder: (_, __) => const TripCompleteScreen()),
      GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    ],
  );
});

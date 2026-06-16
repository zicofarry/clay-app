import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/merchant_login_screen.dart';
import '../features/home/presentation/screens/merchant_home_screen.dart';
import '../features/menu/presentation/screens/menu_list_screen.dart';
import '../features/orders/presentation/screens/order_list_screen.dart';
import '../features/orders/presentation/screens/order_detail_screen.dart';
import '../features/profile/presentation/screens/merchant_profile_screen.dart';
import '../features/report/presentation/screens/report_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const MerchantLoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const MerchantHomeScreen()),
      GoRoute(path: '/menu', builder: (_, __) => const MenuListScreen()),
      GoRoute(path: '/orders', builder: (_, __) => const OrderListScreen()),
      GoRoute(path: '/order/:id', builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/report', builder: (_, __) => const ReportScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const MerchantProfileScreen()),
    ],
  );
});

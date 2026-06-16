import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/ride/presentation/screens/ride_home_screen.dart';
import '../features/ride/presentation/screens/ride_tracking_screen.dart';
import '../features/food/presentation/screens/merchant_list_screen.dart';
import '../features/food/presentation/screens/menu_screen.dart';
import '../features/food/presentation/screens/cart_screen.dart';
import '../features/food/presentation/screens/checkout_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/history/presentation/screens/history_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/ride',
        builder: (_, __) => const RideHomeScreen(),
      ),
      GoRoute(
        path: '/ride/tracking',
        builder: (_, __) => const RideTrackingScreen(),
      ),
      GoRoute(
        path: '/food',
        builder: (_, __) => const MerchantListScreen(),
      ),
      GoRoute(
        path: '/food/menu/:merchantId',
        builder: (_, state) => MenuScreen(merchantId: state.pathParameters['merchantId']!),
      ),
      GoRoute(
        path: '/food/cart',
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: '/food/checkout',
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (_, __) => const WalletScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (_, __) => const HistoryScreen(),
      ),
    ],
  );
});

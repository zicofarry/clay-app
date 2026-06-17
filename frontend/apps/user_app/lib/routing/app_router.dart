import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_shared/clay_shared.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
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
import '../features/common/presentation/screens/placeholder_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/location/presentation/screens/location_picker_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _authRoutes = {'/login', '/register', '/forgot-password', '/reset-password', '/onboarding'};

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final isLoggedIn = ClayApi.instance.hasToken();
      final isAuthRoute = _authRoutes.contains(state.uri.toString());

      if (!isLoggedIn && !isAuthRoute) {
        return '/onboarding';
      }
      if (isLoggedIn && isAuthRoute && state.uri.toString() != '/onboarding') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return ResetPasswordScreen(
            phoneNumber: extra['phone'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: '/location-picker',
        builder: (_, __) => const LocationPickerScreen(),
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
      GoRoute(
        path: '/car',
        builder: (_, __) => const PlaceholderScreen(serviceName: 'ClayCar'),
      ),
      GoRoute(
        path: '/send',
        builder: (_, __) => const PlaceholderScreen(serviceName: 'ClaySend'),
      ),
      GoRoute(
        path: '/pet',
        builder: (_, __) => const PlaceholderScreen(serviceName: 'ClayPet'),
      ),
      GoRoute(
        path: '/waste',
        builder: (_, __) => const PlaceholderScreen(serviceName: 'ClayWaste'),
      ),
      GoRoute(
        path: '/care',
        builder: (_, __) => const PlaceholderScreen(serviceName: 'ClayCare'),
      ),
      GoRoute(
        path: '/other',
        builder: (_, __) => const PlaceholderScreen(serviceName: 'Other'),
      ),
    ],
  );
});

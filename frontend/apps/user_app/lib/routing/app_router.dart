import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_shared/clay_shared.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/sessions_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/ride/presentation/screens/ride_home_screen.dart';
import '../features/ride/presentation/screens/ride_confirm_screen.dart';
import '../features/ride/presentation/screens/ride_searching_screen.dart';
import '../features/ride/presentation/screens/ride_tracking_screen.dart';
import '../features/ride/presentation/screens/ride_on_trip_screen.dart';
import '../features/ride/presentation/screens/ride_complete_screen.dart';
import '../features/ride/presentation/screens/ride_rating_screen.dart';
import '../features/send/presentation/screens/send_home_screen.dart';
import '../features/send/presentation/screens/send_confirm_screen.dart';
import '../features/send/presentation/screens/send_searching_screen.dart';
import '../features/send/presentation/screens/send_tracking_screen.dart';
import '../features/send/presentation/screens/send_complete_screen.dart';
import '../features/send/presentation/screens/send_rating_screen.dart';
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
import '../features/location/presentation/screens/address_list_screen.dart';
import '../features/payment/presentation/screens/payment_methods_screen.dart';
import '../features/settings/presentation/screens/notification_settings_screen.dart';
import '../features/settings/presentation/screens/language_screen.dart';
import '../features/about/presentation/screens/about_screen.dart';
import '../features/about/presentation/screens/rate_app_screen.dart';
import '../features/help/presentation/screens/help_center_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _authRoutes = {'/login', '/register', '/forgot-password', '/otp-verification', '/reset-password', '/onboarding'};

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
        path: '/otp-verification',
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return OtpVerificationScreen(
            phoneNumber: extra['phone'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return ResetPasswordScreen(
            phoneNumber: extra['phone'] ?? '',
            resetToken: extra['resetToken'] ?? '',
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
        path: '/ride/confirm',
        builder: (_, __) => const RideConfirmScreen(),
      ),
      GoRoute(
        path: '/ride/searching',
        builder: (_, __) => const RideSearchingScreen(),
      ),
      GoRoute(
        path: '/ride/tracking',
        builder: (_, __) => const RideTrackingScreen(),
      ),
      GoRoute(
        path: '/ride/on-trip',
        builder: (_, __) => const RideOnTripScreen(),
      ),
      GoRoute(
        path: '/ride/complete',
        builder: (_, __) => const RideCompleteScreen(),
      ),
      GoRoute(
        path: '/ride/rating',
        builder: (_, __) => const RideRatingScreen(),
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
        path: '/sessions',
        builder: (_, __) => const SessionsScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (_, __) => const AddressListScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        builder: (_, __) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/language',
        builder: (_, __) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/rate',
        builder: (_, __) => const RateAppScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (_, __) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (_, __) => const AboutScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (_, __) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/car',
        builder: (_, __) => const RideHomeScreen(),
      ),
      GoRoute(
        path: '/send',
        builder: (_, __) => const SendHomeScreen(),
      ),
      GoRoute(
        path: '/send/confirm',
        builder: (_, __) => const SendConfirmScreen(),
      ),
      GoRoute(
        path: '/send/searching',
        builder: (_, __) => const SendSearchingScreen(),
      ),
      GoRoute(
        path: '/send/tracking',
        builder: (_, __) => const SendTrackingScreen(),
      ),
      GoRoute(
        path: '/send/complete',
        builder: (_, __) => const SendCompleteScreen(),
      ),
      GoRoute(
        path: '/send/rating',
        builder: (_, __) => const SendRatingScreen(),
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

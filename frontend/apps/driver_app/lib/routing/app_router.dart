import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/driver_login_screen.dart';
import '../features/auth/presentation/screens/driver_register_screen.dart';
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
import '../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../features/settings/presentation/screens/change_password_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/documents_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/rating/presentation/screens/ratings_screen.dart';
import '../features/voucher/presentation/screens/vouchers_screen.dart';
import '../features/order/presentation/screens/food_order_screen.dart';
import '../features/order/presentation/screens/delivery_order_screen.dart';
import '../features/order/presentation/screens/dispatch_mode_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const DriverLoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const DriverRegisterScreen()),
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
      GoRoute(path: '/notification-preferences', builder: (_, __) => const NotificationPreferencesScreen()),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/documents', builder: (_, __) => const DocumentsScreen()),
      GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/ratings', builder: (_, __) => const RatingsScreen()),
      GoRoute(path: '/vouchers', builder: (_, __) => const VouchersScreen()),
      GoRoute(path: '/food-order/:id', builder: (_, state) => FoodOrderScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/delivery-order/:id', builder: (_, state) => DeliveryOrderScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/dispatch-mode', builder: (_, __) => const DispatchModeScreen()),
    ],
  );
});

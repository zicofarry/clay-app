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
      GoRoute(
        path: '/login',
        builder: (context, state) => const DriverLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/login',
          child: DriverRegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) => RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: OrderDetailScreen(orderId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/earnings',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: EarningScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: DriverProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/active-trip',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: ActiveTripScreen(),
        ),
      ),
      GoRoute(
        path: '/trip-complete',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: TripCompleteScreen(),
        ),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: ChatScreen(),
        ),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: HistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/profile',
          child: SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/profile',
          child: HelpScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/notification-preferences',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/settings',
          child: NotificationPreferencesScreen(),
        ),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/settings',
          child: ChangePasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/profile',
          child: EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/profile',
          child: DocumentsScreen(),
        ),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/profile',
          child: WalletScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/login',
          child: ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/ratings',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/profile',
          child: RatingsScreen(),
        ),
      ),
      GoRoute(
        path: '/vouchers',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/profile',
          child: VouchersScreen(),
        ),
      ),
      GoRoute(
        path: '/food-order/:id',
        builder: (context, state) => RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: FoodOrderScreen(orderId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/delivery-order/:id',
        builder: (context, state) => RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: DeliveryOrderScreen(orderId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/dispatch-mode',
        builder: (context, state) => const RoutePopScopeWrapper(
          fallbackRoute: '/home',
          child: DispatchModeScreen(),
        ),
      ),
    ],
  );
});

class RoutePopScopeWrapper extends StatelessWidget {
  final Widget child;
  final String fallbackRoute;

  const RoutePopScopeWrapper({
    super.key,
    required this.child,
    required this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.canPop(context)) {
          context.pop();
        } else {
          context.go(fallbackRoute);
        }
      },
      child: child,
    );
  }
}

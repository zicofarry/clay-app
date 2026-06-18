import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/merchant_login_screen.dart';
import '../features/home/presentation/screens/merchant_home_screen.dart';
import '../features/orders/presentation/screens/order_detail_screen.dart';
import '../features/report/presentation/screens/report_screen.dart';
import '../features/wallet/presentation/screens/wallet_dashboard_screen.dart';
import '../features/wallet/presentation/screens/topup_screen.dart';
import '../features/wallet/presentation/screens/transfer_screen.dart';
import '../features/wallet/presentation/screens/payment_methods_screen.dart';
import '../features/chat/presentation/screens/chat_room_screen.dart';
import '../features/rating/presentation/screens/rating_reviews_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const MerchantLoginScreen()),
      GoRoute(path: '/home', builder: (_, _) => const MerchantHomeScreen()),
      GoRoute(path: '/order/:id', builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/order/:id/chat', builder: (_, state) => ChatRoomScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/report', builder: (_, _) => const ReportScreen()),
      GoRoute(path: '/wallet', builder: (_, _) => const WalletDashboardScreen()),
      GoRoute(path: '/wallet/topup', builder: (_, _) => const TopUpScreen()),
      GoRoute(path: '/wallet/transfer', builder: (_, _) => const TransferScreen()),
      GoRoute(path: '/wallet/payment-methods', builder: (_, _) => const PaymentMethodsScreen()),
      GoRoute(path: '/profile/reviews', builder: (_, _) => const RatingReviewsScreen()),
    ],
  );
});

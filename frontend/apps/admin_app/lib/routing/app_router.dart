import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/admin_login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/users/presentation/screens/users_screen.dart';
import '../features/drivers/presentation/screens/drivers_list_screen.dart';
import '../features/merchants/presentation/screens/merchants_list_screen.dart';
import '../features/transactions/presentation/screens/transactions_screen.dart';
import '../features/profile/presentation/screens/admin_profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/dashboard/presentation/screens/notifications_screen.dart';
import '../features/admins/presentation/screens/admin_management_screen.dart';
import '../features/admins/presentation/screens/audit_log_screen.dart';
import '../features/security/presentation/screens/security_fraud_screen.dart';
import '../features/security/presentation/screens/fraud_detail_screen.dart';
import '../features/support/presentation/screens/customer_support_screen.dart';
import '../features/finance/presentation/screens/finance_withdrawal_screen.dart';

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
      GoRoute(path: '/transactions', builder: (_, __) => const TransactionsScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const AdminProfileScreen()),
      GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/admin-management', builder: (_, __) => const AdminManagementScreen()),
      GoRoute(path: '/audit-log', builder: (_, __) => const AuditLogScreen()),
      GoRoute(path: '/security', builder: (_, __) => const SecurityFraudScreen()),
      GoRoute(path: '/fraud-detail', builder: (_, __) => const FraudDetailScreen()),
      GoRoute(path: '/support', builder: (_, __) => const CustomerSupportScreen()),
      GoRoute(path: '/finance', builder: (_, __) => const FinanceWithdrawalScreen()),
    ],
  );
});

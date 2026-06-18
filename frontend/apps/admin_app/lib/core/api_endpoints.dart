class ApiEndpoint {
  static const String login = '/auth/login';
  static const String profile = '/users/me';
  static const String userDetail = '/users';
  static const String driverDetail = '/drivers';
  static const String driverStatus = '/drivers';
  static const String merchants = '/merchants';
  static const String merchantDetail = '/merchants';
  static const String transactions = '/transactions';
  static const String historyTransactions = '/history/transactions';
  static const String historyOrderStats = '/history/orders/stats';
  static const String notifications = '/notifications';
  static const String notificationDetail = '/notifications';
  static const String auditLogs = '/audit/admin/logs';
  static const String auditLogStats = '/audit/admin/logs/stats';
  static const String auditLogDetail = '/audit/admin/logs';
  static const String fraudFlags = '/security/admin/fraud-flags';
  static const String fraudFlagDetail = '/security/admin/fraud-flags';
  static const String fraudFlagResolve = '/security/admin/fraud-flags';
  static const String ipBlacklist = '/security/admin/ip-blacklist';
  static const String userFraudSummary = '/security/admin/users';
}

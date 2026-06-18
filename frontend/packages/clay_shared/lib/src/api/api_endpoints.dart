class ApiEndpoints {
  ApiEndpoints._();

  static const String _prefix = '';

  // Auth
  static const String register = '$_prefix/auth/register';
  static const String login = '$_prefix/auth/login';
  static const String requestOtp = '$_prefix/auth/request-otp';
  static const String verifyOtp = '$_prefix/auth/verify-otp';
  static const String refreshToken = '$_prefix/auth/refresh-token';
  static const String logout = '$_prefix/auth/logout';
  static const String forgotPassword = '$_prefix/auth/password/forgot';
  static const String resetPassword = '$_prefix/auth/password/reset';
  static const String sessions = '$_prefix/auth/sessions';
  static const String revokeAllSessions = '$_prefix/auth/sessions/revoke-all';
  static String revokeSession(String sessionId) => '$_prefix/auth/sessions/$sessionId';

  // User
  static const String getProfile = '$_prefix/users/me';
  static const String updateProfile = '$_prefix/users/me';
  static const String updateAvatar = '$_prefix/users/me/avatar';
  static const String addresses = '$_prefix/addresses';
  static const String settings = '$_prefix/settings';
  static String userById(String userId) => '$_prefix/users/$userId';

  // Ride
  static const String rideEstimate = '$_prefix/ride/orders/estimate';
  static const String rideCreate = '$_prefix/ride/orders';
  static const String rideActive = '$_prefix/ride/orders/active';
  static const String rideHistory = '$_prefix/ride/orders/history';
  static String rideOrder(String orderId) => '$_prefix/ride/orders/$orderId';
  static String cancelRideOrder(String orderId) => '$_prefix/ride/orders/$orderId/cancel';
  static String rateRideOrder(String orderId) => '$_prefix/ride/orders/$orderId/rate';
  static String fareBreakdownRide(String orderId) => '$_prefix/ride/orders/$orderId/fare-breakdown';

  // Delivery (ClaySend)
  static const String deliveryEstimate = '$_prefix/delivery/orders/estimate';
  static const String deliveryCreate = '$_prefix/delivery/orders';
  static const String deliveryActive = '$_prefix/delivery/orders/active';
  static const String deliveryHistory = '$_prefix/delivery/orders/history';
  static String deliveryOrder(String orderId) => '$_prefix/delivery/orders/$orderId';
  static String cancelDeliveryOrder(String orderId) => '$_prefix/delivery/orders/$orderId/cancel';
  static String rateDeliveryOrder(String orderId) => '$_prefix/delivery/orders/$orderId/rate';
  static String fareBreakdownDelivery(String orderId) => '$_prefix/delivery/orders/$orderId/fare-breakdown';

  // Food
  static const String foodEstimate = '$_prefix/food/orders/estimate';
  static const String foodCreate = '$_prefix/food/orders';
  static const String foodActive = '$_prefix/food/orders/active';
  static const String foodHistory = '$_prefix/food/orders/history';
  static String foodOrder(String orderId) => '$_prefix/food/orders/$orderId';
  static String cancelFoodOrder(String orderId) => '$_prefix/food/orders/$orderId/cancel';
  static String rateFoodOrder(String orderId) => '$_prefix/food/orders/$orderId/rate';
  static String fareBreakdownFood(String orderId) => '$_prefix/food/orders/$orderId/fare-breakdown';

  // Wallet
  static const String wallet = '$_prefix/wallet';
  static const String walletTopUp = '$_prefix/wallet/topup';
  static const String walletTransfer = '$_prefix/wallet/transfer';
  static const String walletTransactions = '$_prefix/wallet/transactions';

  // Payment
  static const String paymentMethods = '$_prefix/payment-methods';
  static const String transactions = '$_prefix/transactions';

  // Driver
  static const String driverRegister = '$_prefix/drivers/register';
  static const String driverProfile = '$_prefix/drivers/me';
  static const String driverOnline = '$_prefix/dispatcher/go-online';
  static const String driverOffline = '$_prefix/dispatcher/go-offline';

  // Merchant
  static const String merchants = '$_prefix/merchants';
  static const String merchantMenuItems = '$_prefix/merchants';

  // History
  static const String historyOrders = '$_prefix/history/orders';
  static const String historyTransactions = '$_prefix/history/transactions';

  // Search
  static const String searchMerchants = '$_prefix/search/merchants';
  static const String searchMenuItems = '$_prefix/search/menu-items';
  static const String searchSuggest = '$_prefix/search/suggest';
  static const String searchTrending = '$_prefix/search/trending';
  static const String searchPopular = '$_prefix/search/popular';

  // Chat
  static const String chatRooms = '$_prefix/rooms';
  static const String chatCreateDirect = '$_prefix/rooms/direct';
  static String chatRoomByOrder(String orderId) => '$_prefix/rooms/by-order/$orderId';
  static String chatRoom(String roomId) => '$_prefix/rooms/$roomId';
  static String chatMessages(String roomId) => '$_prefix/rooms/$roomId/messages';
  static String chatMarkRead(String roomId) => '$_prefix/rooms/$roomId/read';
  static String chatUnreadCount(String roomId) => '$_prefix/rooms/$roomId/unread-count';

  // Geo
  static const String mapsAutocomplete = '$_prefix/maps/places/autocomplete';
  static const String mapsPlaceDetails = '$_prefix/maps/places/details';
  static const String mapsGeocode = '$_prefix/maps/geocode';
  static const String mapsReverseGeocode = '$_prefix/maps/reverse-geocode';
  static const String mapsEstimate = '$_prefix/maps/estimate';
  static const String mapsPolyline = '$_prefix/maps/polyline';
  static const String mapsRouting = '$_prefix/maps/routing';
  static const String distance = '$_prefix/distance';
  static const String driversNearby = '$_prefix/drivers/nearby';
}

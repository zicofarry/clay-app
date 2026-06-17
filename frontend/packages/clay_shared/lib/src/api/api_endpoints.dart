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

  // User
  static const String getProfile = '$_prefix/users/me';
  static const String updateProfile = '$_prefix/users/me';
  static const String updateAvatar = '$_prefix/users/me/avatar';
  static const String addresses = '$_prefix/addresses';
  static const String settings = '$_prefix/settings';

  // Ride
  static const String rideEstimate = '$_prefix/ride/orders/estimate';
  static const String rideCreate = '$_prefix/ride/orders';
  static const String rideActive = '$_prefix/ride/orders/active';
  static const String rideHistory = '$_prefix/ride/orders/history';

  // Food
  static const String foodEstimate = '$_prefix/food/orders/estimate';
  static const String foodCreate = '$_prefix/food/orders';
  static const String foodActive = '$_prefix/food/orders/active';
  static const String foodHistory = '$_prefix/food/orders/history';

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

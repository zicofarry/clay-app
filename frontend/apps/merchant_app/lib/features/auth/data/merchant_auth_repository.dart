import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class MerchantAuthRepository {
  final ClayApi _api;

  MerchantAuthRepository(this._api);

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    var finalIdentifier = identifier.trim();

    // Check if the identifier is a phone number (only contains digits, +, spaces, hyphens, parentheses)
    final isPhone = RegExp(r'^\+?[0-9\s\-\(\)]+$').hasMatch(finalIdentifier);
    if (isPhone) {
      // Normalize phone number to match the backend expectation
      var normalizedPhone = finalIdentifier.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (normalizedPhone.startsWith('0')) {
        normalizedPhone = '+62${normalizedPhone.substring(1)}';
      } else if (!normalizedPhone.startsWith('+')) {
        normalizedPhone = '+62$normalizedPhone';
      }
      finalIdentifier = normalizedPhone;
    }

    try {
      final response = await _api.dio.post(
        ApiEndpoints.login,
        data: {
          'identifier': finalIdentifier,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      
      // Ensure the logged in user is actually a merchant
      if (authResponse.user.role != 'merchant') {
        throw AppException('Akun ini bukan akun merchant');
      }

      // Configure ClayApi singleton token
      _api.setToken(authResponse.accessToken);

      // Now fetch the actual merchant profile details
      final profileResponse = await _api.dio.get('${ApiEndpoints.merchants}/me');
      final profileData = profileResponse.data as Map<String, dynamic>;
      final merchantData = profileData['data'] as Map<String, dynamic>? ?? {};

      // Map backend model to legacy UI keys
      return {
        'id': merchantData['id'],
        'user_id': merchantData['user_id'],
        'name': merchantData['name'],
        'owner': authResponse.user.fullName.isNotEmpty ? authResponse.user.fullName : 'Pemilik Toko',
        'phone': merchantData['phone_number'] ?? finalIdentifier,
        'category': merchantData['category'] ?? '',
        'address': merchantData['address'] ?? '',
        'rating': (merchantData['rating'] as num?)?.toDouble() ?? 4.5,
        'total_orders': merchantData['total_reviews'] ?? 0,
        'status': merchantData['status'] ?? 'active',
        ...merchantData,
      };
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal login: ${e.message}');
    }
  }

  void logout() {
    _api.clearToken();
  }
}

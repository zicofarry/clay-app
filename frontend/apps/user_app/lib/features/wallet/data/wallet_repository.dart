import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class WalletRepository {
  final ClayApi _api;

  WalletRepository(this._api);

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _api.dio.get(ApiEndpoints.wallet);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> topUp(int amount, {String channel = 'midtrans'}) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.walletTopUp,
        data: {
          'amount': amount,
          'channel': channel,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> transfer({
    required String recipientPhone,
    required int amount,
    String note = '',
  }) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.walletTransfer,
        data: {
          'recipient_phone': recipientPhone,
          'amount': amount,
          'note': note,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTransactions({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.dio.get(
        ApiEndpoints.walletTransactions,
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    final errorMsg = e.response?.data?['message']?.toString();
    final message = errorMsg ?? (e.message ?? 'Unknown error');
    return AppException(message, statusCode: e.response?.statusCode);
  }
}

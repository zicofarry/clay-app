import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class WalletRepository {
  final ClayApi _api;

  WalletRepository(this._api);

  /// GET /wallet — Saldo dan info wallet
  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _api.dio.get('/wallet');
      final data = response.data as Map<String, dynamic>;
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal mengambil data wallet: ${e.message}');
    }
  }

  /// POST /wallet/topup — Inisiasi top-up
  Future<Map<String, dynamic>> topUp({
    required int amount,
    required String channel,
  }) async {
    try {
      final response = await _api.dio.post(
        '/wallet/topup',
        data: {
          'amount': amount,
          'channel': channel,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal melakukan top-up: ${e.message}');
    }
  }

  /// POST /wallet/transfer — Transfer saldo ke user lain via nomor HP
  Future<Map<String, dynamic>> transfer({
    required String recipientPhone,
    required int amount,
    String? notes,
  }) async {
    try {
      final response = await _api.dio.post(
        '/wallet/transfer',
        data: {
          'recipient_phone': recipientPhone,
          'amount': amount,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal melakukan transfer: ${e.message}');
    }
  }

  /// GET /wallet/transactions — Riwayat transaksi wallet dengan paginasi & filter
  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (type != null && type.isNotEmpty) 'type': type,
      };
      final response = await _api.dio.get(
        '/wallet/transactions',
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal mengambil riwayat transaksi: ${e.message}');
    }
  }

  /// GET /wallet/transactions/{txId} — Detail transaksi wallet
  Future<Map<String, dynamic>> getTransactionDetail(String txId) async {
    try {
      final response = await _api.dio.get('/wallet/transactions/$txId');
      final data = response.data as Map<String, dynamic>;
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal mengambil detail transaksi: ${e.message}');
    }
  }
}

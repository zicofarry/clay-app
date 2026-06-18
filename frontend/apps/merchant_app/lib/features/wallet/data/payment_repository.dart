import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class PaymentRepository {
  final ClayApi _api;

  PaymentRepository(this._api);

  /// GET /payment-methods — Daftar metode pembayaran tersimpan
  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await _api.dio.get('/payment-methods');
      final data = response.data as Map<String, dynamic>;
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal mengambil metode pembayaran: ${e.message}');
    }
  }

  /// POST /payment-methods — Tambah metode pembayaran baru
  Future<Map<String, dynamic>> addPaymentMethod({
    required String type,
    String? cardToken,
    bool setAsDefault = false,
  }) async {
    try {
      final response = await _api.dio.post(
        '/payment-methods',
        data: {
          'type': type,
          'card_token': cardToken,
          'set_as_default': setAsDefault,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal menambah metode pembayaran: ${e.message}');
    }
  }

  /// DELETE /payment-methods/{methodId} — Hapus metode pembayaran
  Future<void> deletePaymentMethod(String methodId) async {
    try {
      await _api.dio.delete('/payment-methods/$methodId');
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal menghapus metode pembayaran: ${e.message}');
    }
  }

  /// POST /payment-methods/{methodId}/set-default — Set metode pembayaran sebagai default
  Future<void> setDefaultPaymentMethod(String methodId) async {
    try {
      await _api.dio.post('/payment-methods/$methodId/set-default');
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal set metode pembayaran default: ${e.message}');
    }
  }

  /// GET /transactions — Riwayat transaksi pembayaran
  Future<Map<String, dynamic>> getTransactionHistory({
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
        '/transactions',
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal mengambil riwayat pembayaran: ${e.message}');
    }
  }

  /// GET /transactions/{transactionId} — Detail transaksi pembayaran
  Future<Map<String, dynamic>> getTransactionDetail(String transactionId) async {
    try {
      final response = await _api.dio.get('/transactions/$transactionId');
      final data = response.data as Map<String, dynamic>;
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      throw AppException(msg ?? 'Gagal mengambil detail pembayaran: ${e.message}');
    }
  }
}

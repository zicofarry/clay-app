import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class RatingRepository {
  final ClayApi _api;

  RatingRepository(this._api);

  /// GET /ratings/me/received — Ambil daftar rating & ulasan yang diterima merchant
  Future<Map<String, dynamic>> getReceivedRatings({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.dio.get(
        '/ratings/me/received',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil data ulasan: ${e.message}');
    }
  }

  /// GET /ratings/{subjectType}/{subjectId} — Ambil ulasan berdasarkan subject ID asli (opsional fallback)
  Future<Map<String, dynamic>> getRatingsForSubject({
    required String subjectType,
    required String subjectId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.dio.get(
        '/ratings/$subjectType/$subjectId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil data ulasan subject: ${e.message}');
    }
  }
}

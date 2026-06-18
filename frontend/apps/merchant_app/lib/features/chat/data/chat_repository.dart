import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class ChatRepository {
  final ClayApi _api;

  ChatRepository(this._api);

  /// GET /rooms/by-order/{orderId} — Ambil chat room berdasarkan order ID
  Future<Map<String, dynamic>> getRoomByOrderId(String orderId) async {
    try {
      final response = await _api.dio.get(ApiEndpoints.chatRoomByOrder(orderId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /rooms/{roomId}/messages — Riwayat pesan dalam room
  Future<Map<String, dynamic>> getMessages(String roomId, {String? before, int limit = 30}) async {
    try {
      final response = await _api.dio.get(
        ApiEndpoints.chatMessages(roomId),
        queryParameters: {
          'before': ?before,
          'limit': limit,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /rooms/{roomId}/messages — Kirim pesan (REST fallback)
  Future<Map<String, dynamic>> sendMessage(
    String roomId,
    String content, {
    String type = 'text',
    String? clientId,
  }) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.chatMessages(roomId),
        data: {
          'content': content,
          'type': type,
          'client_id': ?clientId,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /rooms/{roomId}/read — Tandai pesan sudah dibaca
  Future<void> markAsRead(String roomId, String messageId) async {
    try {
      await _api.dio.post(
        ApiEndpoints.chatMarkRead(roomId),
        data: {'message_id': messageId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /users/{userId} — Ambil profil user (pelanggan/kurir) jika diizinkan
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _api.dio.get(ApiEndpoints.userById(userId));
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

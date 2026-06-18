import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class ChatRepository {
  final ClayApi _api;

  ChatRepository(this._api);

  Future<Map<String, dynamic>> getRooms({String? status, int page = 1, int limit = 20}) async {
    try {
      final response = await _api.dio.get(
        ApiEndpoints.chatRooms,
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getRoomByOrderId(String orderId) async {
    try {
      final response = await _api.dio.get(ApiEndpoints.chatRoomByOrder(orderId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMessages(String roomId, {String? before, int limit = 30}) async {
    try {
      final response = await _api.dio.get(
        ApiEndpoints.chatMessages(roomId),
        queryParameters: {
          if (before != null) 'before': before,
          'limit': limit,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> sendMessage(String roomId, String content, {String type = 'text'}) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.chatMessages(roomId),
        data: {
          'content': content,
          'type': type,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _api.dio.get(ApiEndpoints.userById(userId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createDirectChat(String recipientPhone) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.chatCreateDirect,
        data: {'recipient_phone': recipientPhone},
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/chat_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ClayApi.instance);
});

/// Provides the current user's ID from the auth state.
final currentUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.authResponse?.user.id ?? '';
});

final chatRoomsProvider = StateNotifierProvider<ChatRoomsNotifier, ChatRoomsState>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return ChatRoomsNotifier(repo, userId);
});

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, ChatMessagesState, String>((ref, roomId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  return ChatMessagesNotifier(ref.watch(chatRepositoryProvider), roomId, currentUserId, ref);
});

class ChatRoomsState {
  final bool isLoading;
  final bool hasLoaded;
  final String? error;
  final List<Map<String, dynamic>> rooms;
  final int totalPages;

  const ChatRoomsState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
    this.rooms = const [],
    this.totalPages = 0,
  });

  ChatRoomsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? error,
    bool clearError = false,
    List<Map<String, dynamic>>? rooms,
    int? totalPages,
  }) {
    return ChatRoomsState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : (error ?? this.error),
      rooms: rooms ?? this.rooms,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class ChatRoomsNotifier extends StateNotifier<ChatRoomsState> {
  final ChatRepository _repo;
  final String _currentUserId;

  /// Cache of userId -> full_name for display in chat list.
  final Map<String, String> _nameCache = {};

  ChatRoomsNotifier(this._repo, this._currentUserId) : super(const ChatRoomsState());

  Future<void> loadRooms({String? status, int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.getRooms(status: status, page: page);
      final inner = result['data'] as Map<String, dynamic>? ?? result;
      final data = inner['data'] as List? ?? [];
      final meta = inner['meta'] as Map<String, dynamic>? ?? {};
      final rooms = data.cast<Map<String, dynamic>>();

      // For direct chat rooms, resolve the other participant's display name.
      for (final room in rooms) {
        if (room['order_type'] == 'direct') {
          final otherUserId = _getOtherParticipantId(room);
          if (otherUserId != null && otherUserId.isNotEmpty) {
            final name = await _resolveUserName(otherUserId);
            if (name.isNotEmpty) {
              room['_display_name'] = name;
            }
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        rooms: rooms,
        totalPages: (meta['total_pages'] as num?)?.toInt() ?? 0,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, hasLoaded: true, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, hasLoaded: true, error: e.toString());
    }
  }

  /// Determines the other participant's user ID in a chat room.
  String? _getOtherParticipantId(Map<String, dynamic> room) {
    final userId = room['user_id']?.toString() ?? '';
    final driverId = room['driver_id']?.toString();
    if (userId == _currentUserId) return driverId;
    return userId;
  }

  /// Fetches and caches a user's full_name by their user ID.
  Future<String> _resolveUserName(String userId) async {
    if (_nameCache.containsKey(userId)) return _nameCache[userId]!;
    try {
      final resp = await _repo.getUserProfile(userId);
      final data = resp['data'] as Map<String, dynamic>? ?? resp;
      final name = data['full_name']?.toString() ?? '';
      if (name.isNotEmpty) _nameCache[userId] = name;
      return name;
    } catch (_) {
      return '';
    }
  }

  void refresh() => loadRooms();

  Future<Map<String, String>?> createDirectChat(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.createDirectChat(phone);
      final inner = result['data'] as Map<String, dynamic>? ?? result;
      final room = inner['data'] as Map<String, dynamic>? ?? inner;
      final roomId = room['id']?.toString() ?? '';
      final recipientName = inner['recipient_name']?.toString() ?? '';
      state = state.copyWith(isLoading: false);
      await loadRooms();
      return {'room_id': roomId, 'recipient_name': recipientName};
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

class ChatMessagesState {
  final bool isLoading;
  final bool isSending;
  final String? error;
  final List<Map<String, dynamic>> messages;
  final bool hasMore;

  const ChatMessagesState({
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.messages = const [],
    this.hasMore = false,
  });

  ChatMessagesState copyWith({
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
    List<Map<String, dynamic>>? messages,
    bool? hasMore,
  }) {
    return ChatMessagesState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ChatRepository _repo;
  final String _roomId;
  final String _currentUserId;
  final Ref _ref;

  ChatMessagesNotifier(this._repo, this._roomId, this._currentUserId, this._ref) : super(const ChatMessagesState()) {
    loadMessages();
  }

  Future<void> loadMessages({String? before}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.getMessages(_roomId, before: before);
      final inner = result['data'] as Map<String, dynamic>? ?? result;
      final data = inner['data'] as List? ?? [];
      final meta = inner['meta'] as Map<String, dynamic>? ?? {};
      final newMessages = data.cast<Map<String, dynamic>>();

      if (before != null) {
        state = state.copyWith(
          isLoading: false,
          messages: [...state.messages, ...newMessages],
          hasMore: meta['has_more'] == true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          messages: newMessages.reversed.toList(),
          hasMore: meta['has_more'] == true,
        );
      }

      // Automatically mark messages as read if there are messages from the other user.
      if (state.messages.isNotEmpty) {
        final otherUserMessages = state.messages.where((m) {
          final senderId = m['sender_id']?.toString() ?? '';
          return senderId.isNotEmpty && senderId != _currentUserId;
        }).toList();

        if (otherUserMessages.isNotEmpty) {
          final latestMessage = otherUserMessages.last;
          final latestMsgId = latestMessage['id']?.toString() ?? '';
          final isRead = latestMessage['is_read'] == true;
          if (latestMsgId.isNotEmpty && !isRead) {
            await markAsRead(latestMsgId);
          }
        }
      }
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> sendMessage(String content) async {
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final result = await _repo.sendMessage(_roomId, content);
      final inner = result['data'] as Map<String, dynamic>? ?? result;
      final msg = inner['data'] as Map<String, dynamic>? ?? inner;
      state = state.copyWith(
        isSending: false,
        messages: [...state.messages, msg],
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSending: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await _repo.markAsRead(_roomId, messageId);

      // Update local state to mark messages <= messageId as read
      final idx = state.messages.indexWhere((m) => m['id']?.toString() == messageId);
      if (idx != -1) {
        final updatedMessages = List<Map<String, dynamic>>.from(state.messages);
        for (int i = 0; i <= idx; i++) {
          updatedMessages[i] = {...updatedMessages[i], 'is_read': true};
        }
        state = state.copyWith(messages: updatedMessages);
      }

      // Refresh chatRoomsProvider so the unread count updates in the chat list screen
      _ref.read(chatRoomsProvider.notifier).refresh();
    } catch (_) {}
  }
}

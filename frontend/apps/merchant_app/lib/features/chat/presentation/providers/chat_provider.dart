import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/chat_repository.dart';
import '../../../auth/presentation/providers/merchant_auth_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ClayApi.instance);
});

final currentMerchantUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(merchantAuthProvider);
  return authState.merchant?['user_id']?.toString() ?? '';
});

class ChatMessagesState {
  final bool isLoading;
  final bool isSending;
  final String? error;
  final List<Map<String, dynamic>> messages;
  final bool isSimulated;
  final String roomId;
  final String customerName;
  final String driverName;

  const ChatMessagesState({
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.messages = const [],
    this.isSimulated = false,
    this.roomId = '',
    this.customerName = 'Pelanggan',
    this.driverName = 'Kurir',
  });

  ChatMessagesState copyWith({
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
    List<Map<String, dynamic>>? messages,
    bool? isSimulated,
    String? roomId,
    String? customerName,
    String? driverName,
  }) {
    return ChatMessagesState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      messages: messages ?? this.messages,
      isSimulated: isSimulated ?? this.isSimulated,
      roomId: roomId ?? this.roomId,
      customerName: customerName ?? this.customerName,
      driverName: driverName ?? this.driverName,
    );
  }
}

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, ChatMessagesState, String>((ref, orderId) {
  final repo = ref.watch(chatRepositoryProvider);
  final currentUserId = ref.watch(currentMerchantUserIdProvider);
  return ChatMessagesNotifier(repo, orderId, currentUserId);
});

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ChatRepository _repo;
  final String _orderId;
  final String _currentUserId;
  Timer? _pollTimer;
  int _simulatedStep = 0;

  ChatMessagesNotifier(this._repo, this._orderId, this._currentUserId) : super(const ChatMessagesState()) {
    loadRoomAndMessages();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> loadRoomAndMessages() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // 1. Ambil room by order ID dari backend
      final roomData = await _repo.getRoomByOrderId(_orderId);
      final room = roomData['data'] as Map<String, dynamic>? ?? roomData;
      final roomId = room['id']?.toString() ?? '';

      if (roomId.isEmpty) {
        throw Exception('Room ID kosong');
      }

      // Resolusi nama partisipan (Customer & Driver)
      String customerName = 'Pelanggan';
      String driverName = 'Kurir';

      final customerId = room['user_id']?.toString();
      if (customerId != null && customerId.isNotEmpty) {
        try {
          final custProfile = await _repo.getUserProfile(customerId);
          final cData = custProfile['data'] as Map<String, dynamic>? ?? custProfile;
          if (cData['full_name'] != null) {
            customerName = cData['full_name'].toString();
          }
        } catch (_) {}
      }

      final driverId = room['driver_id']?.toString();
      if (driverId != null && driverId.isNotEmpty) {
        try {
          final drvProfile = await _repo.getUserProfile(driverId);
          final dData = drvProfile['data'] as Map<String, dynamic>? ?? drvProfile;
          if (dData['full_name'] != null) {
            driverName = dData['full_name'].toString();
          }
        } catch (_) {}
      }

      state = state.copyWith(
        roomId: roomId,
        customerName: customerName,
        driverName: driverName,
        isSimulated: false,
      );

      // 2. Load messages dari room
      await _fetchMessages();

      // 3. Jalankan Polling setiap 3 detik
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchMessages());

    } catch (e) {
      // Jika error 403/404 atau server mati, aktifkan Simulated Fallback Mode
      _setupSimulationMode();
    }
  }

  Future<void> _fetchMessages() async {
    if (state.isSimulated || state.roomId.isEmpty) return;
    try {
      final messagesData = await _repo.getMessages(state.roomId);
      final list = messagesData['data'] as List? ?? [];
      final messagesList = list.cast<Map<String, dynamic>>();

      // Urutkan terbalik agar pesan terbaru ada di bawah (List messages dari API adalah terbalik, jadi kita reverse)
      final sortedMessages = messagesList.reversed.toList();
      state = state.copyWith(
        isLoading: false,
        messages: sortedMessages,
      );

      // Tandai pesan terakhir dari user lain sebagai dibaca
      if (sortedMessages.isNotEmpty) {
        final lastMsg = sortedMessages.last;
        final senderId = lastMsg['sender_id']?.toString() ?? '';
        final isRead = lastMsg['is_read'] == true;
        if (senderId != _currentUserId && !isRead) {
          final msgId = lastMsg['id']?.toString() ?? '';
          if (msgId.isNotEmpty) {
            await _repo.markAsRead(state.roomId, msgId);
          }
        }
      }
    } catch (_) {
      // Hiraukan error background polling agar tidak mengganggu UI
    }
  }

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty) return false;

    if (state.isSimulated) {
      // Kirim pesan dalam Mode Simulasi
      final userMsg = {
        'id': 'sim_msg_${DateTime.now().millisecondsSinceEpoch}',
        'room_id': 'sim_room_id',
        'sender_id': _currentUserId,
        'sender_role': 'merchant',
        'content': content,
        'type': 'text',
        'is_read': true,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

      state = state.copyWith(
        messages: [...state.messages, userMsg],
      );

      // Trigger bot response setelah 2 detik
      _triggerSimulatedBotResponse();
      return true;
    }

    // Mode Normal - Panggil API
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final clientId = 'msg_client_${DateTime.now().millisecondsSinceEpoch}';
      final response = await _repo.sendMessage(
        state.roomId,
        content,
        clientId: clientId,
      );
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final msg = data['data'] as Map<String, dynamic>? ?? data;

      // Update local state dengan menyertakan pesan baru di akhir
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

  void _setupSimulationMode() {
    final now = DateTime.now();
    // Inisiasi obrolan demo
    final demoMessages = [
      {
        'id': 'demo_1',
        'room_id': 'sim_room_id',
        'sender_id': 'user_cust_123',
        'sender_role': 'user', // customer
        'content': 'Halo, saya sudah memesan makanan ya. Mohon diproses dan dibuatkan sesuai catatan.',
        'type': 'text',
        'is_read': true,
        'created_at': now.subtract(const Duration(minutes: 10)).toUtc().toIso8601String(),
      },
      {
        'id': 'demo_2',
        'room_id': 'sim_room_id',
        'sender_id': _currentUserId.isNotEmpty ? _currentUserId : 'merchant_user_123',
        'sender_role': 'merchant',
        'content': 'Baik Kak, pesanan sudah kami terima dan sedang disiapkan dengan baik ya.',
        'type': 'text',
        'is_read': true,
        'created_at': now.subtract(const Duration(minutes: 8)).toUtc().toIso8601String(),
      },
      {
        'id': 'demo_3',
        'room_id': 'sim_room_id',
        'sender_id': 'user_driver_123',
        'sender_role': 'driver',
        'content': 'Halo, saya kurir Clay yang bertugas mengantar pesanan Anda. Saya sedang menuju ke resto Anda sekarang.',
        'type': 'text',
        'is_read': true,
        'created_at': now.subtract(const Duration(minutes: 5)).toUtc().toIso8601String(),
      },
      {
        'id': 'demo_4',
        'room_id': 'sim_room_id',
        'sender_id': 'user_cust_123',
        'sender_role': 'user',
        'content': 'Siap Pak kurir, hati-hati di jalan ya.',
        'type': 'text',
        'is_read': true,
        'created_at': now.subtract(const Duration(minutes: 4)).toUtc().toIso8601String(),
      },
    ];

    state = state.copyWith(
      isLoading: false,
      isSimulated: true,
      roomId: 'sim_room_id',
      customerName: 'Budi (Pelanggan)',
      driverName: 'Pak Joko (Kurir)',
      messages: demoMessages,
    );
  }

  void _triggerSimulatedBotResponse() {
    _simulatedStep++;
    final step = _simulatedStep;
    
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || !state.isSimulated) return;

      Map<String, dynamic> responseMsg;
      final nowStr = DateTime.now().toUtc().toIso8601String();

      if (step == 1) {
        responseMsg = {
          'id': 'sim_bot_1',
          'room_id': 'sim_room_id',
          'sender_id': 'user_driver_123',
          'sender_role': 'driver',
          'content': 'Oke Kak, saya sudah sampai di dekat resto Anda. Mohon disiapkan makanannya ya.',
          'type': 'text',
          'is_read': false,
          'created_at': nowStr,
        };
      } else if (step == 2) {
        responseMsg = {
          'id': 'sim_bot_2',
          'room_id': 'sim_room_id',
          'sender_id': 'user_cust_123',
          'sender_role': 'user',
          'content': 'Terima kasih atas responnya yang cepat! Tidak sabar menunggu makanannya sampai.',
          'type': 'text',
          'is_read': false,
          'created_at': nowStr,
        };
      } else {
        responseMsg = {
          'id': 'sim_bot_$step',
          'room_id': 'sim_room_id',
          'sender_id': 'user_driver_123',
          'sender_role': 'driver',
          'content': 'Siap Kak, saya segera antarkan ke alamat tujuan setelah makanan siap.',
          'type': 'text',
          'is_read': false,
          'created_at': nowStr,
        };
      }

      state = state.copyWith(
        messages: [...state.messages, responseMsg],
      );
    });
  }
}

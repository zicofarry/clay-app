import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/merchant_auth_repository.dart';

class SessionState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> sessions;

  const SessionState({
    this.isLoading = false,
    this.error,
    this.sessions = const [],
  });

  SessionState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? sessions,
  }) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sessions: sessions ?? this.sessions,
    );
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(MerchantAuthRepository(ClayApi.instance));
});

class SessionNotifier extends StateNotifier<SessionState> {
  final MerchantAuthRepository _repo;

  SessionNotifier(this._repo) : super(const SessionState());

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getActiveSessions();
      state = state.copyWith(isLoading: false, sessions: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> revokeSession(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.revokeSession(sessionId);
      // Remove the session locally
      final updatedList = state.sessions.where((s) => s['id'] != sessionId).toList();
      state = state.copyWith(isLoading: false, sessions: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> revokeAllOtherSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.revokeAllSessions();
      // Keep only the current session in the list
      final currentSession = state.sessions.where((s) => s['is_current'] == true).toList();
      state = state.copyWith(isLoading: false, sessions: currentSession);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

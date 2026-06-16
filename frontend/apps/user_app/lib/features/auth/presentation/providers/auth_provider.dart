import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/mock_auth_repository.dart';

final mockAuthRepositoryProvider = Provider<MockAuthRepository>((ref) {
  return MockAuthRepository();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(mockAuthRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthState {
  final bool isLoading;
  final String? error;
  final AuthResponse? authResponse;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.authResponse,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    AuthResponse? authResponse,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      authResponse: authResponse ?? this.authResponse,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final MockAuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.login(phone, password);
      state = state.copyWith(isLoading: false, authResponse: response);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.register(
        phoneNumber: phone,
        fullName: name,
        password: password,
      );
      state = state.copyWith(isLoading: false, authResponse: response);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

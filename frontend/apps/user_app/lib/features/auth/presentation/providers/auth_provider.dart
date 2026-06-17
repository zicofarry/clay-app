import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/auth_repository.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ClayApi.instance);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
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
    bool clearError = false,
    AuthResponse? authResponse,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      authResponse: authResponse ?? this.authResponse,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState());

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.login(phone, password);
      state = state.copyWith(isLoading: false, authResponse: response);
      _ref.invalidate(profileProvider);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.register(
        phoneNumber: phone,
        fullName: name,
        password: password,
      );
      state = state.copyWith(isLoading: false, authResponse: response);
      _ref.invalidate(profileProvider);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<bool> forgotPassword(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.sendForgotPasswordOtp(phone);
      state = state.copyWith(isLoading: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  Future<void> verifyOtpAndResetPassword({
    required String phone,
    required String otpCode,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final resetToken = await _repository.verifyOtpForReset(phone, otpCode);
      await _repository.resetPassword(
        phoneNumber: phone,
        resetToken: resetToken,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  void logout() {
    ClayApi.instance.clearToken();
    _ref.invalidate(profileProvider);
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

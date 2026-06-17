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

  // Registration flow
  final bool registered;
  final String? contact;
  final String? password;
  final String? fullName;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.authResponse,
    this.registered = false,
    this.contact,
    this.password,
    this.fullName,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    AuthResponse? authResponse,
    bool? registered,
    String? contact,
    String? password,
    String? fullName,
    bool clearRegistration = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      authResponse: authResponse ?? this.authResponse,
      registered: clearRegistration ? false : (registered ?? this.registered),
      contact: clearRegistration ? null : (contact ?? this.contact),
      password: clearRegistration ? null : (password ?? this.password),
      fullName: clearRegistration ? null : (fullName ?? this.fullName),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState());

  Future<void> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.login(identifier, password);
      state = state.copyWith(isLoading: false, authResponse: response);
      _ref.invalidate(profileProvider);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> register({
    required String fullName,
    required String username,
    String? email,
    String? phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.register(
        fullName: fullName,
        username: username,
        email: email,
        phone: phone,
        password: password,
      );

      if (email != null && email.isNotEmpty) {
        await _repository.requestOtp(email, 'registration');
        state = state.copyWith(
          isLoading: false,
          registered: true,
          contact: email,
          password: password,
          fullName: fullName,
        );
      } else {
        final contact = phone ?? '';
        final response = await _repository.login(contact, password);
        await _repository.createProfile(fullName);
        state = state.copyWith(
          isLoading: false,
          authResponse: response,
        );
        _ref.invalidate(profileProvider);
      }
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> verifyRegistrationOtp(String otpCode) async {
    final contact = state.contact;
    final password = state.password;
    final fullName = state.fullName;
    if (contact == null || password == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.verifyOtp(contact, otpCode, 'registration');

      final response = await _repository.login(contact, password);

      await _repository.createProfile(fullName ?? '');

      state = state.copyWith(isLoading: false, authResponse: response);
      _ref.invalidate(profileProvider);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  void clearRegistration() {
    state = state.copyWith(clearRegistration: true);
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

  Future<String?> verifyResetOtp(String phone, String otpCode) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final resetToken = await _repository.verifyOtpForReset(phone, otpCode);
      state = state.copyWith(isLoading: false);
      return resetToken;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String resetToken,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
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

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
  final String? username;
  final String? password;
  final String? fullName;
  final bool isOtpVerified;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.authResponse,
    this.registered = false,
    this.contact,
    this.username,
    this.password,
    this.fullName,
    this.isOtpVerified = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    AuthResponse? authResponse,
    bool? registered,
    String? contact,
    String? username,
    String? password,
    String? fullName,
    bool? isOtpVerified,
    bool clearRegistration = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      authResponse: authResponse ?? this.authResponse,
      registered: clearRegistration ? false : (registered ?? this.registered),
      contact: clearRegistration ? null : (contact ?? this.contact),
      username: clearRegistration ? null : (username ?? this.username),
      password: clearRegistration ? null : (password ?? this.password),
      fullName: clearRegistration ? null : (fullName ?? this.fullName),
      isOtpVerified: clearRegistration ? false : (isOtpVerified ?? this.isOtpVerified),
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
          username: username,
          password: password,
          fullName: fullName,
          isOtpVerified: false,
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
    final username = state.username;
    final password = state.password;
    final fullName = state.fullName;

    if (contact == null || password == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Data pendaftaran hilang. Silakan daftarkan ulang akun Anda.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.verifyOtp(contact, otpCode, 'registration');

      final loginIdentifier = username ?? contact;
      final response = await _repository.login(loginIdentifier, password);

      try {
        await _repository.createProfile(fullName ?? '');
      } catch (_) {
        // best-effort: profile can be filled later from the profile screen
      }

      state = state.copyWith(
        isLoading: false,
        isOtpVerified: true,
        authResponse: response,
      );
      _ref.invalidate(profileProvider);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> completeRegistrationAndLogin() async {
    final contact = state.contact;
    final username = state.username;
    final password = state.password;
    final fullName = state.fullName;

    if (contact == null || password == null) {
      state = state.copyWith(isLoading: false, error: 'Data kredensial tidak lengkap.');
      return;
    }

    if (state.authResponse != null) {
      state = state.copyWith(clearRegistration: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final loginIdentifier = username ?? contact;
      final response = await _repository.login(loginIdentifier, password);

      try {
        await _repository.createProfile(fullName ?? '');
      } catch (_) {}

      state = state.copyWith(
        isLoading: false,
        authResponse: response,
        clearRegistration: true,
      );
      _ref.invalidate(profileProvider);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearRegistration() {
    state = state.copyWith(clearRegistration: true);
  }

  void acknowledgeRegistrationNavigation() {
    state = state.copyWith(registered: false);
  }

  Future<bool> resendOtp(String contact, String purpose) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (purpose == 'reset') {
        await _repository.sendForgotPasswordOtp(contact);
      } else {
        await _repository.requestOtp(contact, purpose);
      }
      state = state.copyWith(isLoading: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
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

  Future<bool> logoutAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.revokeAllSessions();
      ClayApi.instance.clearToken();
      _ref.invalidate(profileProvider);
      state = const AuthState();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listSessions() async {
    try {
      return await _repository.listSessions();
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
      return [];
    }
  }

  Future<bool> revokeSession(String sessionId) async {
    try {
      await _repository.revokeSession(sessionId);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

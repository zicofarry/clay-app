import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_admin_auth.dart';

final adminAuthProvider = StateNotifierProvider<AdminAuthNotifier, AdminAuthState>((ref) {
  return AdminAuthNotifier(MockAdminAuthRepository());
});

class AdminAuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? admin;
  const AdminAuthState({this.isLoading = false, this.error, this.admin});
  AdminAuthState copyWith({bool? isLoading, String? error, Map<String, dynamic>? admin}) {
    return AdminAuthState(isLoading: isLoading ?? this.isLoading, error: error, admin: admin ?? this.admin);
  }
}

class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  final MockAdminAuthRepository _repo;
  AdminAuthNotifier(this._repo) : super(const AdminAuthState());

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final admin = await _repo.login(phone, password);
      state = state.copyWith(isLoading: false, admin: admin);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

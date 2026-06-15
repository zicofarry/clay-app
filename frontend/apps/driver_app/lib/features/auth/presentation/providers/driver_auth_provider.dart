import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_driver_auth_repository.dart';

final driverAuthProvider = StateNotifierProvider<DriverAuthNotifier, DriverAuthState>((ref) {
  return DriverAuthNotifier(MockDriverAuthRepository());
});

class DriverAuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? driver;

  const DriverAuthState({this.isLoading = false, this.error, this.driver});

  DriverAuthState copyWith({bool? isLoading, String? error, Map<String, dynamic>? driver}) {
    return DriverAuthState(isLoading: isLoading ?? this.isLoading, error: error, driver: driver ?? this.driver);
  }
}

class DriverAuthNotifier extends StateNotifier<DriverAuthState> {
  final MockDriverAuthRepository _repo;
  DriverAuthNotifier(this._repo) : super(const DriverAuthState());

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final driver = await _repo.login(phone, password);
      state = state.copyWith(isLoading: false, driver: driver);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

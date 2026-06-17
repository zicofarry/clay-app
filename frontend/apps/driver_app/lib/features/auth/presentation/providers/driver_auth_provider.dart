import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/driver_auth_repository.dart';

final driverAuthRepositoryProvider = Provider<DriverAuthRepository>((ref) {
  return DriverAuthRepository(ClayApi.instance);
});

final driverAuthProvider = StateNotifierProvider<DriverAuthNotifier, DriverAuthState>((ref) {
  return DriverAuthNotifier(ref.watch(driverAuthRepositoryProvider));
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
  final DriverAuthRepository _repo;
  DriverAuthNotifier(this._repo) : super(const DriverAuthState());

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final driver = await _repo.login(phone, password);
      state = state.copyWith(isLoading: false, driver: driver);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const DriverAuthState();
  }

  DateTime? _lastRefresh;
  Future<void> refreshProfile() async {
    final current = state.driver;
    if (current == null) return;
    final now = DateTime.now();
    if (_lastRefresh != null && now.difference(_lastRefresh!).inSeconds < 2) return;
    _lastRefresh = now;
    try {
      final fresh = await _repo.fetchProfile(
        fallbackName: current['name']?.toString(),
        fallbackEmail: current['email']?.toString(),
        fallbackPhone: current['phone']?.toString(),
        fallbackAvatar: current['avatar_url']?.toString(),
        fallbackId: current['id']?.toString(),
      );
      state = state.copyWith(driver: fresh);
    } catch (_) {}
  }

  void updateDriverProfile(Map<String, dynamic> patch) {
    final current = state.driver;
    if (current == null) return;
    state = state.copyWith(driver: {...current, ...patch});
  }
}

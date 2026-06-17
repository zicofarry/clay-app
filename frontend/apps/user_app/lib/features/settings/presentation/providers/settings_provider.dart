import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';
import '../../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ClayApi.instance);
});

class SettingsState {
  final bool isLoading;
  final String? error;
  final bool notifEnabled;
  final bool marketingEnabled;
  final String language;

  const SettingsState({
    this.isLoading = false,
    this.error,
    this.notifEnabled = true,
    this.marketingEnabled = true,
    this.language = 'id',
  });

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? notifEnabled,
    bool? marketingEnabled,
    String? language,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      notifEnabled: notifEnabled ?? this.notifEnabled,
      marketingEnabled: marketingEnabled ?? this.marketingEnabled,
      language: language ?? this.language,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repo;
  SettingsNotifier(this._repo) : super(const SettingsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final j = await _repo.get();
      state = state.copyWith(
        isLoading: false,
        notifEnabled: j['notif_enabled'] == true,
        marketingEnabled: j['marketing_enabled'] == true,
        language: j['language']?.toString() ?? 'id',
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _repo.describe(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> setNotifEnabled(bool v) async {
    state = state.copyWith(notifEnabled: v);
    try {
      final j = await _repo.update(notifEnabled: v);
      state = state.copyWith(notifEnabled: j['notif_enabled'] == true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(notifEnabled: !v, error: _repo.describe(e));
      return false;
    }
  }

  Future<bool> setMarketingEnabled(bool v) async {
    state = state.copyWith(marketingEnabled: v);
    try {
      final j = await _repo.update(marketingEnabled: v);
      state = state.copyWith(marketingEnabled: j['marketing_enabled'] == true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(marketingEnabled: !v, error: _repo.describe(e));
      return false;
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

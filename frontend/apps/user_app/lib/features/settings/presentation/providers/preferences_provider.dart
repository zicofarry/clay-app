import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clay_shared/clay_shared.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

class AppPreferences {
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language';

  final SharedPreferences _prefs;
  AppPreferences(this._prefs);

  ThemeMode getThemeMode() {
    final raw = _prefs.getString(_themeKey) ?? 'light';
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode m) {
    final v = switch (m) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    return _prefs.setString(_themeKey, v);
  }

  String getLanguage() => _prefs.getString(_languageKey) ?? 'id';
  Future<void> setLanguage(String code) => _prefs.setString(_languageKey, code);
}

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return AppPreferences(ref.watch(sharedPreferencesProvider));
});

class ThemeState {
  final ThemeMode mode;
  const ThemeState(this.mode);
  bool get isDark => mode == ThemeMode.dark;
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final AppPreferences _prefs;
  ThemeNotifier(this._prefs) : super(ThemeState(_prefs.getThemeMode()));

  Future<void> setMode(ThemeMode m) async {
    await _prefs.setThemeMode(m);
    state = ThemeState(m);
  }

  bool get isDark => state.mode == ThemeMode.dark;

  Future<void> toggle() => setMode(isDark ? ThemeMode.light : ThemeMode.dark);
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(ref.watch(appPreferencesProvider));
});

class LanguageState {
  final String code;
  final String label;
  const LanguageState(this.code, this.label);
}

const _supportedLanguages = <String, String>{
  'id': 'Bahasa Indonesia',
  'en': 'English',
};

class LanguageNotifier extends StateNotifier<LanguageState> {
  final AppPreferences _prefs;
  LanguageNotifier(this._prefs)
      : super(LanguageState(
          _prefs.getLanguage(),
          _supportedLanguages[_prefs.getLanguage()] ?? 'Bahasa Indonesia',
        ));

  Future<bool> setLanguage(String code) async {
    await _prefs.setLanguage(code);
    state = LanguageState(code, _supportedLanguages[code] ?? code);
    try {
      final api = ClayApi.instance;
      await api.dio.put(ApiEndpoints.settings, data: {'language': code});
      return true;
    } catch (_) {
      return false;
    }
  }

  static List<MapEntry<String, String>> get supported => _supportedLanguages.entries.toList();
}

final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
  return LanguageNotifier(ref.watch(appPreferencesProvider));
});

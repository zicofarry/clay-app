import 'package:flutter/material.dart';
import 'package:clay_ui/clay_ui.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ClayColors.primary,
        primary: ClayColors.primary,
        secondary: ClayColors.green,
        surface: ClayColors.surface,
        error: ClayColors.error,
      ),
      scaffoldBackgroundColor: ClayColors.background,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ClayColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: ClayColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(color: ClayColors.divider, thickness: 1, space: 0),
    );
  }
}

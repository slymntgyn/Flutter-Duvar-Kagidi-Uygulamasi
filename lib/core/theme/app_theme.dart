import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'text_themes.dart';

/// Uygulama tema modlari.
enum AppThemeMode { light, dark, amoled }

/// Material 3 uyumlu tema fabrikasi.
class AppTheme {
  AppTheme._();

  /// Acik tema.
  static ThemeData light() {
    final colorScheme = AppColorSchemes.light();
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTextThemes.lightTextTheme(),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Koyu tema.
  static ThemeData dark() {
    final colorScheme = AppColorSchemes.dark();
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTextThemes.darkTextTheme(),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// AMOLED siyah tema.
  static ThemeData amoled() {
    final colorScheme = AppColorSchemes.amoled();
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTextThemes.darkTextTheme(),
      scaffoldBackgroundColor: Colors.black,
      cardTheme: CardThemeData(
        color: const Color(0xFF121212),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.white54,
      ),
    );
  }

  /// AppThemeMode'dan ThemeData'ya donusum.
  static ThemeData fromMode(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => light(),
        AppThemeMode.dark => dark(),
        AppThemeMode.amoled => amoled(),
      };
}


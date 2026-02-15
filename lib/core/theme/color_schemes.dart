import 'package:flutter/material.dart';

/// Material 3 renk semalari.
class AppColorSchemes {
  AppColorSchemes._();

  /// Ana seed rengi (mevcut uygulamadaki teal).
  static const Color seedColor = Color(0xFF009688);

  /// Acik tema renk semasi.
  static ColorScheme light() => ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      );

  /// Koyu tema renk semasi.
  static ColorScheme dark() => ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      );

  /// AMOLED siyah tema renk semasi.
  static ColorScheme amoled() => ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ).copyWith(
        surface: Colors.black,
        onSurface: Colors.white,
      );
}

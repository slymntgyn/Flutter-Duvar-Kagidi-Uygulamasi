import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uygulama tipografi sistemi.
class AppTextThemes {
  AppTextThemes._();

  static TextTheme lightTextTheme() =>
      GoogleFonts.interTextTheme(ThemeData.light().textTheme);

  static TextTheme darkTextTheme() =>
      GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
}

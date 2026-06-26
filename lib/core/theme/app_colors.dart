import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    scaffoldBackgroundColor: LightColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: LightColors.background,
      titleTextStyle: TextStyle(
        color: LightColors.primary,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: LightColors.background,
    ),
    colorScheme: const ColorScheme.light(
      primary: LightColors.primary,
      surface: LightColors.surface,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: LightColors.text)),
  );

  static ThemeData dark = ThemeData(
    scaffoldBackgroundColor: DarkColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: DarkColors.background,
      titleTextStyle: TextStyle(
        color: DarkColors.primary,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DarkColors.background,
    ),
    colorScheme: const ColorScheme.dark(
      primary: DarkColors.primary,
      surface: DarkColors.surface,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: DarkColors.text)),
  );
}

class LightColors {
  static const background = Color(0xFFF7F8FA);
  static const surface = Colors.white;

  static const primary = Color(0xFF0D9488);
  static const secondary = Color(0xFF9E3D00);
  static const accent = Color(0xFF334155);

  static const text = Color(0xFF111827);
  static const mutedText = Color(0xFF6B7280);
}

class DarkColors {
  static const background = Color(0xFF1A1D22);
  static const surface = Color(0xFF15181C);
  static const primary = Color(0xFF0D9488);
  static const secondary = Color(0xFF9E3D00);
  static const accent = Color(0xFF4C4ACA);

  static const text = Color(0xFFF9FAFB);
  static const mutedText = Color(0xFF9CA3AF);
}

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    scaffoldBackgroundColor: LightColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: LightColors.surface,
      foregroundColor: LightColors.text,
      titleTextStyle: TextStyle(
        color: LightColors.primary,
        fontSize: 30,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: const ColorScheme.light(primary: LightColors.primary),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: LightColors.text)),
  );

  static ThemeData dark = ThemeData(
    scaffoldBackgroundColor: DarkColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: DarkColors.surface,
      foregroundColor: DarkColors.text,
    ),
    colorScheme: const ColorScheme.dark(primary: DarkColors.primary),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: DarkColors.text)),
  );
}

class LightColors {
  static const background = Color(0xFFF7F8FA);
  static const surface = Colors.white;

  static const primary = Color(0xFF0058BC);
  static const secondary = Color(0xFF9E3D00);
  static const accent = Color(0xFF4C4ACA);

  static const text = Color(0xFF111827);
  static const mutedText = Color(0xFF6B7280);
}

class DarkColors {
  static const background = Color(0xFF0B0F1A);
  static const surface = Color(0xFF111827);

  static const primary = Color(0xFF0058BC);
  static const secondary = Color(0xFF9E3D00);
  static const accent = Color(0xFF4C4ACA);

  static const text = Color(0xFFF9FAFB);
  static const mutedText = Color(0xFF9CA3AF);
}

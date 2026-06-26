import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    scaffoldBackgroundColor: LightColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: LightColors.surface,
      titleTextStyle: TextStyle(
        color: LightColors.primary,
        fontSize: 30,
        fontVariations: <FontVariation>[
          FontVariation('wght', 100.0),
          // Custom weight between 100.0 and 900.0
        ],
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: LightColors.background,
      selectedLabelStyle: TextStyle(
        fontFamily: 'JetBrainsMonoVariable',
        fontSize: 12,
        fontVariations: [FontVariation('wght', 650)],
      ),

      unselectedLabelStyle: TextStyle(
        fontFamily: 'JetBrainsMonoVariable',
        fontSize: 12,
        fontVariations: [FontVariation('wght', 650)],
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: LightColors.primary,
      surface: LightColors.surface,
      secondary: LightColors.secondary,
      surfaceContainer: LightColors.elevatedSurface,
      outline: LightColors.outline,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: LightColors.text,
        fontFamily: 'InterVariable',
        fontSize: 32,
        fontVariations: [FontVariation('wght', 700)],
      ),

      headlineMedium: TextStyle(
        color: LightColors.text,
        fontFamily: 'InterVariable',
        fontSize: 24,
        fontVariations: [FontVariation('wght', 600)],
      ),

      titleLarge: TextStyle(
        color: LightColors.text,
        fontFamily: 'InterVariable',
        fontSize: 20,
        fontVariations: [FontVariation('wght', 600)],
      ),

      titleMedium: TextStyle(
        color: LightColors.text,
        fontFamily: 'InterVariable',
        fontSize: 18,
        fontVariations: [FontVariation('wght', 500)],
      ),

      bodyLarge: TextStyle(
        color: LightColors.text,
        fontFamily: 'InterVariable',
        fontSize: 16,
        fontVariations: [FontVariation('wght', 400)],
      ),

      bodyMedium: TextStyle(
        color: LightColors.text,
        fontFamily: 'InterVariable',
        fontSize: 14,
        fontVariations: [FontVariation('wght', 400)],
      ),

      bodySmall: TextStyle(
        color: LightColors.mutedText,
        fontFamily: 'InterVariable',
        fontSize: 12,
        fontVariations: [FontVariation('wght', 400)],
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    scaffoldBackgroundColor: DarkColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: DarkColors.surface,
      titleTextStyle: TextStyle(
        color: DarkColors.primary,
        fontSize: 30,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMonoVariable',
        fontVariations: <FontVariation>[
          FontVariation('wght', 100.0),
          // Custom weight between 100.0 and 900.0
        ],
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DarkColors.background,
      selectedItemColor: LightColors.primary,
      unselectedItemColor: LightColors.mutedText,
      selectedLabelStyle: TextStyle(
        fontFamily: 'JetBrainsMonoVariable',
        fontSize: 12,
        fontVariations: [FontVariation('wght', 650)],
      ),

      unselectedLabelStyle: TextStyle(
        fontFamily: 'JetBrainsMonoVariable',
        fontSize: 12,
        fontVariations: [FontVariation('wght', 650)],
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: DarkColors.primary,
      surface: DarkColors.surface,
      secondary: DarkColors.secondary,
      surfaceContainer: DarkColors.elevatedSurface,
      outline: DarkColors.outline,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: DarkColors.text,
        fontFamily: 'InterVariable',
        fontSize: 32,
        fontVariations: [FontVariation('wght', 700)],
      ),

      headlineMedium: TextStyle(
        color: DarkColors.text,
        fontFamily: 'InterVariable',
        fontSize: 24,
        fontVariations: [FontVariation('wght', 600)],
      ),

      titleLarge: TextStyle(
        color: DarkColors.text,
        fontFamily: 'InterVariable',
        fontSize: 20,
        fontVariations: [FontVariation('wght', 600)],
      ),

      titleMedium: TextStyle(
        color: DarkColors.text,
        fontFamily: 'InterVariable',
        fontSize: 18,
        fontVariations: [FontVariation('wght', 500)],
      ),

      bodyLarge: TextStyle(
        color: DarkColors.text,
        fontFamily: 'InterVariable',
        fontSize: 16,
        fontVariations: [FontVariation('wght', 400)],
      ),

      bodyMedium: TextStyle(
        color: DarkColors.text,
        fontFamily: 'InterVariable',
        fontSize: 14,
        fontVariations: [FontVariation('wght', 400)],
      ),

      bodySmall: TextStyle(
        color: DarkColors.mutedText,
        fontFamily: 'InterVariable',
        fontSize: 12,
        fontVariations: [FontVariation('wght', 400)],
      ),
    ),
  );
}

class LightColors {
  static const background = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const elevatedSurface = Color(0xFFF3F4F6);

  static const primary = Color(0xFF0D9488);
  static const secondary = Color(0xFFF2F4F7);
  static const accent = Color(0xFF334155);

  static const text = Color(0xFF111827);
  static const mutedText = Color(0xFF6B7280);

  static const outline = Color(0xFFE5E7EB);
}

class DarkColors {
  static const background = Color(0xFF1A1D22);
  static const surface = Color(0xFF121417);
  static const elevatedSurface = Color(0xFF212124);

  static const primary = Color(0xFF0D9488);
  static const secondary = Color(0xFF0B0C0E);
  static const accent = Color(0xFF4C4ACA);

  static const text = Color(0xFFF9FAFB);
  static const mutedText = Color(0xFF9CA3AF);

  static const outline = Color(0xFF2A2D33);
}

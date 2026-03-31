import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryBlueDark = Color(0xFF0D47A1);
  static const Color primaryBlueLight = Color(0xFF42A5F5);
  static const Color accentYellow = Color(0xFFFDD835);

  // Note card colors (light theme)
  static const List<Color> noteColorsLight = [
    Color(0xFFFFFFFF), // Default white
    Color(0xFFE3F2FD), // Blue-50
    Color(0xFFFFF9C4), // Yellow-50
    Color(0xFFE8F5E9), // Green-50
    Color(0xFFFCE4EC), // Pink-50
    Color(0xFFF3E5F5), // Purple-50
    Color(0xFFFFF3E0), // Orange-50
  ];

  // Note card colors (dark theme)
  static const List<Color> noteColorsDark = [
    Color(0xFF1E1E2E), // Default dark
    Color(0xFF0D2137), // Blue tint
    Color(0xFF2D2A0A), // Yellow tint
    Color(0xFF0A2010), // Green tint
    Color(0xFF2D0A14), // Pink tint
    Color(0xFF1A0D2E), // Purple tint
    Color(0xFF2D1A00), // Orange tint
  ];

  static const List<String> noteColorNames = [
    'Default',
    'Sky',
    'Lemon',
    'Mint',
    'Rose',
    'Lavender',
    'Peach',
  ];

  // ── Light Theme ───────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: primaryBlueLight,
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F4FF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF0F4FF),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryBlue),
        titleTextStyle: TextStyle(
          color: Color(0xFF0D1B2E),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primaryBlue.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: Color(0xFFBBDEFB)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D1B2E),
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0D1B2E),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF4A5568),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF90A4AE),
        ),
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlueLight,
        secondary: primaryBlue,
        surface: const Color(0xFF1E1E2E),
      ),
      scaffoldBackgroundColor: const Color(0xFF12121C),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF12121C),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF90CAF9)),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlueLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: primaryBlueLight, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E1E2E),
        selectedColor: primaryBlueLight.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: Color(0xFF1565C0)),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFFB0BEC5),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF607D8B),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF05070D);
  static const Color bgAlt = Color(0xFF09101A);
  static const Color card = Color(0xFF0C111A);
  static const Color glass = Color(0xA30E1520);
  static const Color green = Color(0xFF44F0A6);
  static const Color cyan = Color(0xFF45D4FF);
  static const Color orange = Color(0xFFFFB34D);
  static const Color text = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFB9C8C1);
  static const Color mutedAlt = Color(0xFF8F9B97);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      fontFamily: 'SF Pro Display',
      brightness: Brightness.dark,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: Brightness.dark,
        surface: card,
        background: bg,
      ).copyWith(
        primary: green,
        secondary: cyan,
        tertiary: orange,
        outline: Colors.white.withOpacity(0.08),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.10),
        thickness: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(
          color: mutedAlt.withOpacity(0.90),
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: green, width: 1.2),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: text,
          fontSize: 38,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.7,
          height: 1.0,
        ),
        displayMedium: TextStyle(
          color: text,
          fontSize: 31,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.2,
          height: 1.05,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontSize: 25,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.0,
          height: 1.04,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 19,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.7,
          height: 1.06,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.35,
        ),
        bodyLarge: TextStyle(
          color: muted,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: muted,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF070B10);
  static const Color card = Color(0xFF0D1516);
  static const Color glass = Color(0xB30A1414);
  static const Color green = Color(0xFF4DFFB5);
  static const Color cyan = Color(0xFF45D5FF);
  static const Color orange = Color(0xFFFFB84D);
  static const Color text = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFB9C8C1);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      fontFamily: 'SF Pro Display',
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: text,
          fontSize: 36,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.4,
          height: 1.05,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontSize: 25,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 19,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        bodyMedium: TextStyle(
          color: muted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
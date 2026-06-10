import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bg = Color(0xFF030408);
  static const Color bgAlt = Color(0xFF060912);
  static const Color card = Color(0xFF0C121D);
  static const Color glass = Color(0xD60E1624);
  static const Color green = Color(0xFF4CFFB6);
  static const Color cyan = Color(0xFF45DFFF);
  static const Color orange = Color(0xFFFFB34D);
  static const Color text = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF9BABBA);
  static const Color mutedAlt = Color(0xFF6B7B8F);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,
      splashFactory: InkSparkle.splashFactory,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: green,
            brightness: Brightness.dark,
            surface: card,
          ).copyWith(
            primary: green,
            secondary: cyan,
            tertiary: orange,
            outline: Colors.white.withOpacity(0.06),
          ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.08),
        thickness: 0.8,
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
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.inter(
          color: mutedAlt,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: green, width: 1.2),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: text,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          color: text,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          height: 1.15,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.inter(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: text,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          color: text,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

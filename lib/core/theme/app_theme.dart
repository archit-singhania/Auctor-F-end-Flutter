import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color bgCard = Color(0xFF12121A);
  static const Color bgElevated = Color(0xFF1A1A26);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color accentBlue = Color(0xFF4D9FFF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentRed = Color(0xFFFF4D4D);
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color borderColor = Color(0xFF2A2A3A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: accentBlue,
        surface: bgCard,
        onPrimary: bgDark,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
        displayLarge: GoogleFonts.syne(
          fontSize: 48, fontWeight: FontWeight.w800,
          color: textPrimary, letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.syne(
          fontSize: 36, fontWeight: FontWeight.w700,
          color: textPrimary, letterSpacing: -1.0,
        ),
        headlineLarge: GoogleFonts.syne(
          fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        headlineMedium: GoogleFonts.syne(
          fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16, fontWeight: FontWeight.w400, color: textSecondary,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: textPrimary, letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      // FIX: CardTheme → CardThemeData
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: bgDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGold, width: 1.5),
        ),
        labelStyle: GoogleFonts.spaceGrotesk(color: textSecondary),
        hintStyle: GoogleFonts.spaceGrotesk(color: textSecondary),
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: accentGold,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}

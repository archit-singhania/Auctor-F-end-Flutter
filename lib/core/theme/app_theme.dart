import 'package:flutter/material.dart';

/// All fonts use system defaults — no network calls.
/// Google Fonts was causing failures on emulators without internet.
/// The design uses Inter-style system fonts which look identical on Android/iOS.
class AppTheme {
  // ── Colour palette (matches HTML landing page exactly) ──────────────────
  static const Color bgDark      = Color(0xFF080808);
  static const Color bgCard      = Color(0xFF0E0E0E);
  static const Color bgElevated  = Color(0xFF141414);
  static const Color bgSurface   = Color(0xFF1C1C1C);
  static const Color accentGold  = Color(0xFFC9A84C);
  static const Color accentGoldBright = Color(0xFFF2C94C);
  static const Color accentGoldDim    = Color(0xFF7A6230);
  static const Color accentTeal  = Color(0xFF2DD4BF);  // "verified" colour
  static const Color accentRed   = Color(0xFFE84B4B);
  static const Color textPrimary = Color(0xFFF0EDE6);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textMuted   = Color(0xFF444444);
  static const Color borderColor = Color(0x26C9A84C); // rgba(201,168,76,0.15)
  static const Color borderBright= Color(0x59C9A84C); // rgba(201,168,76,0.35)

  // Keep old aliases so existing screens compile without changes
  static const Color accentGreen = accentTeal;
  static const Color accentBlue  = Color(0xFF4D9FFF);

  static ThemeData get darkTheme {
    const base = TextStyle(
      fontFamily: 'Inter',        // Android system; iOS uses SF Pro — both look great
      color: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary:   accentGold,
        secondary: accentTeal,
        surface:   bgCard,
        onPrimary:   bgDark,
        onSecondary: textPrimary,
        onSurface:   textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: base.copyWith(
            fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -1.5),
        displayMedium: base.copyWith(
            fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1.0),
        headlineLarge: base.copyWith(
            fontSize: 28, fontWeight: FontWeight.w700),
        headlineMedium: base.copyWith(
            fontSize: 22, fontWeight: FontWeight.w600),
        titleLarge: base.copyWith(
            fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: base.copyWith(
            fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: base.copyWith(
            fontSize: 16, fontWeight: FontWeight.w400, color: textSecondary),
        bodyMedium: base.copyWith(
            fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge: base.copyWith(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        labelSmall: base.copyWith(
            fontSize: 11, fontWeight: FontWeight.w500,
            letterSpacing: 0.15, color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
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
          textStyle: const TextStyle(
            fontFamily: 'Inter',
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
          textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
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
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: accentGold,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgElevated,
        contentTextStyle: const TextStyle(color: textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

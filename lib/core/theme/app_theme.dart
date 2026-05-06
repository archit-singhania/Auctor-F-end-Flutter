import 'package:flutter/material.dart';

/// Auctor Design System — Dark + Light themes
/// Uses system Inter font (no network dependency).
class AppTheme {
  // ── DARK palette ────────────────────────────────────────────────
  static const Color bgDark      = Color(0xFF080808);
  static const Color bgCard      = Color(0xFF0E0E0E);
  static const Color bgElevated  = Color(0xFF141414);
  static const Color bgSurface   = Color(0xFF1C1C1C);
  static const Color accentGold  = Color(0xFFC9A84C);
  static const Color accentGoldBright = Color(0xFFF2C94C);
  static const Color accentGoldDim    = Color(0xFF7A6230);
  static const Color accentTeal  = Color(0xFF2DD4BF);
  static const Color accentRed   = Color(0xFFE84B4B);
  static const Color textPrimary = Color(0xFFF0EDE6);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textMuted   = Color(0xFF444444);
  static const Color borderColor = Color(0x26C9A84C);
  static const Color borderBright= Color(0x59C9A84C);

  // Aliases used throughout the app
  static const Color accentGreen = accentTeal;
  static const Color accentBlue  = Color(0xFF4D9FFF);

  // ── LIGHT palette ────────────────────────────────────────────────
  static const Color lBg            = Color(0xFFF7F5F0);
  static const Color lBgCard        = Color(0xFFFFFFFF);
  static const Color lBgElevated    = Color(0xFFF0EDE6);
  static const Color lBgSurface     = Color(0xFFE8E4DC);
  static const Color lTextPrimary   = Color(0xFF111111);
  static const Color lTextSecondary = Color(0xFF555555);
  static const Color lTextMuted     = Color(0xFFAAAAAA);
  static const Color lBorderColor   = Color(0x30C9A84C);
  static const Color lBorderBright  = Color(0x60C9A84C);

  // ── DARK theme ────────────────────────────────────────────────────
  static ThemeData get darkTheme => _build(
    brightness: Brightness.dark,
    scaffold:   bgDark,
    card:       bgCard,
    elevated:   bgElevated,
    surface:    bgSurface,
    textPrim:   textPrimary,
    textSec:    textSecondary,
    textMut:    textMuted,
    border:     borderColor,
    borderB:    borderBright,
    inputFill:  bgElevated,
  );

  // ── LIGHT theme ────────────────────────────────────────────────────
  static ThemeData get lightTheme => _build(
    brightness: Brightness.light,
    scaffold:   lBg,
    card:       lBgCard,
    elevated:   lBgElevated,
    surface:    lBgSurface,
    textPrim:   lTextPrimary,
    textSec:    lTextSecondary,
    textMut:    lTextMuted,
    border:     lBorderColor,
    borderB:    lBorderBright,
    inputFill:  lBgElevated,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color card,
    required Color elevated,
    required Color surface,
    required Color textPrim,
    required Color textSec,
    required Color textMut,
    required Color border,
    required Color borderB,
    required Color inputFill,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = TextStyle(fontFamily: 'Inter', color: textPrim);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary:    accentGold,
        secondary:  accentTeal,
        surface:    card,
        onPrimary:  isDark ? bgDark : Colors.white,
        onSecondary: textPrim,
        onSurface:  textPrim,
        error:      accentRed,
        onError:    Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge:  base.copyWith(fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -1.5),
        displayMedium: base.copyWith(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1.0),
        headlineLarge: base.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
        headlineMedium: base.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        titleLarge:  base.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: base.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge:   base.copyWith(fontSize: 16, fontWeight: FontWeight.w400, color: textSec),
        bodyMedium:  base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: textSec),
        labelLarge:  base.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        labelSmall:  base.copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: textSec),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrim,
        ),
        iconTheme: IconThemeData(color: textPrim),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: isDark ? bgDark : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrim,
          side: BorderSide(color: border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGold, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSec),
        hintStyle:  TextStyle(color: textSec),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor:   accentGold,
        unselectedItemColor: textSec,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: elevated,
        contentTextStyle: TextStyle(color: textPrim, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

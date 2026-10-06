import 'package:flutter/material.dart';

/// Warm paper, graphite and patinated metal. Text and interaction colors are
/// separate so the champagne decoration never becomes low-contrast body copy.
abstract final class AuctorPalette {
  static const jade = Color(0xff275d57);
  static const jadeMist = Color(0xffaed9cc);
  static const champagne = Color(0xffd8bd8a);
  static const bronze = Color(0xff806239);
  static const paper = Color(0xfffffcf6);
  static const graphite = Color(0xff20282e);
  static const ink = Color(0xff202e32);
  static const pearl = Color(0xfff4f1eb);
}

enum AuctorEdition {
  atelier(
      'Ivory & Jade', Color(0xff275d57), Color(0xffaed9cc), Color(0xff806239)),
  archive(
      'Linen & Ink', Color(0xff344d70), Color(0xffbbceeb), Color(0xff795f3c)),
  dusk('Rose & Slate', Color(0xff704e62), Color(0xffe6c4d6), Color(0xff665f3d));

  const AuctorEdition(this.label, this.accent, this.mist, this.metal);
  final String label;
  final Color accent, mist, metal;
  static AuctorEdition parse(Object? value) => values
      .firstWhere((edition) => edition.name == value, orElse: () => atelier);
}

ThemeData auctorTheme(Brightness brightness,
    {bool highContrast = false,
    AuctorEdition edition = AuctorEdition.atelier}) {
  final dark = brightness == Brightness.dark;
  final ink = dark ? const Color(0xfff3f0e7) : AuctorPalette.ink;
  final muted = dark ? const Color(0xffb8c7c8) : const Color(0xff526568);
  final scheme =
      ColorScheme.fromSeed(seedColor: edition.accent, brightness: brightness)
          .copyWith(
    primary: dark ? edition.mist : edition.accent,
    onPrimary: dark ? const Color(0xff132a27) : Colors.white,
    primaryContainer: dark
        ? Color.lerp(AuctorPalette.graphite, edition.accent, .5)!
        : Color.lerp(AuctorPalette.paper, edition.mist, .42)!,
    onPrimaryContainer: dark ? const Color(0xfff3f0e7) : AuctorPalette.ink,
    secondary: dark ? AuctorPalette.champagne : edition.metal,
    onSecondary: dark ? const Color(0xff302517) : Colors.white,
    secondaryContainer:
        dark ? const Color(0xff423a2f) : const Color(0xfff1e7d5),
    onSecondaryContainer:
        dark ? const Color(0xffead6b1) : const Color(0xff59452c),
    tertiary: dark ? const Color(0xffc1bfdc) : const Color(0xff696587),
    surface: dark ? AuctorPalette.graphite : AuctorPalette.paper,
    onSurface: ink,
    onSurfaceVariant: highContrast ? ink : muted,
    outline: highContrast
        ? ink
        : (dark ? const Color(0xff849496) : const Color(0xff8d9a96)),
    outlineVariant: dark ? const Color(0xff3e4d50) : const Color(0xffd9dfd8),
  );
  final base = Typography.material2021()
      .black
      .apply(fontFamily: 'Inter', bodyColor: ink, displayColor: ink);
  final text = base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
        fontFamily: 'Newsreader',
        fontSize: 64,
        fontWeight: FontWeight.w500,
        height: 1.03,
        letterSpacing: -1.5),
    displayMedium: base.displayMedium?.copyWith(
        fontFamily: 'Newsreader',
        fontSize: 46,
        fontWeight: FontWeight.w500,
        height: 1.08,
        letterSpacing: -.9),
    headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: 'Newsreader',
        fontSize: 34,
        fontWeight: FontWeight.w500,
        height: 1.15,
        letterSpacing: -.5),
    headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Newsreader',
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.18,
        letterSpacing: -.3),
    titleLarge: base.titleLarge?.copyWith(
        fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -.45),
    titleMedium: base.titleMedium?.copyWith(
        fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -.15),
    bodyLarge: base.bodyLarge
        ?.copyWith(fontSize: 16, height: 1.55, letterSpacing: -.1),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
    bodySmall:
        base.bodySmall?.copyWith(fontSize: 12, height: 1.5, color: muted),
    labelLarge: base.labelLarge?.copyWith(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: .1),
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
  final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.outlineVariant));
  return ThemeData(
    fontFamily: 'Inter',
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        dark ? const Color(0xff11191f) : AuctorPalette.pearl,
    textTheme: text,
    iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xff1a252c) : const Color(0xfff2f3ed),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
            borderSide: BorderSide(color: scheme.primary, width: 1.6)),
        errorBorder:
            inputBorder.copyWith(borderSide: BorderSide(color: scheme.error)),
        contentPadding: const EdgeInsets.all(18),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant)),
    filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            textStyle: text.labelLarge,
            shape: shape)),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: text.labelLarge,
            side: BorderSide(
                color:
                    highContrast ? ink : scheme.outline.withValues(alpha: .65)),
            shape: shape)),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: shape,
            textStyle: text.labelLarge)),
    iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
            minimumSize: const Size(48, 48), shape: shape)),
    chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer.withValues(alpha: .5),
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface),
        iconTheme: IconThemeData(color: scheme.primary, size: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        side: BorderSide(color: highContrast ? ink : scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
    popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
    snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xffdfeae4) : AuctorPalette.ink,
        contentTextStyle: TextStyle(
            fontFamily: 'Inter',
            color: dark ? AuctorPalette.ink : AuctorPalette.paper),
        behavior: SnackBarBehavior.floating,
        shape: shape),
    listTileTheme: ListTileThemeData(
        shape: shape,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6)),
    progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary, linearTrackColor: scheme.primaryContainer),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: .22),
        selectionHandleColor: scheme.primary),
    dividerColor: scheme.outlineVariant,
  );
}

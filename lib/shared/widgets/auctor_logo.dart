/// auctor_logo.dart
///
/// Single source of truth for the Auctor logo image.
/// Uses web/favicon.png (copied to assets/images/logo.png by install_logo.py).
///
/// Usage:
///   AuctorLogo(size: 32)           // small — AppBar / nav row
///   AuctorLogo(size: 80)           // large — splash screen
///   AuctorLogo.mark(size: 28)      // just the square icon, no text
import 'package:flutter/material.dart';

class AuctorLogo extends StatelessWidget {
  final double size;
  final bool withName;

  const AuctorLogo({super.key, this.size = 32, this.withName = false});

  /// Icon-only square logo (no "Auctor" wordmark)
  const factory AuctorLogo.mark({Key? key, double size}) = _AuctorLogoMark;

  @override
  Widget build(BuildContext context) {
    final img = _logoImage(size);
    if (!withName) return img;

    return Row(mainAxisSize: MainAxisSize.min, children: [
      img,
      const SizedBox(width: 8),
      Text(
        'Auctor',
        style: TextStyle(
          fontSize: size * 0.6,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ]);
  }
}

class _AuctorLogoMark extends AuctorLogo {
  const _AuctorLogoMark({super.key, super.size}) : super(withName: false);
}

Widget _logoImage(double size) {
  return Image.asset(
    'assets/images/logo.png',
    width: size,
    height: size,
    filterQuality: FilterQuality.high,
    // Falls back to a gold 'A' box if asset is missing (e.g. install_logo.py not run yet)
    errorBuilder: (_, __, ___) => _FallbackLogo(size: size),
  );
}

class _FallbackLogo extends StatelessWidget {
  final double size;
  const _FallbackLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFC9A84C),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Center(
        child: Text(
          'A',
          style: TextStyle(
            fontSize: size * 0.55,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF080808),
          ),
        ),
      ),
    );
  }
}

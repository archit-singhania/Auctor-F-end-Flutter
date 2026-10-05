import 'dart:ui';
import 'package:flutter/material.dart';

/// Glass belongs to the interaction layer. Evidence and long-form content use
/// opaque surfaces. No shader/package dependency or animation runs while idle.
class LiquidGlass extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final bool opaque, reducedMotion, highContrast;
  const LiquidGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.opaque = false,
    this.reducedMotion = false,
    this.highContrast = false,
  });

  @override
  State<LiquidGlass> createState() => _LiquidGlassState();
}

class _LiquidGlassState extends State<LiquidGlass> {
  Alignment highlight = Alignment.topLeft;
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final opaque = widget.opaque || widget.highContrast;
    final reduced =
        widget.reducedMotion || MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(widget.radius);
    final surface = dark ? const Color(0xff202529) : const Color(0xfffffdf7);
    return LayoutBuilder(builder: (context, bounds) {
      return MouseRegion(
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() {
          hovered = false;
          highlight = Alignment.topLeft;
        }),
        onHover: !opaque && !reduced
            ? (event) {
                final width = bounds.hasBoundedWidth ? bounds.maxWidth : 320.0;
                final height =
                    bounds.hasBoundedHeight ? bounds.maxHeight : 160.0;
                setState(() => highlight = Alignment(
                    (event.localPosition.dx / width * 2 - 1).clamp(-1.0, 1.0),
                    (event.localPosition.dy / height * 2 - 1)
                        .clamp(-1.0, 1.0)));
              }
            : null,
        child: AnimatedContainer(
          duration: reduced ? Duration.zero : const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? .22 : .075),
                blurRadius: hovered && !reduced ? 30 : 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              enabled: !opaque,
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: opaque ? surface : null,
                  gradient: opaque
                      ? null
                      : LinearGradient(
                          begin: highlight,
                          end: Alignment(-highlight.x, -highlight.y),
                          colors: [
                            surface.withValues(alpha: dark ? .86 : .9),
                            surface.withValues(alpha: dark ? .74 : .72),
                            surface.withValues(alpha: dark ? .82 : .86),
                          ],
                          stops: const [0, .52, 1],
                        ),
                  borderRadius: radius,
                  border: Border.all(
                    width: widget.highContrast ? 1.5 : 1,
                    color: widget.highContrast
                        ? scheme.onSurface
                        : Colors.white.withValues(alpha: dark ? .22 : .88),
                  ),
                ),
                child: Stack(children: [
                  if (!opaque)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            gradient: RadialGradient(
                              center: highlight,
                              radius: 1.15,
                              colors: [
                                Colors.white
                                    .withValues(alpha: dark ? .055 : .2),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: widget.padding,
                    child: Material(
                        type: MaterialType.transparency, child: widget.child),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class GlassDestination extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected, compact;
  final VoidCallback onTap;
  const GlassDestination(
      {super.key,
      required this.label,
      required this.icon,
      required this.selected,
      required this.onTap,
      this.compact = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final contrast = MediaQuery.highContrastOf(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Tooltip(
        message: label,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? [const Color(0xff3a514b), const Color(0xff263b35)]
                        : [const Color(0xffe0ece2), const Color(0xffd4e1d8)])
                : null,
            border: Border.all(
                color: selected
                    ? (contrast
                        ? scheme.onSurface
                        : Colors.white.withValues(alpha: dark ? .28 : .88))
                    : Colors.transparent),
            boxShadow: selected && !contrast
                ? [
                    BoxShadow(
                        color:
                            Colors.black.withValues(alpha: dark ? .12 : .035),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ]
                : [],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 14, vertical: 12),
              child: compact
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon,
                          color: selected
                              ? scheme.primary
                              : scheme.onSurfaceVariant),
                      const SizedBox(height: 5),
                      Text(label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ])
                  : Row(children: [
                      Icon(icon,
                          color: selected
                              ? scheme.primary
                              : scheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(label,
                              style: TextStyle(
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500))),
                    ]),
            ),
          ),
        ),
      ),
    );
  }
}

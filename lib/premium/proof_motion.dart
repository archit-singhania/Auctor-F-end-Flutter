import 'package:flutter/material.dart';

/// Auctor's motion follows evidence becoming readable: a short settle, then rest.
/// Never synthesizes progress or changes the identity of a form or source record.
abstract final class ProofMotion {
  static const settle = Duration(milliseconds: 220);
  static const response = Duration(milliseconds: 180);
  static const curve = Curves.easeOutCubic;
  static Duration duration(BuildContext context, [Duration value = settle]) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : value;
}

class ProofReveal extends StatefulWidget {
  final Widget child;
  final bool active;
  final int order;
  const ProofReveal(
      {super.key, required this.child, this.active = true, this.order = 0});
  @override
  State<ProofReveal> createState() => _ProofRevealState();
}

class _ProofRevealState extends State<ProofReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this);
  late final CurvedAnimation eased =
      CurvedAnimation(parent: controller, curve: ProofMotion.curve);
  bool initialized = false;
  bool reduced = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = MediaQuery.disableAnimationsOf(context);
    if (!initialized || reduced) {
      initialized = true;
      _settle();
    }
  }

  @override
  void didUpdateWidget(ProofReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _settle();
  }

  void _settle() {
    // Bounded sequencing: even the last card settles within 280 milliseconds.
    controller.duration =
        Duration(milliseconds: 220 + widget.order.clamp(0, 3) * 20);
    if (reduced) {
      controller.value = 1;
    } else if (widget.active) {
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    eased.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: eased,
      child: AnimatedBuilder(
        animation: eased,
        child: widget.child,
        builder: (context, child) => Transform.translate(
            offset: Offset(0, reduced ? 0 : 10 * (1 - eased.value)),
            child: child),
      ),
    );
  }
}

/// Only compact, read-only server states crossfade. Forms remain mounted.
class ProofState extends StatelessWidget {
  final Widget child;
  final Object identity;
  const ProofState({super.key, required this.identity, required this.child});
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: ProofMotion.duration(context, ProofMotion.response),
        switchInCurve: ProofMotion.curve,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [
            for (final old in previous)
              IgnorePointer(child: ExcludeSemantics(child: old)),
            if (current != null) current,
          ],
        ),
        child: KeyedSubtree(key: ValueKey(identity), child: child),
      );
}

Future<T?> showAuctorDialog<T>(
    {required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true}) {
  final themes = InheritedTheme.capture(
      from: context, to: Navigator.of(context, rootNavigator: true).context);
  return Navigator.of(context, rootNavigator: true).push<T>(RawDialogRoute<T>(
    traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
    requestFocus: true,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: .36),
    transitionDuration: ProofMotion.duration(context),
    pageBuilder: (context, animation, secondary) =>
        SafeArea(child: themes.wrap(builder(context))),
    transitionBuilder: (context, animation, secondary, child) {
      final eased = animation.drive(CurveTween(curve: ProofMotion.curve));
      return FadeTransition(
          opacity: eased,
          child: SlideTransition(
              position: Tween(begin: const Offset(0, .025), end: Offset.zero)
                  .animate(eased),
              child: child));
    },
  ));
}

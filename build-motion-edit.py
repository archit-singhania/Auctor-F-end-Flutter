from pathlib import Path
p=Path('lib/premium/app.dart')
s=p.read_text()
s=s.replace("import 'visual_theme.dart';", "import 'visual_theme.dart';\nimport 'proof_motion.dart';")
s=s.replace('highContrast: c.highContrast)', 'highContrast: c.highContrast, edition: c.edition)')
s=s.replace('highContrast: true)', 'highContrast: true, edition: c.edition)')
s=s.replace('themeMode: c.theme,', 'themeMode: c.theme,\n        themeAnimationDuration: c.reducedMotion || MediaQuery.disableAnimationsOf(context) ? Duration.zero : ProofMotion.response,')
s=s.replace('ThemeData theme(Brightness brightness, {bool highContrast = false}) =>\n    auctorTheme(brightness, highContrast: highContrast);', 'ThemeData theme(Brightness brightness, {bool highContrast = false, AuctorEdition edition = AuctorEdition.atelier}) =>\n    auctorTheme(brightness, highContrast: highContrast, edition: edition);')
s=s.replace('showDialog', 'showAuctorDialog')
s=s.replace('    return content;\n  }\n}', '    return ProofReveal(child: content);\n  }\n}',1)
start=s.index('    final page = switch (current) {')
end=s.index('    return Scaffold',start)
s=s[:start]+s[end:]
start=s.index('          Expanded(\n              child: SingleChildScrollView(', s.index('class _Workspace'))
end=s.index('          if (!wide)',start)
s=s[:start]+'''          Expanded(child: _WorkspaceDeck(current: current, wide: wide, error: c.error)),
'''+s[end:]
start=s.index('class SectionTitle')
s=s[:start]+'''/// Panes mount on first visit and retain form/filter/scroll identity thereafter.
class _WorkspaceDeck extends StatefulWidget {
  final int current;
  final bool wide;
  final String? error;
  const _WorkspaceDeck({required this.current, required this.wide, this.error});
  @override
  State<_WorkspaceDeck> createState() => _WorkspaceDeckState();
}

class _WorkspaceDeckState extends State<_WorkspaceDeck> {
  final visited = <int>{};
  final bucket = PageStorageBucket();
  Widget pane(int index) => switch (index) {
    0 => const OverviewPane(), 1 => const EvidencePane(),
    2 => const ChallengesPane(), 3 => const ActivityPane(),
    4 => const DiscoverPane(), 5 => const ProfilePane(),
    _ => const ReviewsPane(),
  };
  @override
  Widget build(BuildContext context) {
    visited.add(widget.current);
    return PageStorage(bucket: bucket, child: Stack(children: [
      for (final index in visited.toList()..sort())
        Positioned.fill(key: ValueKey('destination-$index'), child: Offstage(
          offstage: index != widget.current,
          child: TickerMode(enabled: index == widget.current, child: ExcludeFocus(
            excluding: index != widget.current,
            child: ProofReveal(active: index == widget.current, child: SingleChildScrollView(
              key: PageStorageKey('destination-scroll-$index'),
              padding: EdgeInsets.fromLTRB(widget.wide ? 12 : 20, 8, 24, 32),
              child: Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(children: [
                  if (widget.error != null && index == widget.current) ErrorNotice(widget.error!),
                  pane(index),
                ]),
              )),
            )),
          )),
        )),
    ]));
  }
}

'''+s[start:]
s=s.replace("                    Chip(label: Text(e['status']))", "                    ProofState(identity: e['status'], child: Chip(label: Text(e['status'])))")
s=s.replace("      for (final e in c.list('evidence'))\n        Padding(", "      for (final e in c.list('evidence'))\n        Padding(\n            key: ValueKey('evidence-${e['id']}'),")
s=s.replace("      for (final event in c.list('activity'))\n        Padding(", "      for (final event in c.list('activity'))\n        Padding(\n            key: ValueKey('activity-${event['id']}'),")
s=s.replace("      for (final e in queue ?? [])\n        Padding(", "      for (final e in queue ?? [])\n        Padding(\n            key: ValueKey('review-${e['id']}'),")
s=s.replace("        for (final decision in audit) ReviewAuditCard(decision: decision),", "        for (final decision in audit) ReviewAuditCard(key: ValueKey('decision-${decision['id']}'), decision: decision),")
s=s.replace("      if (queue?.isEmpty == true)\n        const EmptyState", "      if (queue?.isEmpty == true)\n        const ProofReveal(child: EmptyState")
s=s.replace("            'New experience, certificate and coding submissions appear here.'),", "            'New experience, certificate and coding submissions appear here.')),")
s=s.replace("        DropdownButtonFormField<ThemeMode>(", """        DropdownButtonFormField<AuctorEdition>(
            initialValue: c.edition,
            decoration: const InputDecoration(labelText: 'Curated palette'),
            items: [for (final edition in AuctorEdition.values)
              DropdownMenuItem(value: edition, child: Text(edition.label))],
            onChanged: c.busy ? null : (value) => c.preferences(palette: value)),
        const SizedBox(height: 16),
        DropdownButtonFormField<ThemeMode>(""")
# Score digits are always authoritative; the settled ring interpolates old -> new server fractions only.
s=s.replace("child: CircularProgressIndicator(\n                      value: score / 10,", "child: TweenAnimationBuilder<double>(\n                      tween: Tween(end: score / 10),\n                      duration: ProofMotion.duration(context),\n                      curve: ProofMotion.curve,\n                      builder: (context, value, child) => CircularProgressIndicator(\n                      value: value,")
s=s.replace("                      color: Theme.of(context).colorScheme.secondary)),", "                      color: Theme.of(context).colorScheme.secondary))),",1)
s=s.replace("                        Text(score.toStringAsFixed(1),", "                        ProofState(identity: score, child: Text(score.toStringAsFixed(1),")
s=s.replace("fontSize: 38, fontWeight: FontWeight.w500)),", "fontSize: 38, fontWeight: FontWeight.w500))),",1)
# Only confirmed graded content is newly revealed; answer buttons keep state throughout the timer.
s=s.replace("                    if (result != null) ...[", "                    if (result != null) ProofReveal(key: ValueKey(attempt?['id']), child: Semantics(liveRegion: true, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
s=s.replace("                    ] else if (attempt != null)", "                    ]))) else if (attempt != null)")
# Derive backdrop from selected semantic colors while retaining opaque content.
s=s.replace("    final dark = Theme.of(context).brightness == Brightness.dark;\n    return Container(", "    final dark = Theme.of(context).brightness == Brightness.dark;\n    final scheme = Theme.of(context).colorScheme;\n    return Container(")
s=s.replace("const Color(0xff192d2f),", "Color.lerp(const Color(0xff11191f), scheme.primary, .1)!,")
s=s.replace("const Color(0xffe6eeec),", "Color.lerp(AuctorPalette.pearl, scheme.primaryContainer, .6)!,")
p.write_text(s)
p=Path('lib/premium/liquid_glass.dart');s=p.read_text();s=s.replace("? [const Color(0xff344e48), const Color(0xff273e3c)]", "? [scheme.primaryContainer, Color.lerp(scheme.surface, scheme.primaryContainer, .6)!]");s=s.replace(": [const Color(0xffe3efe9), const Color(0xffd4e6df)])", ": [Color.lerp(scheme.surface, scheme.primaryContainer, .65)!, scheme.primaryContainer])");p.write_text(s)

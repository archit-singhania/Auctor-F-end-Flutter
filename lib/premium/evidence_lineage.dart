import 'dart:convert';
import 'package:flutter/material.dart';
import 'controller.dart';
import 'app.dart' show Surface;

class EvidenceLineage extends StatefulWidget {
  const EvidenceLineage({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<EvidenceLineage> createState() => _EvidenceLineageState();
}

class _EvidenceLineageState extends State<EvidenceLineage> {
  List sources = [];
  Map<String, dynamic>? trace;
  bool busy = false, loaded = false;
  String? error;
  Future<void> load([String? id]) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final value = await widget.controller.api
          .call(id == null ? '/lineage' : '/lineage/$id');
      if (mounted) {
        setState(() {
          if (id == null) {
            sources = value;
            loaded = true;
            trace = null;
          } else {
            trace = Map<String, dynamic>.from(value);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Evidence lineage', style: Theme.of(context).textTheme.titleLarge),
        const Text(
            'Inspect exact saved revisions and the material that references them. Historical records remain visible after a source is withdrawn.'),
        OutlinedButton(
            onPressed: busy ? null : () => load(),
            child: const Text('Load source history')),
        if (busy) const LinearProgressIndicator(),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        if (loaded && sources.isEmpty)
          const Text('No captured evidence history yet.'),
        for (final source in sources)
          ListTile(
              title: Text(source['title'] ?? 'Evidence source'),
              subtitle:
                  Text('${source['operation']} · ${source['captured_at']}'),
              trailing: TextButton(
                  onPressed: busy ? null : () => load(source['evidence_id']),
                  child: const Text('Trace source'))),
        if (trace != null) ...[
          Semantics(
              liveRegion: true,
              child: Text(trace!['withdrawn'] == true
                  ? 'Source withdrawn; history retained'
                  : 'Current eligibility: ${trace!['currently_eligible']}')),
          Text(trace!['scope']),
          for (final revision in trace!['revisions'])
            ExpansionTile(
                key: ValueKey('revision-${revision['id']}'),
                title: Text(
                    'Source revision ${revision['id']} · ${revision['operation']}'),
                subtitle: Text('${revision['captured_at']}'),
                children: [
                  SelectableText('SHA-256 ${revision['sha256']}'),
                  SelectableText(const JsonEncoder.withIndent('  ')
                      .convert(revision['payload']))
                ]),
          Text('Downstream references',
              style: Theme.of(context).textTheme.titleMedium),
          if ((trace!['downstream'] as List).isEmpty)
            const Text('No stored downstream references found.'),
          for (final (index, reference)
              in (trace!['downstream'] as List).indexed)
            ExpansionTile(
                key: ValueKey('${trace!['evidence_id']}-$index'),
                title: Text('${reference['kind']} · ${reference['id']}'),
                subtitle: Text(reference['binding']),
                children: [
                  SelectableText(
                      const JsonEncoder.withIndent('  ').convert(reference))
                ]),
        ],
      ]));
}

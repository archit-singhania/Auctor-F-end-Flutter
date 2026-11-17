import 'package:flutter/material.dart';
import 'controller.dart';
import 'app.dart' show Surface;

class EvidenceCollection extends StatefulWidget {
  const EvidenceCollection(
      {super.key, required this.controller, required this.submitEvidence});
  final WorkspaceController controller;
  final Future<void> Function() submitEvidence;
  @override
  State<EvidenceCollection> createState() => _EvidenceCollectionState();
}

class _EvidenceCollectionState extends State<EvidenceCollection> {
  List claims = [], available = [];
  final Map<String, String?> selected = {};
  String? error;
  bool busy = false, loaded = false;
  Future<void> refresh({Future<void> Function()? before}) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await before?.call();
      final data = await widget.controller.api.call('/evidence-collection');
      if (mounted) {
        setState(() {
          claims = data['claims'];
          available = data['available_evidence'];
          loaded = true;
          selected.clear();
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
        Text('Evidence collection',
            style: Theme.of(context).textTheme.titleLarge),
        const Text(
            'Inspect the sources linked to your saved CV claims and career milestones. A missing source leaves a claim unknown.'),
        Wrap(children: [
          OutlinedButton(
              onPressed: busy ? null : () => refresh(),
              child: Text(loaded
                  ? 'Refresh checklists'
                  : 'Load collection checklists')),
          TextButton(
              onPressed:
                  busy ? null : () => refresh(before: widget.submitEvidence),
              child: const Text('Submit supporting material'))
        ]),
        if (busy) const LinearProgressIndicator(),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        if (loaded && claims.isEmpty)
          const Text(
              'Save a CV claim or career milestone to see its collection checklist.'),
        for (final claim in claims)
          ExpansionTile(
              key: ValueKey(claim['id']),
              title: Text(claim['title']),
              subtitle: Text(
                  '${claim['origin']} · ${claim['kind']} · ${claim['status']}'),
              children: [
                for (final step in claim['checklist'])
                  ListTile(title: Text(step)),
                Text(claim['scope']),
                for (final source in claim['linked'])
                  ListTile(
                      title: Text(source['title']),
                      subtitle: Text(
                          '${source['kind']} · ${source['status']} · ${source['eligibility_state']}')),
                if (available.isNotEmpty)
                  DropdownButtonFormField<String>(
                      key: ValueKey('${claim['id']}-${claim['linked'].length}'),
                      initialValue: selected[claim['id']],
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Existing evidence to link'),
                      items: [
                        for (final e in available.where((e) =>
                            !(claim['linked'] as List)
                                .any((linked) => linked['id'] == e['id'])))
                          DropdownMenuItem<String>(
                              value: e['id'],
                              child: Text('${e['title']} · ${e['status']}',
                                  overflow: TextOverflow.ellipsis))
                      ],
                      onChanged: busy
                          ? null
                          : (id) => setState(() => selected[claim['id']] = id)),
                OutlinedButton(
                    onPressed: busy || selected[claim['id']] == null
                        ? null
                        : () => refresh(before: () async {
                              await widget.controller.api.call(
                                  '/evidence-collection/${claim['id']}/links',
                                  method: 'POST',
                                  data: {'evidence_id': selected[claim['id']]});
                            }),
                    child: const Text('Attach selected evidence')),
              ])
      ]));
}

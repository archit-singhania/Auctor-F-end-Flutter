import 'dart:convert';
import 'package:flutter/material.dart';
import 'controller.dart';
import 'app.dart' show Surface;

class DisputesWorkspace extends StatefulWidget {
  const DisputesWorkspace({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<DisputesWorkspace> createState() => _DisputesWorkspaceState();
}

class _DisputesWorkspaceState extends State<DisputesWorkspace> {
  List disputes = [], sources = [];
  Map<String, dynamic>? selected;
  final reason = TextEditingController(),
      correction = TextEditingController(),
      note = TextEditingController();
  String? evidenceId, error;
  final support = <String>{};
  int? reviewerId;
  String correctedStatus = 'rejected';
  bool busy = false, loaded = false;
  @override
  void dispose() {
    reason.dispose();
    correction.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
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

  Future<void> load() async {
    final list = await widget.controller.api.call('/disputes');
    final evidence = await widget.controller.api.call('/evidence-collection');
    if (mounted) {
      setState(() {
        disputes = list;
        sources = evidence['available_evidence'];
        loaded = true;
      });
    }
  }

  Future<void> inspect(String id) async {
    final value = await widget.controller.api.call('/disputes/$id');
    if (mounted) {
      setState(() {
        selected = Map<String, dynamic>.from(value);
        reviewerId = null;
      });
    }
  }

  Future<void> act(String action) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Confirm ${action.replaceAll('_', ' ')}?'),
                content: Text(action == 'corrected'
                    ? 'Record a new $correctedStatus decision, revoke earlier receipts and recalculate current eligibility. Earlier decisions remain in history.'
                    : 'This action and your note will be added to the dispute history.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirm action'))
                ]));
    if (ok != true) return;
    await widget.controller.api
        .call('/disputes/${selected!['id']}/actions', method: 'POST', data: {
      'revision': selected!['revision'],
      'action': action,
      'note': note.text,
      'reviewer_id': reviewerId,
      'corrected_status': correctedStatus,
      'source_sha256': selected!['source_sha256']
    });
    note.clear();
    await inspect(selected!['id']);
    await load();
  }

  @override
  Widget build(BuildContext context) => Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Disputes and appeals',
            style: Theme.of(context).textTheme.titleLarge),
        const Text(
            'Request a correction with supporting material. Opening a dispute does not change verification. Independent reviewer decisions remain auditable.'),
        OutlinedButton(
            onPressed: busy ? null : () => run(load),
            child: const Text('Load disputes')),
        if (busy) const LinearProgressIndicator(),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        if (loaded)
          ExpansionTile(title: const Text('Open a dispute'), children: [
            DropdownButtonFormField<String>(
                initialValue: evidenceId,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Evidence to dispute'),
                items: [
                  for (final e in sources)
                    DropdownMenuItem<String>(
                        value: e['id'],
                        child:
                            Text(e['title'], overflow: TextOverflow.ellipsis))
                ],
                onChanged: busy ? null : (v) => setState(() => evidenceId = v)),
            TextField(
                controller: reason,
                enabled: !busy,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Reason (at least 10 characters)')),
            TextField(
                controller: correction,
                enabled: !busy,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Requested correction')),
            for (final e in sources)
              CheckboxListTile(
                  title: Text('Supporting material: ${e['title']}'),
                  value: support.contains(e['id']),
                  onChanged: busy
                      ? null
                      : (v) => setState(() {
                            v == true
                                ? support.add(e['id'])
                                : support.remove(e['id']);
                          })),
            FilledButton(
                onPressed: busy || evidenceId == null
                    ? null
                    : () => run(() async {
                          final value = await widget.controller.api
                              .call('/disputes', method: 'POST', data: {
                            'evidence_id': evidenceId,
                            'reason': reason.text,
                            'requested_correction': correction.text,
                            'supporting_ids': support.toList()
                          });
                          reason.clear();
                          correction.clear();
                          support.clear();
                          await load();
                          await inspect(value['id']);
                        }),
                child: const Text('Submit dispute')),
          ]),
        if (loaded && disputes.isEmpty) const Text('No disputes available.'),
        for (final dispute in disputes)
          ListTile(
              title: Text(dispute['data']['requested_correction']),
              subtitle: Text(
                  '${dispute['state']} · revision ${dispute['revision']} · reviewer ${dispute['reviewer_id'] ?? 'unassigned'}'),
              onTap: busy ? null : () => run(() => inspect(dispute['id']))),
        if (selected != null) ...[
          Text('Selected dispute — ${selected!['state']}',
              style: Theme.of(context).textTheme.titleMedium),
          ExpansionTile(
              title: const Text('Inspect original and current source'),
              children: [
                SelectableText(const JsonEncoder.withIndent('  ').convert({
                  'submission': selected!['data'],
                  'current_source': selected!['current_source']
                }))
              ]),
          for (final entry in selected!['history'])
            ListTile(
                title:
                    Text('${entry['action']} · revision ${entry['revision']}'),
                subtitle: Text(
                    '${entry['note']}\n${entry['created_at']} · actor ${entry['actor_id']} · reviewer ${entry['reviewer_id'] ?? 'unassigned'}')),
          if (!['upheld', 'corrected', 'withdrawn']
              .contains(selected!['state'])) ...[
            TextField(
                controller: note,
                enabled: !busy,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Action note or requested information')),
            if (selected!['user_id'] == widget.controller.profile['id'])
              Wrap(spacing: 8, children: [
                if (selected!['state'] == 'awaiting_information')
                  OutlinedButton(
                      onPressed: busy ? null : () => run(() => act('respond')),
                      child: const Text('Submit information')),
                TextButton(
                    onPressed: busy ? null : () => run(() => act('withdrawn')),
                    child: const Text('Withdraw dispute')),
              ]),
            if (widget.controller.profile['role'] == 'reviewer') ...[
              DropdownButtonFormField<int>(
                  key: ValueKey('${selected!['id']}-${selected!['revision']}'),
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Independent reviewer for reassignment'),
                  items: [
                    for (final r in selected!['reviewers'])
                      if (r['independent'] == true)
                        DropdownMenuItem<int>(
                            value: r['id'], child: Text(r['display_name']))
                  ],
                  onChanged:
                      busy ? null : (v) => setState(() => reviewerId = v)),
              TextButton(
                  onPressed: busy || reviewerId == null
                      ? null
                      : () => run(() => act('assign')),
                  child: const Text('Record reassignment')),
              if (selected!['reviewer_id'] ==
                  widget.controller.profile['id']) ...[
                DropdownButtonFormField<String>(
                    initialValue: correctedStatus,
                    decoration: const InputDecoration(
                        labelText: 'Proposed corrected evidence status'),
                    items: const [
                      DropdownMenuItem(
                          value: 'rejected', child: Text('Rejected')),
                      DropdownMenuItem(
                          value: 'verified', child: Text('Verified'))
                    ],
                    onChanged: busy
                        ? null
                        : (v) => setState(() => correctedStatus = v!)),
                Wrap(spacing: 8, children: [
                  for (final action in [
                    'under_review',
                    'awaiting_information',
                    'upheld',
                    'corrected'
                  ])
                    OutlinedButton(
                        onPressed: busy ? null : () => run(() => act(action)),
                        child: Text(action == 'upheld'
                            ? 'Uphold original decision'
                            : action.replaceAll('_', ' ')))
                ]),
              ],
            ],
          ],
        ],
      ]));
}

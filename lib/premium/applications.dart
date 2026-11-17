import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'controller.dart';
import 'app.dart' show Surface, download;

const applicationStages = ['saved', 'applied', 'interview', 'offer', 'closed'];

class ApplicationWorkspace extends StatefulWidget {
  const ApplicationWorkspace({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<ApplicationWorkspace> createState() => _ApplicationWorkspaceState();
}

class _ApplicationWorkspaceState extends State<ApplicationWorkspace> {
  List records = [], evidence = [], runs = [];
  bool busy = false, loaded = false, board = false;
  String? error;
  Map<String, dynamic>? get draft => widget.controller.applicationDraft;
  Future<void> perform(Future<void> Function() action) async {
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
    final applications = await widget.controller.api.call('/applications');
    final collection = await widget.controller.api.call('/evidence-collection');
    final roles = await widget.controller.api.call('/role-fit');
    if (mounted) {
      setState(() {
        records = applications;
        evidence = collection['available_evidence'];
        runs = roles['runs'];
        loaded = true;
      });
    }
  }

  void create() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    setState(() => widget.controller.applicationDraft = {
          'id':
              '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}',
          'revision': 0,
          'employer': '',
          'role': '',
          'stage': 'saved',
          'applied_on': null,
          'notes': '',
          'evidence_ids': <String>[],
          'role_run_id': null,
          'interviews': <dynamic>[]
        });
  }

  Widget field(String key, String label, {int lines = 1}) => TextFormField(
        key: ValueKey('${draft!['id']}-$key'),
        initialValue: draft![key]?.toString() ?? '',
        decoration: InputDecoration(labelText: label),
        maxLines: lines,
        enabled: !busy,
        onChanged: (value) =>
            draft![key] = key == 'applied_on' && value.isEmpty ? null : value,
      );
  Future<void> inspect(Map record) async {
    final values = await widget.controller.api
        .call('/applications/${record['id']}/snapshots');
    if (!mounted) return;
    await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Saved submission snapshots'),
              content: SizedBox(
                  width: 700,
                  child: SingleChildScrollView(
                      child: SelectableText((values as List).isEmpty
                          ? 'No snapshot saved. Review and save the application, then freeze its material.'
                          : const JsonEncoder.withIndent('  ')
                              .convert(values)))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ));
  }

  Widget card(Map record) => Card(
          child: ListTile(
        title: Text('${record['role']} · ${record['employer']}'),
        subtitle: Text('${record['stage']} · revision ${record['revision']}'),
        onTap: busy || draft != null
            ? null
            : () => setState(() => widget.controller.applicationDraft =
                jsonDecode(jsonEncode(record))),
        trailing: IconButton(
            tooltip: 'Inspect saved snapshots',
            icon: const Icon(Icons.history),
            onPressed: busy ? null : () => perform(() => inspect(record))),
      ));
  @override
  Widget build(BuildContext context) => Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Application workspace',
            style: Theme.of(context).textTheme.titleLarge),
        const Text(
            'Private job tracking and saved submission material. Calendar exports create local files; no employer is contacted.'),
        Wrap(spacing: 8, children: [
          OutlinedButton(
              onPressed: busy ? null : () => perform(load),
              child:
                  Text(loaded ? 'Refresh applications' : 'Load applications')),
          FilledButton(
              onPressed: busy || draft != null ? null : create,
              child: const Text('New application')),
          TextButton(
              onPressed: () => setState(() => board = !board),
              child: Text(board ? 'List view' : 'Board view')),
        ]),
        if (busy) const LinearProgressIndicator(),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        if (loaded && records.isEmpty)
          const Text('No applications yet. Create a private record to begin.'),
        if (board)
          Wrap(spacing: 12, runSpacing: 12, children: [
            for (final stage in applicationStages)
              SizedBox(
                  width: 280,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stage,
                            style: Theme.of(context).textTheme.titleMedium),
                        for (final record
                            in records.where((r) => r['stage'] == stage))
                          card(record)
                      ]))
          ])
        else
          for (final record in records) card(record),
        if (draft != null) ...[
          const Divider(),
          const Text('Application draft — save before freezing or exporting'),
          field('employer', 'Employer'),
          field('role', 'Role'),
          field('applied_on', 'Application date (YYYY-MM-DD, optional)'),
          field('notes', 'Private notes', lines: 3),
          DropdownButtonFormField<String>(
              key: ValueKey('${draft!['id']}-stage'),
              initialValue: draft!['stage'],
              decoration: const InputDecoration(labelText: 'Stage'),
              items: [
                for (final stage in applicationStages)
                  DropdownMenuItem(value: stage, child: Text(stage))
              ],
              onChanged: busy
                  ? null
                  : (value) => setState(() => draft!['stage'] = value)),
          const Text('Selected evidence'),
          for (final source in evidence)
            CheckboxListTile(
                title: Text(source['title']),
                subtitle: Text(source['status']),
                value: (draft!['evidence_ids'] as List).contains(source['id']),
                onChanged: busy
                    ? null
                    : (checked) => setState(() {
                          final ids = draft!['evidence_ids'] as List;
                          checked == true
                              ? ids.add(source['id'])
                              : ids.remove(source['id']);
                        })),
          DropdownButtonFormField<String>(
              key: ValueKey('${draft!['id']}-fit-${runs.length}'),
              initialValue: runs.any((r) => r['id'] == draft!['role_run_id'])
                  ? draft!['role_run_id']
                  : '',
              isExpanded: true,
              decoration:
                  const InputDecoration(labelText: 'Saved role-fit run'),
              items: [
                const DropdownMenuItem(
                    value: '', child: Text('No role-fit run')),
                for (final run in runs)
                  DropdownMenuItem<String>(
                      value: run['id'],
                      child: Text('${run['created_at']}',
                          overflow: TextOverflow.ellipsis))
              ],
              onChanged: busy
                  ? null
                  : (value) =>
                      draft!['role_run_id'] = value == '' ? null : value),
          for (final (index, interview)
              in (draft!['interviews'] as List).indexed)
            Column(children: [
              TextFormField(
                  key: ValueKey('${draft!['id']}-$index-title'),
                  initialValue: interview['title'],
                  decoration:
                      const InputDecoration(labelText: 'Interview title'),
                  onChanged: busy ? null : (v) => interview['title'] = v),
              TextFormField(
                  key: ValueKey('${draft!['id']}-$index-time'),
                  initialValue: interview['starts_at'],
                  decoration: const InputDecoration(
                      labelText:
                          'Time with offset (2026-12-01T10:00:00+05:30)'),
                  onChanged: busy ? null : (v) => interview['starts_at'] = v),
              TextFormField(
                  initialValue: '${interview['duration_minutes']}',
                  decoration:
                      const InputDecoration(labelText: 'Duration in minutes'),
                  keyboardType: TextInputType.number,
                  onChanged: busy
                      ? null
                      : (v) =>
                          interview['duration_minutes'] = int.tryParse(v) ?? 0),
            ]),
          TextButton(
              onPressed: busy
                  ? null
                  : () => setState(() => (draft!['interviews'] as List).add(
                      {'title': '', 'starts_at': '', 'duration_minutes': 60})),
              child: const Text('Add interview')),
          Wrap(spacing: 8, children: [
            FilledButton(
                onPressed: busy
                    ? null
                    : () => perform(() async {
                          final result = await widget.controller.api.call(
                              '/applications',
                              method: 'PUT',
                              data: draft);
                          widget.controller.applicationDraft =
                              Map<String, dynamic>.from(result);
                          await load();
                        }),
                child: const Text('Save application')),
            OutlinedButton(
                onPressed: busy || draft!['revision'] == 0
                    ? null
                    : () => perform(() async {
                          final approved = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                      title: const Text(
                                          'Freeze saved submission material?'),
                                      content: const Text(
                                          'This saves the last saved application revision, current CV, reviewed requirements and selected evidence. Unsaved edits are excluded.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel')),
                                        FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child:
                                                const Text('Freeze snapshot'))
                                      ]));
                          if (approved != true) return;
                          await widget.controller.api.call(
                              '/applications/${draft!['id']}/snapshots',
                              method: 'POST',
                              data: {'revision': draft!['revision']});
                          await inspect(draft!);
                        }),
                child: const Text('Freeze saved material')),
            TextButton(
                onPressed: busy || draft!['revision'] == 0
                    ? null
                    : () => perform(() => download(
                        widget.controller.api,
                        '/applications/${draft!['id']}/calendar',
                        'application-interviews.ics')),
                child: const Text('Export saved interviews')),
            TextButton(
                onPressed: busy
                    ? null
                    : () async {
                        final close = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                                    title:
                                        const Text('Close application draft?'),
                                    content: const Text(
                                        'Unsaved changes will be discarded.'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Keep editing')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Discard draft'))
                                    ]));
                        if (close == true && mounted) {
                          setState(
                              () => widget.controller.applicationDraft = null);
                        }
                      },
                child: const Text('Close draft')),
          ]),
        ],
      ]));
}

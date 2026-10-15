import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'controller.dart';
import 'liquid_glass.dart';
import 'save_stub.dart'
    if (dart.library.io) 'save_io.dart'
    if (dart.library.js_interop) 'save_web.dart';

class EvidenceWorkbench extends StatefulWidget {
  const EvidenceWorkbench({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<EvidenceWorkbench> createState() => _EvidenceWorkbenchState();
}

class _EvidenceWorkbenchState extends State<EvidenceWorkbench> {
  List snapshots = [], comparisons = [], sessions = [];
  Map<String, dynamic>? role;
  bool loading = true, working = false, practice = false, reading = false;
  String? error;
  Timer? timer;
  int lastTick = -1;
  Duration offset = Duration.zero;
  Map<String, dynamic> get drafts => widget.controller.workbenchDraft ??= {
        'annotations': <String, dynamic>{},
        'practice': <String, dynamic>{},
        'requirements': <int>[],
        'evidence': <String>[]
      };
  String? get comparisonId => drafts['comparisonId'];
  String? get sessionId => drafts['sessionId'];
  Map? get comparison =>
      comparisons.where((r) => r['id'] == comparisonId).firstOrNull;
  Map? get session => sessions.where((r) => r['id'] == sessionId).firstOrNull;
  @override
  void initState() {
    super.initState();
    load();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        if (practice && session?['status'] == 'active') {
          final remaining = DateTime.parse(session!['expires_at'])
              .difference(DateTime.now().toUtc().add(offset))
              .inSeconds;
          final tick = remaining < 0 ? 0 : remaining;
          if (lastTick != tick) {
            setState(() => lastTick = tick);
          }
        }
        if (snapshots.any((s) => ['queued', 'running'].contains(s['status'])) &&
            !working) {
          load(quiet: true);
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> load({bool quiet = false}) async {
    if (reading) return;
    reading = true;
    try {
      final c = widget.controller;
      final response = await Future.wait([
        c.api.call('/workbench/snapshots'),
        c.api.call('/workbench/comparisons'),
        c.api.call('/workbench/practice'),
        c.api.call('/role-fit')
      ]);
      if (!mounted) return;
      if (comparisonId != null &&
          !(response[1] as List).any((r) => r['id'] == comparisonId)) {
        (response[1] as List).insert(
            0, await c.api.call('/workbench/comparisons/$comparisonId'));
      }
      if (sessionId != null &&
          !(response[2]['sessions'] as List).any((r) => r['id'] == sessionId)) {
        (response[2]['sessions'] as List)
            .insert(0, await c.api.call('/workbench/practice/$sessionId'));
      }
      final chosen = (response[1] as List)
          .where((r) => r['id'] == comparisonId)
          .firstOrNull;
      if (chosen != null) {
        for (final id in [chosen['left_id'], chosen['right_id']]) {
          if (!(response[0] as List).any((r) => r['id'] == id)) {
            (response[0] as List)
                .add(await c.api.call('/workbench/snapshots/$id'));
          }
        }
      }
      if (!mounted) return;
      setState(() {
        snapshots = response[0];
        comparisons = response[1];
        sessions = response[2]['sessions'];
        role = Map<String, dynamic>.from(response[3]['document']);
        offset = DateTime.parse(response[2]['server_now'])
            .difference(DateTime.now().toUtc());
        loading = false;
        if (!quiet) {
          error = null;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e.toString();
        });
      }
    } finally {
      reading = false;
    }
  }

  Future<void> perform(Future<void> Function() operation) async {
    setState(() {
      working = true;
      error = null;
    });
    try {
      await operation();
      while (reading && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      if (mounted) {
        await load();
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => working = false);
      }
    }
  }

  Future<void> snapshot(String kind, String id) => perform(() async {
        await widget.controller.api.call('/workbench/snapshots',
            method: 'POST', data: {'kind': kind, 'source_id': id});
      });
  Future<void> addNote() async {
    String side = 'left', line = '1', text = '';
    final form = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Annotate a snapshot line'),
                content: Form(
                    key: form,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: DropdownButtonFormField<String>(
                              initialValue: side,
                              items: ['left', 'right']
                                  .map((v) => DropdownMenuItem(
                                      value: v, child: Text(v)))
                                  .toList(),
                              decoration: const InputDecoration(
                                  labelText: 'Snapshot side'),
                              onChanged: (v) => side = v!)),
                      TextFormField(
                          initialValue: line,
                          decoration:
                              const InputDecoration(labelText: 'Line number'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => line = v,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            return n == null || n < 1 || n > 2000
                                ? 'Enter a line from 1 to 2000'
                                : null;
                          }),
                      TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Annotation'),
                          maxLines: 3,
                          maxLength: 2000,
                          onChanged: (v) => text = v,
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? 'Enter an annotation'
                              : null),
                    ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () {
                        if (form.currentState!.validate()) {
                          Navigator.pop(ctx, true);
                        }
                      },
                      child: const Text('Keep annotation'))
                ]));
    if (accepted == true && mounted) {
      setState(() => notes['annotations']
          .add({'side': side, 'line': int.parse(line), 'text': text.trim()}));
    }
  }

  Map<String, dynamic> get notes =>
      drafts['annotations'][comparisonId] ??= jsonDecode(jsonEncode({
        'revision': comparison!['revision'],
        'annotations': comparison!['annotations']
      }));
  Map<String, dynamic> get answers =>
      drafts['practice'][sessionId] ??= jsonDecode(jsonEncode({
        'revision': session!['revision'],
        'answers': session!['answers'],
        'review': session!['review']
      }));
  Future<void> saveNotes() => perform(() async {
        await widget.controller.api.call(
            '/workbench/comparisons/$comparisonId/annotations',
            method: 'PUT',
            data: notes);
        drafts['annotations'].remove(comparisonId);
      });
  Future<void> savePractice({bool finish = false}) => perform(() async {
        await widget.controller.api.call('/workbench/practice/$sessionId',
            method: 'PUT', data: {...answers, 'finish': finish});
        drafts['practice'].remove(sessionId);
      });
  Widget pane(Map snapshot, String side, List operations) {
    final data = Map<String, dynamic>.from(snapshot['data']);
    final lines = data['text'].toString().split('\n');
    final changed = <int>{};
    for (final op in operations) {
      if (op[0] != 'equal') {
        for (int i = op[side == 'left' ? 1 : 3];
            i < op[side == 'left' ? 2 : 4];
            i++) {
          changed.add(i);
        }
      }
    }
    final document = data['source']?['document_id'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          '${side == 'left' ? 'Before' : 'After'} · ${snapshot['kind']} / ${snapshot['source_id']}',
          style: Theme.of(context).textTheme.titleMedium),
      Text(data['scope']),
      if (data['truncated'] == true)
        const Text(
            'Bounded extract: the comparison omits text beyond 2,000 lines / 100,000 characters.'),
      if (document != null)
        TextButton(
            onPressed: working
                ? null
                : () => perform(() async {
                      final bytes = await widget.controller.api
                          .bytes('/cv/jobs/$document/file');
                      await saveReport('cv-source.pdf', bytes);
                    }),
            child: const Text('Download authorized original PDF')),
      SizedBox(
          height: 300,
          child: ListView.builder(
              itemCount: lines.length,
              itemBuilder: (ctx, i) => Container(
                  color: changed.contains(i)
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : null,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: 42,
                            child: Text('${i + 1}',
                                semanticsLabel: 'Line ${i + 1}')),
                        Expanded(
                            child: SelectableText(lines[i],
                                style: Theme.of(context).textTheme.bodySmall))
                      ])))),
    ]);
  }

  String shortId(Object? value, int length) {
    final text = value.toString();
    return text.length <= length ? text : text.substring(0, length);
  }

  Widget comparisonRoom() {
    final c = widget.controller;
    final ready = snapshots.where((s) => s['status'] == 'ready').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
          'Freeze a source before comparing it. CV revisions link to their claim version; PDF snapshots compare extracted text, not pixels. Repository snapshots cover cached metadata, not source code.'),
      Wrap(spacing: 8, runSpacing: 8, children: [
        PopupMenuButton<String>(
            tooltip: 'Snapshot CV revision',
            onSelected: (id) => snapshot('cv_version', id),
            itemBuilder: (_) => c
                .list('versions')
                .map((v) => PopupMenuItem(
                    value: '${v['id']}',
                    child: Text('CV revision ${v['id']} · ${v['note']}')))
                .toList(),
            child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Snapshot CV revision'))),
        PopupMenuButton<String>(
            tooltip: 'Snapshot evidence record',
            onSelected: (id) => snapshot('evidence', id),
            itemBuilder: (_) => c
                .list('evidence')
                .map((e) => PopupMenuItem<String>(
                    value: e['id'], child: Text(e['title'])))
                .toList(),
            child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Snapshot evidence record'))),
        PopupMenuButton<String>(
            tooltip: 'Snapshot cached repository',
            onSelected: (id) => snapshot('repository', id),
            itemBuilder: (_) =>
                (c.profile['github_identity']?['repositories'] as List? ?? [])
                    .map((r) => PopupMenuItem<String>(
                        value: r['full_name'], child: Text(r['full_name'])))
                    .toList(),
            child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Snapshot cached repository'))),
      ]),
      if (snapshots.isEmpty)
        const Text(
            'No snapshots yet. Add CV revisions or evidence in the existing Evidence workspace first.'),
      for (final s in snapshots)
        Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text('${s['kind']} / ${s['source_id']} · ${s['status']}'),
              if (s['error'] != null) Text(s['error']),
              if (['queued', 'running'].contains(s['status']))
                TextButton(
                    onPressed: working
                        ? null
                        : () => perform(() async {
                              await c.api.call(
                                  '/workbench/snapshots/${s['id']}/cancel',
                                  method: 'POST');
                            }),
                    child: const Text('Cancel snapshot')),
              if (['failed', 'cancelled'].contains(s['status']))
                TextButton(
                    onPressed: working
                        ? null
                        : () => perform(() async {
                              await c.api.call(
                                  '/workbench/snapshots/${s['id']}/retry',
                                  method: 'POST');
                            }),
                    child: const Text('Retry snapshot'))
            ]),
      if (ready.isNotEmpty) ...[
        for (final side in ['left', 'right'])
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DropdownButtonFormField<String>(
                  initialValue: ready.any((s) => s['id'] == drafts[side])
                      ? drafts[side]
                      : null,
                  isExpanded: true,
                  decoration: InputDecoration(
                      labelText: side == 'left'
                          ? 'Before snapshot'
                          : 'After snapshot'),
                  items: ready
                      .map((s) => DropdownMenuItem<String>(
                          value: s['id'],
                          child: Text(
                              '${s['kind']} / ${s['source_id']} · ${shortId(s['id'], 6)}')))
                      .toList(),
                  onChanged: working
                      ? null
                      : (v) => setState(() => drafts[side] = v))),
        FilledButton(
            onPressed: working ||
                    drafts['left'] == null ||
                    drafts['right'] == null
                ? null
                : () => perform(() async {
                      final result = await c.api.call('/workbench/comparisons',
                          method: 'POST',
                          data: {
                            'left_id': drafts['left'],
                            'right_id': drafts['right']
                          });
                      drafts['comparisonId'] = result['id'];
                    }),
            child: const Text('Compare saved snapshots')),
      ],
      if (comparisons.isNotEmpty)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DropdownButtonFormField<String>(
                key: ValueKey('comparison-$comparisonId'),
                initialValue: comparisonId,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Saved comparison'),
                items: comparisons
                    .map((r) => DropdownMenuItem<String>(
                        value: r['id'],
                        child: Text('Comparison ${shortId(r['id'], 8)}')))
                    .toList(),
                onChanged: (v) => setState(() => drafts['comparisonId'] = v))),
      if (comparison != null) ...[
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(comparison!['data']['scope'])),
        LayoutBuilder(builder: (ctx, b) {
          final left = snapshots
                  .where((s) => s['id'] == comparison!['left_id'])
                  .firstOrNull,
              right = snapshots
                  .where((s) => s['id'] == comparison!['right_id'])
                  .firstOrNull;
          if (left == null || right == null) {
            return const Text(
                'Snapshot is outside the recent list. Create a comparison from the loaded snapshots.');
          }
          final l = pane(left, 'left', comparison!['data']['operations']),
              r = pane(right, 'right', comparison!['data']['operations']);
          return b.maxWidth > 850
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: l),
                  const SizedBox(width: 16),
                  Expanded(child: r)
                ])
              : Column(children: [l, const SizedBox(height: 16), r]);
        }),
        Wrap(spacing: 8, children: [
          OutlinedButton(
              onPressed: working ? null : addNote,
              child: const Text('Add line annotation')),
          FilledButton(
              onPressed: working ? null : saveNotes,
              child: const Text('Save annotations'))
        ]),
        for (final entry in (notes['annotations'] as List).asMap().entries)
          ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                  '${entry.value['side']} line ${entry.value['line']} · ${entry.value['text']}'),
              trailing: IconButton(
                  tooltip: 'Remove annotation',
                  onPressed: working
                      ? null
                      : () => setState(
                          () => notes['annotations'].removeAt(entry.key)),
                  icon: const Icon(Icons.close))),
        const Text(
            'Annotation drafts remain during navigation. A stale save fails without replacing another client’s notes.'),
      ],
    ]);
  }

  Widget practiceRoom() {
    final reqs = role?['requirements'] as List? ?? [];
    final selected = List<int>.from(drafts['requirements']);
    final evidence = List<String>.from(drafts['evidence']);
    final current = session;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
          'Ungraded interview practice from your reviewed role and selected evidence. Timers are practice guidance; they do not certify an assessment or change verified scores.'),
      if (role?['reviewed'] != true || reqs.isEmpty)
        const Text(
            'Review and save role requirements in Role-fit atelier first.'),
      for (final entry in reqs.asMap().entries)
        CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Practice ${entry.value['skill']}'),
            value: selected.contains(entry.key),
            onChanged: working
                ? null
                : (v) => setState(() {
                      if (v == true) {
                        selected.add(entry.key);
                      } else {
                        selected.remove(entry.key);
                      }
                      drafts['requirements'] = selected;
                    })),
      for (final e in widget.controller.list('evidence'))
        CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Use evidence: ${e['title']}'),
            subtitle: Text(
                '${e['status']} · included as context, not a new verification'),
            value: evidence.contains(e['id']),
            onChanged: working
                ? null
                : (v) => setState(() {
                      if (v == true) {
                        evidence.add(e['id']);
                      } else {
                        evidence.remove(e['id']);
                      }
                      drafts['evidence'] = evidence;
                    })),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: DropdownButtonFormField<int>(
              initialValue: drafts['duration'] ?? 600,
              decoration: const InputDecoration(labelText: 'Practice duration'),
              items: [300, 600, 1200]
                  .map((v) => DropdownMenuItem(
                      value: v, child: Text('${v ~/ 60} minutes')))
                  .toList(),
              onChanged: working ? null : (v) => drafts['duration'] = v)),
      FilledButton(
          onPressed: working || selected.isEmpty || role?['reviewed'] != true
              ? null
              : () => perform(() async {
                    final result = await widget.controller.api
                        .call('/workbench/practice', method: 'POST', data: {
                      'role_revision': role!['revision'],
                      'requirement_indexes': selected,
                      'evidence_ids': evidence,
                      'duration_seconds': drafts['duration'] ?? 600
                    });
                    drafts['sessionId'] = result['id'];
                  }),
          child: const Text('Start practice session')),
      if (sessions.isEmpty) const Text('No saved practice sessions yet.'),
      if (sessions.isNotEmpty)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DropdownButtonFormField<String>(
                key: ValueKey('session-$sessionId'),
                initialValue: sessionId,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Saved practice session'),
                items: sessions
                    .map((s) => DropdownMenuItem<String>(
                        value: s['id'],
                        child: Text('${s['status']} · ${s['started_at']}')))
                    .toList(),
                onChanged: (v) => setState(() => drafts['sessionId'] = v))),
      if (current != null) ...[
        Text(
            'Session context: ${current['source']?['role']?['title'] ?? 'Reviewed role'}'),
        for (final e in current['source']?['evidence'] ?? [])
          Text(
              'Selected evidence at start: ${e['title']} · ${e['status']} (${e['kind']})'),
        const SizedBox(height: 12),
        Builder(builder: (_) {
          final seconds = DateTime.parse(current['expires_at'])
              .difference(DateTime.now().toUtc().add(offset))
              .inSeconds;
          return Text(
              current['status'] == 'completed'
                  ? 'Practice completed'
                  : seconds <= 0
                      ? 'Practice time elapsed · answers remain editable for reflection'
                      : 'Practice time left ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleLarge);
        }),
        for (final q in current['questions'])
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q['skill'],
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(q['prompt']),
                    TextFormField(
                        key: ValueKey(
                            'answer-$sessionId-${q['id']}-${current['revision']}'),
                        initialValue: answers['answers'][q['id']] ?? '',
                        maxLines: 5,
                        maxLength: 4000,
                        readOnly: working || current['status'] == 'completed',
                        decoration: InputDecoration(
                            labelText: 'Practice answer ${q['id']}'),
                        onChanged: (v) => answers['answers'][q['id']] = v),
                    for (final item in [
                      'situation',
                      'tradeoff',
                      'outcome',
                      'evidence'
                    ])
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Self-review: $item'),
                          value: answers['review'][q['id']]?[item] == true,
                          onChanged: working || current['status'] == 'completed'
                              ? null
                              : (v) => setState(() {
                                    answers['review']
                                        [q['id']] ??= <String, dynamic>{};
                                    answers['review'][q['id']][item] = v;
                                  })),
                  ])),
        if (current['status'] != 'completed')
          Wrap(spacing: 8, children: [
            FilledButton(
                onPressed: working ? null : () => savePractice(),
                child: const Text('Save practice answers')),
            OutlinedButton(
                onPressed: working ? null : () => savePractice(finish: true),
                child: const Text('Complete practice'))
          ]),
        if ((current['feedback'] as Map).isNotEmpty) ...[
          Text(current['feedback']['scope']),
          for (final feedback in current['feedback']['items'])
            Text(
                'Question ${feedback['question_id']} · ${feedback['word_count']} words · numeric detail ${feedback['has_numeric_detail']}\n${(feedback['prompts'] as List).join('\n')}'),
        ],
        const Text(
            'Self-review is your reflection, not external grading. Save before reloading; unsaved answers survive in-app navigation only.'),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return LiquidGlass(
        opaque: c.reducedTransparency,
        reducedMotion: c.reducedMotion,
        highContrast: c.highContrast,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Evidence & interview atelier',
              style: Theme.of(context).textTheme.headlineSmall),
          Wrap(spacing: 8, children: [
            TextButton(
                onPressed: () => setState(() => practice = false),
                child: const Text('Evidence comparison')),
            TextButton(
                onPressed: () => setState(() => practice = true),
                child: const Text('Interview practice')),
            TextButton(
                onPressed: working ? null : () => load(),
                child: const Text('Refresh workbench'))
          ]),
          if (loading || working) const LinearProgressIndicator(),
          if (error != null)
            Text(error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (!loading) practice ? practiceRoom() : comparisonRoom(),
        ]));
  }
}

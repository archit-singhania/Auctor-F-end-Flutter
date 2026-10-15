import 'dart:convert';
import 'package:flutter/material.dart';
import 'controller.dart';
import 'liquid_glass.dart';

class CareerStory extends StatefulWidget {
  const CareerStory({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<CareerStory> createState() => _CareerStoryState();
}

class _CareerStoryState extends State<CareerStory> {
  Map<String, dynamic> get draft => widget.controller.careerDraft ??=
      jsonDecode(jsonEncode(widget.controller.workspace?['career_story'] ??
          {'revision': 0, 'milestones': []}));
  List get items => draft['milestones'];
  String? error;
  void change(VoidCallback action) => setState(action);

  Future<void> edit([int? index]) async {
    final old = index == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(items[index]);
    final values = <String, String>{
      'Title': old['title'] ?? '',
      'Date (YYYY-MM-DD)':
          old['date'] ?? DateTime.now().toIso8601String().substring(0, 10),
      'Narrative and outcomes': old['narrative'] ?? '',
      'Milestone annotation': old['annotation'] ?? '',
    };
    String kind = old['kind'] ?? 'project';
    bool visible = old['visible'] ?? false;
    final links = Set<String>.from(old['evidence_ids'] ?? []);
    final form = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
        context: context,
        animationStyle:
            widget.controller.reducedMotion ? AnimationStyle.noAnimation : null,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, update) => AlertDialog(
                  title: Text(index == null
                      ? 'Add career milestone'
                      : 'Edit career milestone'),
                  content: SizedBox(
                      width: 520,
                      child: SingleChildScrollView(
                          child: Form(
                              key: form,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (final field in values.entries)
                                      TextFormField(
                                          initialValue: field.value,
                                          decoration: InputDecoration(
                                              labelText: field.key),
                                          maxLength: field.key == 'Title'
                                              ? 160
                                              : field.key ==
                                                      'Milestone annotation'
                                                  ? 500
                                                  : field.key ==
                                                          'Date (YYYY-MM-DD)'
                                                      ? 10
                                                      : 4000,
                                          maxLines: field.key ==
                                                  'Narrative and outcomes'
                                              ? 4
                                              : 1,
                                          onChanged: (v) =>
                                              values[field.key] = v,
                                          validator: (v) {
                                            if (field.key == 'Title' &&
                                                (v ?? '').trim().isEmpty) {
                                              return 'Enter a title';
                                            }
                                            if (field.key ==
                                                'Date (YYYY-MM-DD)') {
                                              final date =
                                                  DateTime.tryParse(v ?? '');
                                              if (date == null ||
                                                  date
                                                          .toIso8601String()
                                                          .substring(0, 10) !=
                                                      v) {
                                                return 'Enter a valid calendar date';
                                              }
                                            }
                                            return null;
                                          }),
                                    DropdownButtonFormField<String>(
                                        initialValue: kind,
                                        decoration: const InputDecoration(
                                            labelText: 'Milestone type'),
                                        items: [
                                          'project',
                                          'experience',
                                          'outcome'
                                        ]
                                            .map((v) => DropdownMenuItem(
                                                value: v, child: Text(v)))
                                            .toList(),
                                        onChanged: (v) => kind = v!),
                                    SwitchListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text(
                                            'Include in public story'),
                                        subtitle: const Text(
                                            'Narrative remains candidate-written, even with verified evidence.'),
                                        value: visible,
                                        onChanged: (v) =>
                                            update(() => visible = v)),
                                    const Text(
                                        'Link your evidence. Private or unverified records will not appear as public evidence links.'),
                                    for (final e
                                        in widget.controller.list('evidence'))
                                      CheckboxListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(e['title']),
                                          subtitle: Text(
                                              '${e['kind']} · ${e['status']}'),
                                          value: links.contains(e['id']),
                                          onChanged: (v) => update(() {
                                                if (v == true) {
                                                  links.add(e['id']);
                                                } else {
                                                  links.remove(e['id']);
                                                }
                                              })),
                                    for (final id in List<String>.from(links)
                                        .where((id) => !widget.controller
                                            .list('evidence')
                                            .any((e) => e['id'] == id)))
                                      CheckboxListTile(
                                          title: const Text(
                                              'Unavailable evidence · unlink to save'),
                                          value: true,
                                          onChanged: (_) =>
                                              update(() => links.remove(id))),
                                    if (widget.controller
                                        .list('evidence')
                                        .isEmpty)
                                      const Text(
                                          'No evidence yet. You can save a private narrative and attach evidence later.'),
                                  ])))),
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
                        child: const Text('Keep milestone'))
                  ],
                )));
    if (accepted != true || !mounted) return;
    change(() {
      final next = {
        'id': old['id'] ?? 'milestone-${DateTime.now().microsecondsSinceEpoch}',
        'title': values['Title']!.trim(),
        'date': values['Date (YYYY-MM-DD)'],
        'narrative': values['Narrative and outcomes'],
        'annotation': values['Milestone annotation'],
        'kind': kind,
        'visible': visible,
        'evidence_ids': links.toList()
      };
      if (index == null) {
        items.add(next);
      } else {
        items[index] = next;
      }
    });
  }

  Future<void> reload() async {
    final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Reload saved career story?'),
                content: const Text(
                    'This replaces the current story draft with the server version. Keep editing to retain your draft.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Keep editing')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reload saved story'))
                ]));
    if (accepted != true || !mounted) return;
    final c = widget.controller;
    await c.run(() async {
      final saved =
          Map<String, dynamic>.from(await c.api.call('/career-story'));
      c.workspace!['career_story'] = saved;
      c.careerDraft = jsonDecode(jsonEncode(saved));
    });
    if (mounted) setState(() => error = c.error);
  }

  Future<void> save() async {
    final c = widget.controller;
    await c.run(() async {
      final result = Map<String, dynamic>.from(
          await c.api.call('/career-story', method: 'PUT', data: draft));
      c.workspace!['career_story'] = result;
      c.careerDraft = jsonDecode(jsonEncode(result));
    });
    if (mounted) setState(() => error = c.error);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final dirty = !sameWorkspaceValue(draft,
        c.workspace?['career_story'] ?? {'revision': 0, 'milestones': []});
    return LiquidGlass(
        reducedMotion: c.reducedMotion,
        opaque: c.reducedTransparency,
        highContrast: c.highContrast,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your career, in context',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
              'Connect projects, experience and outcomes to their evidence. Dates provide context; the saved sequence controls the story. Your narrative never changes your verified score.'),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(
                onPressed: c.busy ? null : () => edit(),
                icon: const Icon(Icons.add),
                label: const Text('Add milestone')),
            TextButton(
                onPressed: c.busy
                    ? null
                    : () => change(() =>
                        items.sort((a, b) => a['date'].compareTo(b['date']))),
                child: const Text('Order by date')),
            FilledButton(
                onPressed: c.busy || !dirty ? null : save,
                child: Text(c.busy ? 'Saving story…' : 'Save story')),
            Text(dirty
                ? 'Unsaved story · retained during navigation'
                : 'Story saved · revision ${draft['revision']}'),
          ]),
          if (error != null)
            Text(error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (items.isEmpty)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                    'No milestones yet. Start with a project, an experience or a meaningful outcome.')),
          for (final entry in items.asMap().entries)
            Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${entry.value['date']} · ${entry.value['kind']} · ${entry.value['visible'] ? 'Public' : 'Private'}',
                          style: Theme.of(context).textTheme.labelMedium),
                      Text(entry.value['title'],
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(entry.value['narrative']),
                      if (entry.value['annotation'].isNotEmpty)
                        Text(entry.value['annotation'],
                            style: Theme.of(context).textTheme.bodySmall),
                      Wrap(spacing: 8, children: [
                        for (final id in entry.value['evidence_ids'])
                          ActionChip(
                              label: Text(c
                                      .list('evidence')
                                      .where((e) => e['id'] == id)
                                      .firstOrNull?['title'] ??
                                  'Unavailable evidence'),
                              onPressed: () {
                                final e = c
                                    .list('evidence')
                                    .where((e) => e['id'] == id)
                                    .firstOrNull;
                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                            title: Text(e?['title'] ??
                                                'Unavailable evidence'),
                                            content: Text(e == null
                                                ? 'This source was removed. Unlink it before saving.'
                                                : '${e['kind']} · ${e['status']}\n${e['url']}\n${jsonEncode(e['detail'])}'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                  child: const Text('Close'))
                                            ]));
                              })
                      ]),
                      Wrap(spacing: 8, children: [
                        TextButton(
                            onPressed: c.busy ? null : () => edit(entry.key),
                            child: const Text('Edit milestone')),
                        IconButton(
                            tooltip: 'Move milestone earlier',
                            onPressed: c.busy || entry.key == 0
                                ? null
                                : () => change(() {
                                      final item = items.removeAt(entry.key);
                                      items.insert(entry.key - 1, item);
                                    }),
                            icon: const Icon(Icons.arrow_upward)),
                        IconButton(
                            tooltip: 'Move milestone later',
                            onPressed: c.busy || entry.key == items.length - 1
                                ? null
                                : () => change(() {
                                      final item = items.removeAt(entry.key);
                                      items.insert(entry.key + 1, item);
                                    }),
                            icon: const Icon(Icons.arrow_downward)),
                        TextButton(
                            onPressed: c.busy
                                ? null
                                : () => change(() => items.removeAt(entry.key)),
                            child: const Text('Remove milestone')),
                      ]),
                      const Divider(),
                    ])),
        ]));
  }
}

class PublicCareerStory extends StatelessWidget {
  const PublicCareerStory({super.key, required this.story});
  final Map<String, dynamic> story;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ((story['milestones'] as List? ?? []).isNotEmpty)
          Text('Career story',
              style: Theme.of(context).textTheme.headlineSmall),
        for (final m in story['milestones'] ?? [])
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${m['date']} · ${m['kind']}'),
                    Text(m['title'],
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(m['narrative']),
                    Text(m['annotation']),
                    Text(m['narrative_status'],
                        style: Theme.of(context).textTheme.bodySmall),
                    for (final e in m['evidence'])
                      Text(
                          'Linked evidence: ${e['title']} · ${e['status']} (${e['kind']})'),
                  ])),
      ]);
}

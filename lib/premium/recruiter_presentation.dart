import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controller.dart';
import 'liquid_glass.dart';
import 'save_stub.dart'
    if (dart.library.io) 'save_io.dart'
    if (dart.library.js_interop) 'save_web.dart';

class RecruiterPresentationEditor extends StatefulWidget {
  const RecruiterPresentationEditor({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<RecruiterPresentationEditor> createState() =>
      _RecruiterPresentationEditorState();
}

class _RecruiterPresentationEditorState
    extends State<RecruiterPresentationEditor> {
  Map<String, dynamic>? saved, preview;
  List runs = [];
  bool loading = true, working = false;
  String? error, link;
  int days = 7;
  Map<String, dynamic> get draft => widget.controller.presentationDraft!;
  bool get dirty => !sameWorkspaceValue(draft, saved);
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final c = widget.controller;
      final values = await Future.wait(
          [c.api.call('/presentations'), c.api.call('/role-fit')]);
      if (!mounted) return;
      setState(() {
        saved = Map<String, dynamic>.from(values[0]);
        c.presentationDraft ??= jsonDecode(jsonEncode(saved));
        runs = values[1]['runs'];
        loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e.toString();
        });
      }
    }
  }

  Future<void> perform(Future<void> Function() action) async {
    setState(() {
      working = true;
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
        setState(() => working = false);
      }
    }
  }

  void select(String field, String value, bool selected) {
    setState(() {
      final list = draft[field] as List;
      if (selected) {
        if (!list.contains(value)) {
          list.add(value);
        }
      } else {
        list.remove(value);
      }
      preview = null;
    });
  }

  Future<void> save() => perform(() async {
        final result = Map<String, dynamic>.from(await widget.controller.api
            .call('/presentations', method: 'PUT', data: draft));
        if (mounted) {
          setState(() {
            saved = result;
            widget.controller.presentationDraft =
                jsonDecode(jsonEncode(result));
            preview = null;
          });
        }
      });
  Future<void> review() => perform(() async {
        final result = Map<String, dynamic>.from(
            await widget.controller.api.call('/presentations/preview'));
        if (!mounted) return;
        setState(() => preview = result);
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RecruiterWalkthrough(data: result['data'])));
      });
  Future<void> publish() async {
    final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Share the reviewed presentation?'),
                content: Text(
                    'Create a public link expiring in $days days. Only reviewed public fields are included. Private notes, contact data and source files are excluded. Revocation remains available in Private sharing.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Create expiring link'))
                ]));
    if (accepted != true || !mounted) return;
    await perform(() async {
      final result = await widget.controller.api
          .call('/presentations/shares', method: 'POST', data: {
        'revision': preview!['revision'],
        'preview_sha256': preview!['preview_sha256'],
        'confirm_public': true,
        'expires_days': days
      });
      if (mounted) {
        setState(() => link = result['url']);
      }
      await widget.controller.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return LiquidGlass(
        opaque: c.reducedTransparency,
        reducedMotion: c.reducedMotion,
        highContrast: c.highContrast,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Recruiter presentation',
              style: Theme.of(context).textTheme.headlineSmall),
          const Text(
              'Curate a focused walkthrough. Public narrative stays labelled, evidence eligibility is rechecked, and private notes never enter the link or PDF.'),
          if (loading || working) const LinearProgressIndicator(),
          if (error != null)
            Text(error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (saved == null && !loading)
            TextButton(
                onPressed: load, child: const Text('Retry presentation')),
          if (saved != null) ...[
            for (final field in {
              'title': 'Presentation title',
              'introduction': 'Public introduction',
              'private_notes': 'Private speaker notes'
            }.entries)
              TextFormField(
                  key: ValueKey(
                      'presentation-${field.key}-${draft['revision']}'),
                  initialValue: draft[field.key],
                  maxLength: field.key == 'title'
                      ? 160
                      : field.key == 'introduction'
                          ? 2000
                          : 4000,
                  maxLines: field.key == 'title' ? 1 : 3,
                  readOnly: working,
                  decoration: InputDecoration(labelText: field.value),
                  onChanged: (v) => setState(() {
                        draft[field.key] = v;
                        preview = null;
                      })),
            const Text(
                'Choose public milestones (enable their visibility in Career story first):'),
            for (final m in c.workspace?['career_story']?['milestones'] ?? [])
              if (m['visible'] == true)
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(m['title']),
                    value: (draft['milestone_ids'] as List).contains(m['id']),
                    onChanged: working
                        ? null
                        : (v) => select('milestone_ids', m['id'], v == true)),
            const Text(
                'Choose projects. Their descriptions remain candidate-written.'),
            for (final p in c.cv['projects'])
              CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p['name']),
                  value: (draft['project_names'] as List).contains(p['name']),
                  onChanged: working
                      ? null
                      : (v) => select('project_names', p['name'], v == true)),
            const Text(
                'Choose evidence shortcuts. Only currently verified eligible sources are published.'),
            for (final e in c.list('evidence'))
              CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e['title']),
                  subtitle: Text(e['status']),
                  value: (draft['evidence_ids'] as List).contains(e['id']),
                  onChanged: working
                      ? null
                      : (v) => select('evidence_ids', e['id'], v == true)),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: DropdownButtonFormField<String>(
                    initialValue: draft['role_run_id'] ?? '',
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText:
                            'Role-fit snapshot (public selected-evidence explanations)'),
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('Do not include role fit')),
                      for (final r in runs)
                        DropdownMenuItem<String>(
                            value: r['id'], child: Text('Match ${r['id']}'))
                    ],
                    onChanged: working
                        ? null
                        : (v) => setState(() {
                              draft['role_run_id'] = v == '' ? null : v;
                              preview = null;
                            }))),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton(
                  onPressed: working || !dirty ? null : save,
                  child: const Text('Save presentation')),
              OutlinedButton(
                  onPressed: working || dirty ? null : review,
                  child: const Text('Review public walkthrough'))
            ]),
            if (dirty)
              const Text(
                  'Unsaved presentation · retained during navigation. Save before reviewing.'),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: DropdownButtonFormField<int>(
                    initialValue: days,
                    decoration:
                        const InputDecoration(labelText: 'Link expiration'),
                    items: [1, 7, 30, 90]
                        .map((v) =>
                            DropdownMenuItem(value: v, child: Text('$v days')))
                        .toList(),
                    onChanged:
                        working ? null : (v) => setState(() => days = v!))),
            FilledButton(
                onPressed: working || dirty || preview == null ? null : publish,
                child: const Text('Share reviewed walkthrough')),
            if (link != null) ...[
              SelectableText(link!),
              TextButton(
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: link!)),
                  child: const Text('Copy presentation link'))
            ],
            const Text(
                'Links are scoped to the presentation. Revoke them in Private sharing. Existing private draft edits are not a disk backup; save before reloading.'),
          ],
        ]));
  }
}

class RecruiterPresentationPage extends StatefulWidget {
  const RecruiterPresentationPage({super.key, required this.token});
  final String token;
  @override
  State<RecruiterPresentationPage> createState() =>
      _RecruiterPresentationPageState();
}

class _RecruiterPresentationPageState extends State<RecruiterPresentationPage> {
  final api = PlatformApi();
  late Future<dynamic> data =
      api.call('/presentations/shared/${widget.token}', authenticated: false);
  @override
  void dispose() {
    api.client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: data,
      builder: (ctx, s) {
        if (s.hasData) {
          return RecruiterWalkthrough(
              data: Map<String, dynamic>.from(s.data as Map),
              download: () async {
                await saveReport(
                    'auctor-interview-brief.pdf',
                    await api.bytes(
                        '/presentations/shared/${widget.token}/brief.pdf'));
              });
        }
        return Scaffold(
            body: Center(
                child: s.hasError
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text(
                            'Presentation expired, revoked or unavailable.'),
                        TextButton(
                            onPressed: () => setState(() => data = api.call(
                                '/presentations/shared/${widget.token}',
                                authenticated: false)),
                            child: const Text('Retry presentation'))
                      ])
                    : const CircularProgressIndicator()));
      });
}

class RecruiterWalkthrough extends StatefulWidget {
  const RecruiterWalkthrough({super.key, required this.data, this.download});
  final Map<String, dynamic> data;
  final Future<void> Function()? download;
  @override
  State<RecruiterWalkthrough> createState() => _RecruiterWalkthroughState();
}

class _RecruiterWalkthroughState extends State<RecruiterWalkthrough> {
  int index = 0;
  bool exporting = false;
  String? error;
  List<Map<String, dynamic>> get slides => [
        {
          'title': widget.data['title'],
          'body':
              '${widget.data['profile']['display_name']} · @${widget.data['profile']['handle']}\n\n${widget.data['introduction']}\n\n${widget.data['scope']}'
        },
        for (final m in widget.data['career_story']['milestones'])
          {
            'title': m['title'],
            'body':
                '${m['date']}\n\n${m['narrative']}\n\n${m['narrative_status'] ?? 'Candidate-written narrative'}',
            'evidence': m['evidence']
          },
        for (final p in widget.data['projects'])
          {
            'title': p['name'],
            'body':
                '${p['description']}\n\nCandidate-written project description'
          },
        if (widget.data['role_fit'] != null)
          {
            'title': 'Role-fit explanations',
            'body':
                '${widget.data['role_fit']['scope']}\n\n${(widget.data['role_fit']['contributions'] as List).map((r) => "${r['skill']} · ${r['status']}").join('\n')}'
          },
        {
          'title': 'Selected evidence',
          'body':
              'Inspect the verification scope before drawing a conclusion. Private source files are not included.',
          'evidence': widget.data['evidence']
        },
      ];
  void step(int delta) =>
      setState(() => index = (index + delta).clamp(0, slides.length - 1));
  Future<void> export() async {
    setState(() {
      exporting = true;
      error = null;
    });
    try {
      await widget.download!();
    } catch (e) {
      if (mounted) {
        setState(() => error =
            'Export unavailable. The link may have expired or been revoked.');
      }
    } finally {
      if (mounted) {
        setState(() => exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = slides;
    final s = entries[index];
    return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => step(1),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => step(-1),
          const SingleActivator(LogicalKeyboardKey.home): () =>
              setState(() => index = 0),
          const SingleActivator(LogicalKeyboardKey.end): () =>
              setState(() => index = entries.length - 1)
        },
        child: Focus(
            autofocus: true,
            child: Scaffold(
                appBar: AppBar(
                    title: const Text('Auctor · Evidence walkthrough'),
                    actions: [
                      if (widget.download != null)
                        TextButton(
                            onPressed: exporting ? null : export,
                            child: Text(exporting
                                ? 'Exporting…'
                                : 'Interview brief PDF'))
                    ]),
                body: SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(children: [
                          Expanded(
                              child: AnimatedSwitcher(
                                  duration:
                                      MediaQuery.disableAnimationsOf(context)
                                          ? Duration.zero
                                          : const Duration(milliseconds: 220),
                                  child: SingleChildScrollView(
                                      key: ValueKey(index),
                                      child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 900),
                                          child: LiquidGlass(
                                              opaque: true,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(s['title'],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineLarge),
                                                    const SizedBox(height: 24),
                                                    SelectableText(s['body'],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge),
                                                    for (final e
                                                        in s['evidence'] ?? [])
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 12),
                                                          child: ActionChip(
                                                              label: Text(
                                                                  e['title']),
                                                              onPressed: () =>
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder: (ctx) =>
                                                                          AlertDialog(
                                                                              title: Text(e['title']),
                                                                              content: SelectableText('${e['kind']} · ${e['status']}\n${e['url'] ?? ''}\nVerification status does not guarantee the truth of the narrative.'),
                                                                              actions: [
                                                                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close evidence'))
                                                                              ]))))
                                                  ])))))),
                          if (error != null) Text(error!),
                          const SizedBox(height: 16),
                          Wrap(
                              spacing: 16,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                OutlinedButton(
                                    onPressed:
                                        index == 0 ? null : () => step(-1),
                                    child: const Text('Previous section')),
                                Text(
                                    'Section ${index + 1} of ${entries.length}'),
                                FilledButton(
                                    onPressed: index == entries.length - 1
                                        ? null
                                        : () => step(1),
                                    child: const Text('Next section'))
                              ]),
                          const Text('Keyboard: left/right arrows · Home/End'),
                        ]))))));
  }
}

import 'package:flutter/material.dart';
import 'controller.dart';
import 'app.dart' show Surface, download;

class CaseStudyBuilder extends StatefulWidget {
  const CaseStudyBuilder({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<CaseStudyBuilder> createState() => _CaseStudyBuilderState();
}

class _CaseStudyBuilderState extends State<CaseStudyBuilder> {
  bool busy = false;
  String? error;
  List evidence = [], shares = [];
  Map<String, dynamic>? get draft => widget.controller.caseStudyDraft;
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
    final value = await widget.controller.api.call('/case-studies');
    final sources = await widget.controller.api.call('/evidence-collection');
    final publications =
        await widget.controller.api.call('/case-studies/shares');
    if (mounted) {
      setState(() {
        widget.controller.caseStudyDraft ??= Map<String, dynamic>.from(value);
        evidence = sources['available_evidence'];
        shares = publications;
      });
    }
  }

  Future<void> preview() async {
    final result = await widget.controller.api.call('/case-studies/preview');
    if (!mounted) return;
    final data = result['data'];
    final publish = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(data['title']),
              content: SizedBox(
                  width: 640,
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(data['scope']),
                        for (final section in data['sections']) ...[
                          Text(section['kind'],
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(section['text']),
                          for (final source in section['evidence'])
                            Text(
                                '${source['title']} · reviewed revision ${source['source_revision']}'),
                          if ((section['evidence'] as List).isEmpty)
                            const Text('No current reviewed source displayed.'),
                        ],
                        const Text(
                            'Publishing creates a public link that expires in seven days. Review the narrative for private information before confirming.'),
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Close preview')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirm public publication'))
              ],
            ));
    if (publish != true) return;
    await widget.controller.api
        .call('/case-studies/shares', method: 'POST', data: {
      'revision': data['revision'],
      'sha256': result['sha256'],
      'confirm_public': true,
      'expires_days': 7
    });
    await load();
  }

  @override
  Widget build(BuildContext context) => Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Portfolio case study',
            style: Theme.of(context).textTheme.titleLarge),
        const Text(
            'Develop your story, link its sources, and publish an independent snapshot. Narrative remains candidate-written.'),
        OutlinedButton(
            onPressed: busy ? null : () => run(load),
            child: const Text('Load case study')),
        if (busy) const LinearProgressIndicator(),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        if (draft != null) ...[
          TextFormField(
              initialValue: draft!['title'],
              enabled: !busy,
              decoration: const InputDecoration(labelText: 'Case study title'),
              onChanged: (v) => draft!['title'] = v),
          for (final section in draft!['sections'])
            ExpansionTile(
                key: ValueKey(section['kind']),
                title: Text(section['kind']),
                children: [
                  TextFormField(
                      initialValue: section['text'],
                      enabled: !busy,
                      minLines: 3,
                      maxLines: 8,
                      decoration: InputDecoration(
                          labelText: '${section['kind']} narrative'),
                      onChanged: (v) => section['text'] = v),
                  for (final source in evidence)
                    CheckboxListTile(
                        title: Text(source['title']),
                        subtitle: Text(
                            '${source['status']} · ${source['eligibility_state']}'),
                        value: (section['evidence_ids'] as List)
                            .contains(source['id']),
                        onChanged: busy
                            ? null
                            : (checked) => setState(() {
                                  final ids = section['evidence_ids'] as List;
                                  checked == true
                                      ? ids.add(source['id'])
                                      : ids.remove(source['id']);
                                })),
                ]),
          Wrap(spacing: 8, children: [
            FilledButton(
                onPressed: busy
                    ? null
                    : () => run(() async {
                          final value = await widget.controller.api.call(
                              '/case-studies',
                              method: 'PUT',
                              data: draft);
                          widget.controller.caseStudyDraft =
                              Map<String, dynamic>.from(value);
                        }),
                child: const Text('Save case-study draft')),
            OutlinedButton(
                onPressed:
                    busy || draft!['revision'] == 0 ? null : () => run(preview),
                child: const Text('Preview saved publication')),
          ]),
          Text(
              'Saved revision ${draft!['revision']}. Preview uses saved content. Unsaved edits remain private.'),
        ],
        for (final share in shares)
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(share['revoked'] == true
                            ? 'Revoked publication'
                            : 'Publication expires ${share['expires_at']}'),
                        if (share['revoked'] != true) ...[
                          SelectableText(
                              '${PlatformApi.base}/api/case-studies/shared/${share['id']}'),
                          Wrap(spacing: 8, children: [
                            TextButton(
                                onPressed: busy
                                    ? null
                                    : () => run(() => download(
                                        widget.controller.api,
                                        '/case-studies/shared/${share['id']}',
                                        'case-study.html')),
                                child: const Text('Export HTML')),
                            TextButton(
                                onPressed: busy
                                    ? null
                                    : () => run(() => download(
                                        widget.controller.api,
                                        '/case-studies/shared/${share['id']}/report.pdf',
                                        'case-study.pdf')),
                                child: const Text('Export PDF')),
                            TextButton(
                                onPressed: busy
                                    ? null
                                    : () => run(() async {
                                          await widget.controller.api.call(
                                              '/shares/${share['id']}',
                                              method: 'DELETE');
                                          await load();
                                        }),
                                child: const Text('Revoke publication')),
                          ]),
                        ],
                      ]))),
      ]));
}

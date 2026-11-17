import 'dart:convert';
import 'package:flutter/material.dart';
import 'controller.dart';
import 'app.dart' show Surface;

class AssessmentQuality extends StatefulWidget {
  const AssessmentQuality({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<AssessmentQuality> createState() => _AssessmentQualityState();
}

class _AssessmentQualityState extends State<AssessmentQuality> {
  final questions = TextEditingController(), reason = TextEditingController();
  String badge = 'docker';
  Map<String, dynamic>? catalog, report;
  bool busy = false;
  String? error;
  @override
  void dispose() {
    questions.dispose();
    reason.dispose();
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
    final value =
        await widget.controller.api.call('/assessment-quality/$badge/catalog');
    final analytics =
        await widget.controller.api.call('/assessment-quality/$badge/report');
    if (mounted) {
      setState(() {
        catalog = Map<String, dynamic>.from(value);
        report = Map<String, dynamic>.from(analytics);
        questions.text =
            const JsonEncoder.withIndent('  ').convert(value['questions']);
      });
    }
  }

  Future<void> publish() async {
    final parsed = jsonDecode(questions.text);
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Publish reviewed question version?'),
                content: SizedBox(
                    width: 650,
                    child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text(
                              'This changes future attempts only. Retiring any question pauses new attempts until the five-question assessment is restored. Review every prompt, option and zero-based answer index.'),
                          SelectableText(const JsonEncoder.withIndent('  ')
                              .convert(parsed)),
                          Text('Reason: ${reason.text}')
                        ]))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirm publication'))
                ]));
    if (accepted != true) return;
    await widget.controller.api
        .call('/assessment-quality/$badge/versions', method: 'POST', data: {
      'version': catalog!['version'],
      'questions': parsed,
      'reason': reason.text,
      'confirm_publication': true
    });
    reason.clear();
    await load();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.profile['role'] != 'reviewer') {
      return const SizedBox.shrink();
    }
    return Surface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Assessment quality', style: Theme.of(context).textTheme.titleLarge),
      const Text(
          'Reviewer-only question governance. Cohort statistics guide human review and never change past grades.'),
      DropdownButton<String>(
          value: badge,
          isExpanded: true,
          items: [
            for (final id in [
              'docker',
              'jwt-auth',
              'rest-api',
              'postgres',
              'redis'
            ])
              DropdownMenuItem(value: id, child: Text(id))
          ],
          onChanged: busy || catalog != null
              ? null
              : (value) => setState(() => badge = value!)),
      OutlinedButton(
          onPressed: busy || catalog != null ? null : () => run(load),
          child: const Text('Load assessment quality')),
      if (busy) const LinearProgressIndicator(),
      if (error != null) Semantics(liveRegion: true, child: Text(error!)),
      if (report != null) ...[
        Semantics(
            liveRegion: true,
            child: Text(report!['suppressed'] == true
                ? 'Statistics suppressed — fewer than 20 eligible completed attempts'
                : 'Cohort quality report')),
        Text('Eligible completed attempts: ${report!['eligible_completed']}'),
        Text(report!['scope']),
        if (report!['unstable'] == true)
          const Text(
              'Small cohort: measurements are unstable (fewer than 100 completions).'),
        ExpansionTile(
            title: const Text('Inspect reproducible metrics and input hash'),
            children: [
              SelectableText(const JsonEncoder.withIndent('  ').convert(report))
            ]),
      ],
      if (catalog != null) ...[
        Text('Saved assessment version ${catalog!['version']}'),
        TextField(
            controller: questions,
            enabled: !busy,
            minLines: 6,
            maxLines: 14,
            decoration: const InputDecoration(
                labelText: 'Question definitions (JSON; answer indices 0–3)')),
        TextField(
            controller: reason,
            enabled: !busy,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Review rationale (at least 10 characters)')),
        OutlinedButton(
            onPressed: busy ? null : () => run(publish),
            child: const Text('Review publication preview')),
        TextButton(
            onPressed: busy
                ? null
                : () async {
                    final discard = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                                title: const Text(
                                    'Close and discard unsaved question edits?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Keep editing')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Close editor'))
                                ]));
                    if (discard == true && mounted) {
                      setState(() {
                        catalog = null;
                        report = null;
                      });
                    }
                  },
            child: const Text('Choose another assessment')),
        for (final entry in catalog!['history'])
          ListTile(
              title: Text(
                  'Version ${entry['version']} · reviewer ${entry['reviewer_id']}'),
              subtitle: Text('${entry['reason']}\n${entry['created_at']}')),
      ],
    ]));
  }
}

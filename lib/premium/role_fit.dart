import 'dart:convert';
import 'package:flutter/material.dart';
import 'controller.dart';
import 'liquid_glass.dart';

class RoleFitWorkspace extends StatefulWidget {
  const RoleFitWorkspace({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<RoleFitWorkspace> createState() => _RoleFitWorkspaceState();
}

class _RoleFitWorkspaceState extends State<RoleFitWorkspace> {
  Map<String, dynamic>? saved;
  Map<String, dynamic>? result;
  List runs = [];
  bool loading = true, working = false;
  String? error;
  Map<String, dynamic> get draft => widget.controller.roleDraft!;
  List get requirements => draft['requirements'];
  bool get dirty => !sameWorkspaceValue(draft, saved);
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({bool replaceDraft = false}) async {
    try {
      final response = await widget.controller.api.call('/role-fit');
      if (!mounted) return;
      setState(() {
        saved = Map<String, dynamic>.from(response['document']);
        if (replaceDraft || widget.controller.roleDraft == null) {
          widget.controller.roleDraft = jsonDecode(jsonEncode(saved));
        }
        runs = response['runs'];
        result = runs.isEmpty
            ? null
            : Map<String, dynamic>.from(runs.first['result']);
        loading = false;
        error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          loading = false;
        });
      }
    }
  }

  void edit(VoidCallback action) => setState(() {
        action();
        draft['reviewed'] = false;
      });
  Future<void> request({bool match = false}) async {
    setState(() {
      working = true;
      error = null;
    });
    try {
      if (match) {
        await widget.controller.api.call('/role-fit/runs', method: 'POST');
        await load();
      } else {
        final response = Map<String, dynamic>.from(await widget.controller.api
            .call('/role-fit', method: 'PUT', data: draft));
        if (mounted) {
          setState(() {
            saved = response;
            widget.controller.roleDraft = jsonDecode(jsonEncode(response));
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> addRequirement() async {
    String skill = '';
    String priority = 'required';
    String weight = '';
    final form = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Add reviewed requirement'),
                content: Form(
                    key: form,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextFormField(
                          decoration: const InputDecoration(labelText: 'Skill'),
                          maxLength: 100,
                          onChanged: (v) => skill = v,
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? 'Enter a skill'
                              : null),
                      DropdownButtonFormField<String>(
                          initialValue: priority,
                          decoration:
                              const InputDecoration(labelText: 'Importance'),
                          items: ['required', 'preferred']
                              .map((v) =>
                                  DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (v) => priority = v!),
                      TextFormField(
                          initialValue: weight,
                          decoration: const InputDecoration(
                              labelText:
                                  'Weight (optional: required 2, preferred 1)'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => weight = v,
                          validator: (v) {
                            if ((v ?? '').trim().isEmpty) {
                              return null;
                            }
                            final n = double.tryParse(v ?? '');
                            return n == null || !n.isFinite || n <= 0 || n > 10
                                ? 'Enter a weight greater than 0 and at most 10'
                                : null;
                          }),
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
                      child: const Text('Add requirement'))
                ]));
    if (accepted == true && mounted) {
      edit(() => requirements.add({
            'skill': skill.trim(),
            'priority': priority,
            'weight': weight.trim().isEmpty
                ? (priority == 'required' ? 2 : 1)
                : double.parse(weight)
          }));
    }
  }

  void extract() {
    final text = draft['description'].toString();
    final known = {
      'Docker': r'\bdocker\b',
      'PostgreSQL': r'\b(postgres|postgresql)\b',
      'Redis': r'\bredis\b',
      'REST API': r'\brest\b',
      'JWT authentication': r'\bjwt\b'
    };
    edit(() {
      for (final item in known.entries) {
        final lines = text.split('\n').where(
            (line) => RegExp(item.value, caseSensitive: false).hasMatch(line));
        if (lines.isNotEmpty &&
            !requirements.any((r) =>
                r['skill'].toString().toLowerCase() ==
                item.key.toLowerCase())) {
          final preferred =
              RegExp(r'preferred|nice to have|optional', caseSensitive: false)
                  .hasMatch(lines.first);
          requirements.add({
            'skill': item.key,
            'priority': preferred ? 'preferred' : 'required',
            'weight': preferred ? 1 : 2
          });
        }
      }
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
          Text('Role-fit atelier',
              style: Theme.of(context).textTheme.headlineSmall),
          const Text(
              'Evidence coverage for a target role. This is separate from your developer score. Missing evidence means unknown, not inability.'),
          if (loading)
            const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator()),
          if (error != null)
            Text(error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (saved == null && !loading)
            TextButton(
                onPressed: load, child: const Text('Retry role workspace')),
          if (saved != null) ...[
            TextFormField(
                key: ValueKey('role-title-${draft['revision']}'),
                initialValue: draft['title'],
                decoration: const InputDecoration(labelText: 'Target role'),
                maxLength: 160,
                onChanged: (v) => edit(() => draft['title'] = v),
                readOnly: working),
            TextFormField(
                key: ValueKey('role-description-${draft['revision']}'),
                initialValue: draft['description'],
                decoration: const InputDecoration(labelText: 'Job description'),
                maxLines: 5,
                maxLength: 20000,
                onChanged: (v) => edit(() => draft['description'] = v),
                readOnly: working),
            const Text(
                'Local extraction recognizes five implemented skill families. Review its suggestions and manually add other requirements; it cannot interpret every job description.'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton(
                  onPressed: working ? null : extract,
                  child: const Text('Suggest known requirements')),
              OutlinedButton(
                  onPressed: working ? null : addRequirement,
                  child: const Text('Add requirement'))
            ]),
            if (requirements.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                      'No reviewed requirements yet. Add a skill and its importance.')),
            for (final e in requirements.asMap().entries)
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.value['skill']),
                  subtitle: Text(
                      '${e.value['priority']} · weight ${e.value['weight']}'),
                  trailing: IconButton(
                      tooltip: 'Remove requirement ${e.value['skill']}',
                      onPressed: working
                          ? null
                          : () => edit(() => requirements.removeAt(e.key)),
                      icon: const Icon(Icons.close))),
            const Text(
                'To change a requirement or weight, remove it and add the reviewed replacement. Required defaults to 2; preferred defaults to 1 in the matching API.'),
            CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('I reviewed these requirements and weights'),
                value: draft['reviewed'] == true,
                onChanged: working
                    ? null
                    : (v) => setState(() => draft['reviewed'] = v)),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton(
                  onPressed: working || !dirty ? null : () => request(),
                  child: const Text('Save requirements')),
              OutlinedButton(
                  onPressed: working ||
                          dirty ||
                          draft['reviewed'] != true ||
                          requirements.isEmpty
                      ? null
                      : () => request(match: true),
                  child: const Text('Run evidence match')),
              TextButton(
                  onPressed: working
                      ? null
                      : () async {
                          final accepted = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                      title: const Text(
                                          'Discard role draft and reload?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Keep draft')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child:
                                                const Text('Reload saved role'))
                                      ]));
                          if (accepted == true && mounted) {
                            await load(replaceDraft: true);
                          }
                        },
                  child: const Text('Reload role'))
            ]),
            if (working) const LinearProgressIndicator(),
            if (dirty)
              const Text(
                  'Unsaved requirements · retained during navigation. Save before matching.'),
            if (result != null) ...[
              const Divider(height: 32),
              Text('${result!['coverage_percent']}% evidenced coverage',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text(result!['explanation']),
              Text(
                  'Saved snapshot · ${result!['formula_version']} · ${result!['vocabulary_version']}'),
              for (final r in result!['contributions'])
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${r['skill']} · ${r['status']}',
                              style: Theme.of(context).textTheme.titleMedium),
                          Text('${r['earned_weight']} / ${r['weight']} weight'),
                          for (final source in [
                            ...r['sources'],
                            ...r['context']
                          ])
                            ActionChip(
                                label: Text(source['title']),
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                            title: Text(source['title']),
                                            content: Text(
                                                '${source['scope']}\nSource: ${source['kind']} / ${source['id']}\nThis is the evidence snapshot used for this match.'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                  child: const Text(
                                                      'Close source'))
                                            ]))),
                        ])),
              Wrap(spacing: 8, children: [
                for (final run in runs)
                  TextButton(
                      onPressed: () => setState(() =>
                          result = Map<String, dynamic>.from(run['result'])),
                      child: Text(
                          'Snapshot ${run['id'].toString().substring(0, 6)}'))
              ]),
            ],
          ],
        ]));
  }
}

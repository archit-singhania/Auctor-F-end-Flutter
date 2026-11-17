import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'controller.dart';
import 'app.dart' show Surface;

class RecruiterExplorer extends StatefulWidget {
  const RecruiterExplorer({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<RecruiterExplorer> createState() => _RecruiterExplorerState();
}

class _RecruiterExplorerState extends State<RecruiterExplorer> {
  final query = TextEditingController();
  Map<String, dynamic>? preferences;
  List results = [];
  double minimum = 0;
  bool onlySaved = false;
  bool busy = false, compared = false, loaded = false;
  String? error;
  @override
  void dispose() {
    query.dispose();
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

  Future<void> refreshPreferences() async {
    final response = await widget.controller.api.call('/recruiter-exploration');
    if (mounted) {
      setState(() => preferences = Map<String, dynamic>.from(response));
    }
  }

  Future<void> search() async {
    final values = await widget.controller.api.call(
        '/candidates?q=${Uri.encodeQueryComponent(query.text)}&min_score=$minimum');
    await refreshPreferences();
    if (mounted) {
      setState(() {
        results = values;
        loaded = true;
      });
    }
  }

  Future<void> save({List? ids, String? density}) async {
    await widget.controller.api
        .call('/recruiter-exploration', method: 'PUT', data: {
      'revision': preferences!['revision'],
      'candidate_ids': ids ?? preferences!['candidate_ids'],
      'density': density ?? preferences!['density']
    });
    await refreshPreferences();
  }

  bool get compact => preferences?['density'] == 'compact';
  List get selected => preferences?['candidate_ids'] ?? [];
  Widget candidate(Map person, {bool comparison = false}) {
    final id = person['profile']['id'];
    final name = person['profile']['display_name'];
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Surface(
            padding: EdgeInsets.all(compact ? 12 : 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Semantics(
                  header: true,
                  child: Text(name,
                      style: Theme.of(context).textTheme.titleLarge)),
              Text(
                  '@${person['profile']['handle']} · score ${person['score']['total']} / 10'),
              if (!compact || comparison)
                Text('Candidate narrative: ${person['profile']['bio'] ?? ''}'),
              Text('Declared skills: ${(person['skills'] as List).join(', ')}'),
              Text(
                  'Earned assessment badges: ${(person['badges'] as List).isEmpty ? 'None displayed' : (person['badges'] as List).join(', ')}'),
              Text(
                  'Current reviewed evidence: ${(person['evidence'] as List).length}'),
              if ((person['evidence'] as List).isEmpty)
                const Text(
                    'Missing evidence is unknown, not proof of inability.'),
              if (comparison) ...[
                const Text('Score contributions — text equivalent'),
                for (final entry
                    in (person['score']['components'] as Map).entries)
                  Text('${entry.key}: ${entry.value['points']} points'),
                for (final evidence in person['evidence'])
                  ListTile(
                      dense: compact,
                      title: Text(evidence['title']),
                      subtitle: Text(
                          '${evidence['kind']} · reviewed within the source scope')),
              ],
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton(
                    onPressed: busy
                        ? null
                        : () => context
                            .go('/public/${person['profile']['handle']}'),
                    child: Text('Inspect evidence for $name')),
                if (!comparison)
                  OutlinedButton(
                      onPressed: busy ||
                              preferences == null ||
                              (!selected.contains(id) && selected.length >= 3)
                          ? null
                          : () => run(() => save(
                              ids: selected.contains(id)
                                  ? selected.where((v) => v != id).toList()
                                  : [...selected, id])),
                      child: Text(selected.contains(id)
                          ? 'Remove $name from tray'
                          : 'Compare $name')),
                if (!comparison)
                  TextButton(
                      onPressed: busy
                          ? null
                          : () => run(() async {
                                await widget.controller.api.call(
                                    '/candidates/$id/save',
                                    method: person['saved'] == true
                                        ? 'DELETE'
                                        : 'POST');
                                await search();
                              }),
                      child: Text(person['saved'] == true
                          ? 'Unsave $name'
                          : 'Save $name')),
              ]),
            ])));
  }

  @override
  Widget build(BuildContext context) => FocusTraversalGroup(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Recruiter exploration',
            style: Theme.of(context).textTheme.headlineMedium),
        const Text(
            'Search opt-in profiles, compare public evidence and keep a private comparison tray.'),
        Surface(
            child: Column(children: [
          TextField(
              controller: query,
              enabled: !busy,
              onSubmitted: (_) => run(search),
              decoration: const InputDecoration(
                  labelText: 'Search name, handle or declared skill')),
          TextFormField(
              initialValue: '0',
              enabled: !busy,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Minimum score (0–10)'),
              onChanged: (v) {
                minimum = double.tryParse(v) ?? 0;
              }),
          FilterChip(
              label: const Text('Saved candidates only'),
              selected: onlySaved,
              onSelected: busy ? null : (v) => setState(() => onlySaved = v)),
          Wrap(spacing: 8, children: [
            FilledButton(
                onPressed: busy ? null : () => run(search),
                child: const Text('Search profiles')),
            if (preferences != null)
              DropdownButton<String>(
                  value: preferences!['density'],
                  hint: const Text('Reading density'),
                  items: const [
                    DropdownMenuItem(
                        value: 'comfortable',
                        child: Text('Comfortable reading')),
                    DropdownMenuItem(
                        value: 'compact', child: Text('Compact reading'))
                  ],
                  onChanged: busy ? null : (v) => run(() => save(density: v))),
          ]),
        ])),
        if (busy) const LinearProgressIndicator(),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        if (preferences != null)
          Surface(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Semantics(
                    liveRegion: true,
                    child: Text(
                        'Saved comparison tray — ${selected.length} of 3 profiles')),
                Text(preferences!['scope']),
                for (final id in selected)
                  Row(children: [
                    Expanded(
                        child: Text((preferences!['candidates'] as List)
                                .where((p) => p['profile']['id'] == id)
                                .map((p) => p['profile']['display_name'])
                                .firstOrNull ??
                            'Profile no longer available')),
                    IconButton(
                        tooltip: 'Remove profile $id from comparison',
                        onPressed: busy
                            ? null
                            : () => run(() => save(
                                ids: selected.where((v) => v != id).toList())),
                        icon: const Icon(Icons.close)),
                  ]),
                FilledButton.tonal(
                    onPressed: busy || selected.length < 2
                        ? null
                        : () => run(() async {
                              await refreshPreferences();
                              if (mounted) {
                                setState(() => compared = true);
                              }
                            }),
                    child: const Text('Refresh and compare selected profiles')),
                if ((preferences!['unavailable_count'] as num) > 0)
                  TextButton(
                      onPressed: busy
                          ? null
                          : () => run(() => save(
                              ids: (preferences!['candidates'] as List)
                                  .map((p) => p['profile']['id'])
                                  .toList())),
                      child: const Text('Remove all unavailable profiles')),
                if ((preferences!['unavailable_count'] as num) > 0)
                  Text(
                      '${preferences!['unavailable_count']} profiles withheld after consent or availability changed.'),
              ])),
        if (compared && preferences != null) ...[
          Semantics(
              header: true,
              child: Text('Evidence comparison',
                  style: Theme.of(context).textTheme.headlineSmall)),
          const Text(
              'Scores, declared skills, assessed badges and reviewed sources are separate. This comparison does not calculate role fit.'),
          for (final person in preferences!['candidates'])
            candidate(person, comparison: true),
        ],
        if (loaded && results.isEmpty)
          const Text(
              'No discoverable profiles match. Try another name or skill.'),
        for (final person
            in results.where((p) => !onlySaved || p['saved'] == true))
          candidate(person),
      ]));
}

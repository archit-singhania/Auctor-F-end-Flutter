import 'package:flutter/material.dart';
import 'controller.dart';
import 'app.dart' show Surface;

class ProfileAnalytics extends StatefulWidget {
  const ProfileAnalytics({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<ProfileAnalytics> createState() => _ProfileAnalyticsState();
}

class _ProfileAnalyticsState extends State<ProfileAnalytics> {
  Map<String, dynamic>? report;
  bool busy = false;
  String? error;
  Future<void> run({bool? enabled, bool reset = false}) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final api = widget.controller.api;
      if (enabled != null) {
        await api.call('/analytics', method: 'PUT', data: {'enabled': enabled});
      }
      if (reset) {
        await api.call('/analytics', method: 'DELETE');
      }
      final value = await api.call('/analytics');
      if (mounted) {
        setState(() => report = Map<String, dynamic>.from(value));
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
        Text('Profile analytics',
            style: Theme.of(context).textTheme.titleLarge),
        const Text(
            'Opt-in, aggregate daily interactions. Counts do not identify visitors or measure unique people.'),
        OutlinedButton(
            onPressed: busy ? null : () => run(),
            child: const Text('Load analytics')),
        if (busy) const LinearProgressIndicator(),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        if (report != null) ...[
          SwitchListTile(
              title: const Text('Collect public profile interactions'),
              subtitle: const Text(
                  'Disabled by default. Turning this off stops new counts and preserves history.'),
              value: report!['enabled'] == true,
              onChanged: busy ? null : (value) => run(enabled: value)),
          Text(report!['scope']),
          if ((report!['days'] as List).isEmpty)
            const Text('No recorded interactions.'),
          for (final day in report!['days'])
            ListTile(
                title: Text('${day['day']} · ${day['kind']}'),
                trailing: Text('${day['count']}',
                    semanticsLabel: '${day['count']} interactions')),
          TextButton(
              onPressed: busy
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title: const Text('Reset analytics history?'),
                                  content: const Text(
                                      'This deletes the saved daily counts. Collection stays in its current enabled or disabled state.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete counts'))
                                  ]));
                      if (confirmed == true && mounted) {
                        await run(reset: true);
                      }
                    },
              child: const Text('Reset analytics')),
        ],
      ]));
}

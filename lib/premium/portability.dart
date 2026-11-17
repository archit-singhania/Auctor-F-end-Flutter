import 'package:flutter/material.dart';
import 'controller.dart';
import 'app.dart' show Surface, download;

class AccountPortability extends StatefulWidget {
  const AccountPortability({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<AccountPortability> createState() => _AccountPortabilityState();
}

class _AccountPortabilityState extends State<AccountPortability> {
  Map<String, dynamic>? state;
  bool busy = false;
  String? error;
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

  Future<void> refresh() async {
    final value = await widget.controller.api.call('/portability');
    if (mounted) {
      setState(() => state = Map<String, dynamic>.from(value));
    }
  }

  @override
  Widget build(BuildContext context) => Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Account portability',
            style: Theme.of(context).textTheme.titleLarge),
        const Text(
            'Export your owned records and source files in a private ZIP with a checksum manifest. Export retention does not delete original account data.'),
        Wrap(spacing: 8, children: [
          OutlinedButton(
              onPressed: busy ? null : () => run(refresh),
              child: const Text('Refresh account exports')),
          FilledButton(
              onPressed: busy
                  ? null
                  : () => run(() async {
                        await widget.controller.api
                            .call('/portability/exports', method: 'POST');
                        await refresh();
                      }),
              child: const Text('Queue account export')),
        ]),
        if (busy) const LinearProgressIndicator(),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        if (state != null) ...[
          Text(state!['scope']),
          DropdownButtonFormField<int>(
              key: ValueKey(state!['export_days']),
              initialValue: state!['export_days'],
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: 'Generated archive retention (future exports)'),
              items: [
                for (var day = 1; day <= 30; day++)
                  DropdownMenuItem(value: day, child: Text('$day days'))
              ],
              onChanged: busy
                  ? null
                  : (days) => run(() async {
                        await widget.controller.api.call(
                            '/portability/retention',
                            method: 'PUT',
                            data: {'export_days': days});
                        await refresh();
                      })),
          if ((state!['jobs'] as List).isEmpty)
            const Text('No exports requested yet.'),
          for (final job in state!['jobs'])
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                              liveRegion: true,
                              child: Text('Export ${job['status']}')),
                          Text(
                              'Requested ${job['created_at']} · expires ${job['expires_at']}'),
                          if (job['error'] != null) Text(job['error']),
                          if (job['sha256'] != null)
                            SelectableText('SHA-256 ${job['sha256']}'),
                          if (job['status'] == 'ready')
                            OutlinedButton(
                                onPressed: busy
                                    ? null
                                    : () => run(() => download(
                                        widget.controller.api,
                                        '/portability/exports/${job['id']}/download',
                                        'auctor-account.zip')),
                                child: const Text('Download private archive')),
                          if (job['status'] == 'failed')
                            TextButton(
                                onPressed: busy
                                    ? null
                                    : () => run(() async {
                                          await widget.controller.api.call(
                                              '/portability/exports/${job['id']}/retry',
                                              method: 'POST');
                                          await refresh();
                                        }),
                                child: const Text('Retry export')),
                        ]))),
        ],
      ]));
}

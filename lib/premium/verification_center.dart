import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controller.dart';
import 'liquid_glass.dart';
import 'save_stub.dart'
    if (dart.library.io) 'save_io.dart'
    if (dart.library.js_interop) 'save_web.dart';

class VerificationCenter extends StatefulWidget {
  const VerificationCenter({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<VerificationCenter> createState() => _VerificationCenterState();
}

class _VerificationCenterState extends State<VerificationCenter> {
  List evidence = [],
      receipts = [],
      checks = [],
      signals = [],
      integrations = [];
  bool loading = true, working = false;
  String? error;
  bool get reviewer => widget.controller.profile['role'] == 'reviewer';
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final values = await Future.wait([
        for (final path in [
          '/verification/evidence',
          '/verification/receipts',
          '/verification/rechecks',
          '/verification/integrity',
          '/integrations'
        ])
          widget.controller.api.call(path)
      ]);
      if (mounted) {
        setState(() {
          evidence = values[0];
          receipts = values[1];
          checks = values[2];
          signals = values[3];
          integrations = values[4];
          loading = false;
        });
      }
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
      await load();
      await widget.controller.refresh();
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

  Future<void> inspect(String title, Object value) async {
    if (!mounted) return;
    final wasWorking = working;
    setState(() => working = false);
    try {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: Text(title),
                  content: SizedBox(
                      width: 650,
                      child: SingleChildScrollView(
                          child: SelectableText(
                              const JsonEncoder.withIndent('  ')
                                  .convert(value)))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close details'))
                  ]));
    } finally {
      if (mounted) {
        setState(() => working = wasWorking);
      }
    }
  }

  Future<Map<String, String>?> form(
      String title, Map<String, String> fields) async {
    final values = Map<String, String>.from(fields);
    return showDialog<Map<String, String>>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(title),
                content: SizedBox(
                    width: 520,
                    child: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      for (final field in fields.entries)
                        TextFormField(
                            initialValue: field.value,
                            decoration: InputDecoration(labelText: field.key),
                            maxLength: field.key.contains('note')
                                ? 2000
                                : field.key == 'Signed receipt JSON'
                                    ? 5000
                                    : 2048,
                            maxLines: field.key.contains('note') ||
                                    field.key == 'Signed receipt JSON'
                                ? 4
                                : 1,
                            onChanged: (v) => values[field.key] = v)
                    ]))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, values),
                      child: const Text('Submit reviewed values'))
                ]));
  }

  Future<void> lifecycle(Map item, {Map? request, bool approve = true}) async {
    final values = await form(
        request == null
            ? 'Review evidence eligibility'
            : approve
                ? 'Approve manual re-verification'
                : 'Reject manual re-verification',
        {
          'State (current, stale, revoked)': approve ? 'current' : 'revoked',
          'Review due (ISO timestamp with timezone, optional)':
              item['review_due_at'] ?? '',
          'Reviewer note': ''
        });
    if (values == null || !mounted) return;
    final due =
        values['Review due (ISO timestamp with timezone, optional)']!.trim();
    await perform(() async {
      await widget.controller.api.call(
          request == null
              ? '/verification/evidence/${item['id']}/lifecycle'
              : '/verification/rechecks/${request['id']}/decision',
          method: request == null ? 'PUT' : 'POST',
          data: {
            'state': values['State (current, stale, revoked)'],
            'review_due_at': due.isEmpty ? null : due,
            'note': values['Reviewer note'],
            if (request != null) 'approved': approve
          });
    });
  }

  Future<void> consent() async {
    String name = '', url = '';
    bool profile = true, verification = false, confirmed = false;
    int days = 30;
    final key = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, update) => AlertDialog(
                    title: const Text('Authorize recruiter integration'),
                    content: SizedBox(
                        width: 560,
                        child: SingleChildScrollView(
                            child: Form(
                                key: key,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                          'This credential can read only your permitted profile/verification fields. Private source files and contact fields are excluded. Optional signed webhooks contain event metadata only. Revoke consent at any time.'),
                                      TextFormField(
                                          decoration: const InputDecoration(
                                              labelText: 'Integration name'),
                                          maxLength: 100,
                                          onChanged: (v) => name = v,
                                          validator: (v) =>
                                              (v ?? '').trim().isEmpty
                                                  ? 'Enter a name'
                                                  : null),
                                      CheckboxListTile(
                                          title:
                                              const Text('Allow profile reads'),
                                          value: profile,
                                          onChanged: (v) => update(
                                              () => profile = v == true)),
                                      CheckboxListTile(
                                          title: const Text(
                                              'Allow verification status reads and updates'),
                                          value: verification,
                                          onChanged: (v) => update(
                                              () => verification = v == true)),
                                      TextFormField(
                                          decoration: const InputDecoration(
                                              labelText:
                                                  'HTTPS webhook URL (optional)'),
                                          maxLength: 2048,
                                          onChanged: (v) => url = v),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: DropdownButtonFormField<int>(
                                              initialValue: days,
                                              decoration: const InputDecoration(
                                                  labelText:
                                                      'Credential expiration'),
                                              items: [7, 30, 90]
                                                  .map((v) => DropdownMenuItem(
                                                      value: v,
                                                      child: Text('$v days')))
                                                  .toList(),
                                              onChanged: (v) => days = v!)),
                                      CheckboxListTile(
                                          title: const Text(
                                              'I authorize these scopes and this webhook destination'),
                                          value: confirmed,
                                          onChanged: (v) => update(
                                              () => confirmed = v == true)),
                                    ])))),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: !confirmed || (!profile && !verification)
                              ? null
                              : () {
                                  if (key.currentState!.validate()) {
                                    Navigator.pop(ctx, true);
                                  }
                                },
                          child: const Text('Create scoped credential'))
                    ])));
    if (accepted != true || !mounted) return;
    await perform(() async {
      final result = await widget.controller.api
          .call('/integrations', method: 'POST', data: {
        'name': name.trim(),
        'webhook_url': url.trim(),
        'scopes': [
          if (profile) 'profile:read',
          if (verification) 'verification:read'
        ],
        'expires_days': days,
        'confirm_consent': true
      });
      await inspect('Store credentials securely · shown only once', result);
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
          Text('Verification & consent',
              style: Theme.of(context).textTheme.headlineSmall),
          const Text(
              'Signatures prove scope and snapshot integrity, not claim truth. Review dates affect current eligibility. Integrity signals require human judgment and never automatically change grading.'),
          TextButton(
              onPressed: working ? null : load,
              child: const Text('Refresh verification center')),
          if (loading || working) const LinearProgressIndicator(),
          if (error != null)
            Text(error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          Text('Evidence review lifecycle',
              style: Theme.of(context).textTheme.titleLarge),
          if (evidence.isEmpty)
            const Text(
                'No evidence available for this account or review role.'),
          for (final e in evidence)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e['title'],
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                          '${e['status']} · ${e['eligibility_state']} · review due ${e['review_due_at'] ?? 'Not assigned'}'),
                      Wrap(spacing: 8, children: [
                        TextButton(
                            onPressed: working
                                ? null
                                : () => inspect(
                                    'Evidence scope and source metadata', e),
                            child: const Text('Inspect evidence')),
                        if (e['has_file'] == true)
                          TextButton(
                              onPressed: working
                                  ? null
                                  : () => perform(() async {
                                        await saveReport(
                                            'evidence.pdf',
                                            await c.api.bytes(
                                                '/evidence/${e['id']}/file'));
                                      }),
                              child:
                                  const Text('Download authorized proof PDF')),
                        if (reviewer && e['user_id'] != c.profile['id'])
                          OutlinedButton(
                              onPressed: working ? null : () => lifecycle(e),
                              child: const Text('Review eligibility')),
                        if (e['user_id'] == c.profile['id']) ...[
                          OutlinedButton(
                              onPressed: working
                                  ? null
                                  : () => perform(() async {
                                        await c.api.call(
                                            '/verification/evidence/${e['id']}/recheck',
                                            method: 'POST');
                                      }),
                              child: const Text('Request re-verification')),
                          if (e['status'] == 'verified' &&
                              e['eligibility_state'] == 'current')
                            FilledButton(
                                onPressed: working
                                    ? null
                                    : () => perform(() async {
                                          final result = await c.api.call(
                                              '/verification/evidence/${e['id']}/receipts',
                                              method: 'POST');
                                          await inspect(
                                              'Signed scope receipt', result);
                                        }),
                                child: const Text('Issue signed receipt')),
                        ]
                      ])
                    ])),
          const Divider(height: 32),
          Text('Your signed receipts',
              style: Theme.of(context).textTheme.titleLarge),
          if (receipts.isEmpty)
            const Text(
                'No receipts yet. Only currently eligible verified evidence can receive one.'),
          for (final r in receipts)
            Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                      '${r['revoked'] ? 'Revoked' : 'Issued'} · ${r['payload']['scope']}'),
                  TextButton(
                      onPressed: working
                          ? null
                          : () => perform(() async {
                                await inspect(
                                    'Signature and current eligibility',
                                    await c.api.call(
                                        '/verification/receipts/${r['id']}'));
                              }),
                      child: const Text('Check receipt status')),
                  TextButton(
                      onPressed: () => Clipboard.setData(ClipboardData(
                          text:
                              '${PlatformApi.base}/api/verification/receipts/${r['id']}')),
                      child: const Text('Copy public receipt URL')),
                  if (!r['revoked'])
                    TextButton(
                        onPressed: working
                            ? null
                            : () => perform(() async {
                                  await c.api.call(
                                      '/verification/receipts/${r['id']}',
                                      method: 'DELETE');
                                }),
                        child: const Text('Revoke receipt'))
                ]),
          TextButton(
              onPressed: working
                  ? null
                  : () async {
                      final value = await form('Verify a signed receipt',
                          {'Signed receipt JSON': ''});
                      if (value == null || !mounted) return;
                      await perform(() async {
                        final data = jsonDecode(value['Signed receipt JSON']!);
                        await inspect(
                            'Cryptographic verification result',
                            await c.api.call('/verification/verify',
                                method: 'POST',
                                data: {
                                  'payload': data['payload'],
                                  'signature': data['signature']
                                }));
                      });
                    },
              child: const Text('Verify pasted receipt')),
          Text('Re-verification requests',
              style: Theme.of(context).textTheme.titleLarge),
          if (checks.isEmpty) const Text('No re-verification requests.'),
          for (final r in checks)
            ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(r['title']),
                subtitle: Text('${r['status']} · ${r['reason']}'),
                trailing: reviewer &&
                        r['user_id'] != c.profile['id'] &&
                        r['status'] == 'pending'
                    ? PopupMenuButton<bool>(
                        tooltip: 'Decide re-verification',
                        onSelected: (approved) => lifecycle(
                            evidence
                                    .where((e) => e['id'] == r['evidence_id'])
                                    .firstOrNull ??
                                {'id': r['evidence_id']},
                            request: r,
                            approve: approved),
                        itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: true,
                                  child: Text('Approve manual review')),
                              const PopupMenuItem(
                                  value: false,
                                  child: Text('Reject manual review'))
                            ])
                    : null),
          const Text(
              'Manual reviewer action is required. Re-verification does not invent issuer or employment proof.'),
          const Divider(height: 32),
          Text('Assessment integrity review',
              style: Theme.of(context).textTheme.titleLarge),
          if (signals.isEmpty)
            const Text(
                'No review signals. This is not a guarantee of assessment integrity.'),
          for (final s in signals)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s['kind']} · ${s['review_status']}'),
                      Text('${s['data']['explanation']}'),
                      TextButton(
                          onPressed: () => inspect(
                              'Server-observed signal · human review required',
                              s),
                          child: const Text('Inspect signal')),
                      if (reviewer && s['user_id'] != c.profile['id'])
                        TextButton(
                            onPressed: working
                                ? null
                                : () async {
                                    final values =
                                        await form('Record human disposition', {
                                      'Disposition (reviewed, dismissed, needs_followup)':
                                          'reviewed',
                                      'Reviewer note': ''
                                    });
                                    if (values == null || !mounted) return;
                                    await perform(() async {
                                      await c.api.call(
                                          '/verification/integrity/${s['id']}/review',
                                          method: 'POST',
                                          data: {
                                            'disposition': values[
                                                'Disposition (reviewed, dismissed, needs_followup)'],
                                            'note': values['Reviewer note']
                                          });
                                    });
                                  },
                            child: const Text('Record disposition'))
                    ])),
          if (reviewer)
            Wrap(spacing: 8, children: [
              TextButton(
                  onPressed: working
                      ? null
                      : () => perform(() async {
                            await inspect(
                                'Evidence lifecycle audit',
                                await c.api
                                    .call('/verification/lifecycle-audit'));
                          }),
                  child: const Text('Lifecycle audit')),
              TextButton(
                  onPressed: working
                      ? null
                      : () => perform(() async {
                            await inspect(
                                'Integrity review audit',
                                await c.api
                                    .call('/verification/integrity-audit'));
                          }),
                  child: const Text('Integrity audit'))
            ]),
          const Divider(height: 32),
          Text('Recruiter integrations',
              style: Theme.of(context).textTheme.titleLarge),
          const Text(
              'Credentials are scoped to your account. Webhook redirects and private-network destinations are blocked outside explicitly configured local development.'),
          FilledButton(
              onPressed: working ? null : consent,
              child: const Text('Authorize recruiter integration')),
          if (integrations.isEmpty)
            const Text(
                'No recruiter integrations. No credentials or webhooks are active.'),
          for (final i in integrations)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i['name'],
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                          '${i['revoked'] ? 'Revoked' : DateTime.tryParse(i['expires_at'].toString())?.isBefore(DateTime.now()) == true ? 'Expired' : 'Consented'} · ${(i['scopes'] as List).join(', ')} · expires ${i['expires_at']}'),
                      Wrap(spacing: 8, children: [
                        TextButton(
                            onPressed: working
                                ? null
                                : () => perform(() async {
                                      await inspect(
                                          'Signed webhook delivery history',
                                          await c.api.call(
                                              '/integrations/${i['id']}/deliveries'));
                                    }),
                            child: const Text('Delivery history')),
                        if (!i['revoked'])
                          TextButton(
                              onPressed: working
                                  ? null
                                  : () => perform(() async {
                                        await c.api.call(
                                            '/integrations/${i['id']}',
                                            method: 'DELETE');
                                      }),
                              child: const Text('Revoke consent'))
                      ])
                    ])),
        ]));
  }
}

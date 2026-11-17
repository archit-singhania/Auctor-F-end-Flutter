import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'controller.dart';
import 'app.dart' show Surface;
import 'save_stub.dart'
    if (dart.library.io) 'save_io.dart'
    if (dart.library.js_interop) 'save_web.dart';

class AccountDeletion extends StatefulWidget {
  const AccountDeletion({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<AccountDeletion> createState() => _AccountDeletionState();
}

class _AccountDeletionState extends State<AccountDeletion> {
  final password = TextEditingController(),
      confirmation = TextEditingController();
  Map<String, dynamic>? preview;
  bool busy = false;
  String? error;
  @override
  void dispose() {
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> inspect() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final value =
          await widget.controller.api.call('/account-deletion/preview');
      if (mounted) {
        setState(() => preview = Map<String, dynamic>.from(value));
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

  Future<void> begin() async {
    final approved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Permanently delete this account?'),
                content: const Text(
                    'Sessions, sharing and integrations will be revoked immediately. Cleanup cannot be undone here. Download any exports you need first. Retained backups follow the operator retention policy.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Keep account')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirm account deletion'))
                ]));
    if (approved != true || !mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final value = await widget.controller.api
          .call('/account-deletion', method: 'POST', data: {
        'preview_sha256': preview!['preview_sha256'],
        'password': password.text,
        'confirmation': confirmation.text
      });
      password.clear();
      confirmation.clear();
      if (mounted) {
        context.go('/deletion-status', extra: Map<String, dynamic>.from(value));
      }
      await widget.controller.logout(serverRevoked: true);
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
        Text('Delete account', style: Theme.of(context).textTheme.titleLarge),
        const Text(
            'Review the inventory and export anything you need before starting permanent cleanup.'),
        OutlinedButton(
            onPressed: busy ? null : inspect,
            child: const Text('Review deletion inventory')),
        TextButton(
            onPressed: () => context.go('/deletion-status'),
            child: const Text('Check a deletion receipt')),
        if (busy) const LinearProgressIndicator(),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        if (preview != null) ...[
          Text('Account @${preview!['handle']}'),
          Text(preview!['scope']),
          Text(
              'Operator backup policy: ${preview!['backup_policy_days']} days. Backup expiry must be enforced by the deployment operator.'),
          ExpansionTile(title: const Text('Owned record counts'), children: [
            for (final entry in (preview!['counts'] as Map).entries)
              ListTile(title: Text(entry.key), trailing: Text('${entry.value}'))
          ]),
          if ((preview!['owned_organizations'] as List).isNotEmpty) ...[
            const Text(
                'Transfer these organizations to another active member before deletion:'),
            for (final org in preview!['owned_organizations'])
              Text(org['name']),
          ] else ...[
            TextField(
                controller: password,
                enabled: !busy,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Confirm current password')),
            TextField(
                controller: confirmation,
                enabled: !busy,
                decoration:
                    const InputDecoration(labelText: 'Type DELETE MY ACCOUNT')),
            FilledButton(
                onPressed: busy ? null : begin,
                child: const Text('Review final deletion confirmation')),
          ],
        ],
      ]));
}

class DeletionStatusPage extends StatefulWidget {
  const DeletionStatusPage({super.key, this.initial});
  final Map<String, dynamic>? initial;
  @override
  State<DeletionStatusPage> createState() => _DeletionStatusPageState();
}

class _DeletionStatusPageState extends State<DeletionStatusPage> {
  final api = PlatformApi();
  late final TextEditingController id =
      TextEditingController(text: widget.initial?['id']);
  late final TextEditingController receipt =
      TextEditingController(text: widget.initial?['receipt']);
  Map<String, dynamic>? result;
  String? error;
  bool busy = false;
  @override
  void dispose() {
    id.dispose();
    receipt.dispose();
    api.client.close();
    super.dispose();
  }

  Future<void> check({bool retry = false}) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final body = {'id': id.text.trim(), 'receipt': receipt.text.trim()};
      if (retry) {
        await api.call('/account-deletion/retry',
            method: 'POST', authenticated: false, data: body);
      }
      final value = await api.call('/account-deletion/status',
          method: 'POST', authenticated: false, data: body);
      if (mounted) {
        setState(() => result = Map<String, dynamic>.from(value));
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
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Deletion receipt')),
      body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                'Keep this private receipt to check cleanup after sign-out. It contains no account password. Completion covers active-store cleanup, not immediate removal from retained backups.'),
                            TextField(
                                controller: id,
                                enabled: !busy,
                                decoration: const InputDecoration(
                                    labelText: 'Deletion job ID')),
                            TextField(
                                controller: receipt,
                                enabled: !busy,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'Private receipt token')),
                            Wrap(spacing: 8, children: [
                              OutlinedButton(
                                  onPressed: busy ? null : () => check(),
                                  child: const Text('Check deletion progress')),
                              TextButton(
                                  onPressed: () async {
                                    try {
                                      await saveReport(
                                          'auctor-deletion-receipt.json',
                                          Uint8List.fromList(utf8.encode(
                                              jsonEncode({
                                            'id': id.text.trim(),
                                            'receipt': receipt.text.trim()
                                          }))));
                                    } catch (e) {
                                      if (mounted) {
                                        setState(() => error = e.toString());
                                      }
                                    }
                                  },
                                  child: const Text('Save private receipt')),
                              TextButton(
                                  onPressed: () => context.go('/'),
                                  child: const Text('Return to sign in')),
                            ]),
                            if (busy) const LinearProgressIndicator(),
                            if (error != null)
                              Semantics(liveRegion: true, child: Text(error!)),
                            if (result != null) ...[
                              Semantics(
                                  liveRegion: true,
                                  child: Text('Cleanup ${result!['status']}')),
                              if (result!['error'] != null)
                                Text(result!['error']),
                              SelectableText(const JsonEncoder.withIndent('  ')
                                  .convert(result)),
                              if (result!['status'] == 'failed')
                                OutlinedButton(
                                    onPressed:
                                        busy ? null : () => check(retry: true),
                                    child: const Text('Retry cleanup')),
                            ],
                          ]))))));
}

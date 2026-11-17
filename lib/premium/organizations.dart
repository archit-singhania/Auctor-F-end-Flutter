import 'package:flutter/material.dart';
import 'controller.dart';
import 'app.dart' show Surface;

class OrganizationWorkspace extends StatefulWidget {
  const OrganizationWorkspace({super.key, required this.controller});
  final WorkspaceController controller;
  @override
  State<OrganizationWorkspace> createState() => _OrganizationWorkspaceState();
}

class _OrganizationWorkspaceState extends State<OrganizationWorkspace> {
  final name = TextEditingController(),
      token = TextEditingController(),
      email = TextEditingController(),
      query = TextEditingController();
  List organizations = [], candidates = [];
  Map<String, dynamic>? org;
  final Map<int, String> notes = {};
  String inviteRole = 'reviewer';
  String? error, invitation;
  bool busy = false;
  @override
  void dispose() {
    name.dispose();
    token.dispose();
    email.dispose();
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

  Future<void> list() async {
    final value = await widget.controller.api.call('/organizations');
    if (mounted) {
      setState(() => organizations = value);
    }
  }

  Future<void> open(String id) async {
    final value = await widget.controller.api.call('/organizations/$id');
    if (mounted) {
      setState(() {
        if (org?['id'] != id) {
          notes.clear();
          candidates = [];
          invitation = null;
        }
        org = Map<String, dynamic>.from(value);
      });
    }
  }

  Future<void> change(String suffix, String method, [Map? data]) async {
    await widget.controller.api.call('/organizations/${org!['id']}/$suffix',
        method: method, data: data);
    await open(org!['id']);
  }

  Future<bool> confirm(String title) async =>
      await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(title: Text(title), actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirm'))
              ])) ??
      false;
  @override
  Widget build(BuildContext context) => Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Organization workspace',
            style: Theme.of(context).textTheme.titleLarge),
        const Text(
            'Share a recruiting workspace with invited colleagues. Membership does not unlock private candidate evidence.'),
        OutlinedButton(
            onPressed: busy ? null : () => run(list),
            child: const Text('Load organizations')),
        ExpansionTile(
            title: const Text('Create or join a workspace'),
            children: [
              TextField(
                  controller: name,
                  enabled: !busy,
                  decoration:
                      const InputDecoration(labelText: 'Organization name')),
              FilledButton(
                  onPressed: busy
                      ? null
                      : () => run(() async {
                            final value = await widget.controller.api.call(
                                '/organizations',
                                method: 'POST',
                                data: {'name': name.text});
                            await list();
                            await open(value['id']);
                          }),
                  child: const Text('Create organization')),
              TextField(
                  controller: token,
                  enabled: !busy,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Invitation token for your email')),
              OutlinedButton(
                  onPressed: busy
                      ? null
                      : () => run(() async {
                            final value = await widget.controller.api.call(
                                '/organizations/accept',
                                method: 'POST',
                                data: {'token': token.text.trim()});
                            token.clear();
                            await list();
                            await open(value['organization_id']);
                          }),
                  child: const Text('Accept invitation')),
            ]),
        if (busy) const LinearProgressIndicator(),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        for (final item in organizations)
          ListTile(
              title: Text(item['name']),
              subtitle: Text(item['role']),
              onTap: busy ? null : () => run(() => open(item['id']))),
        if (org != null) ...[
          Text('${org!['name']} · ${org!['role']}',
              style: Theme.of(context).textTheme.titleMedium),
          ExpansionTile(
              title: const Text('Members and invitations'),
              children: [
                for (final member in org!['members'])
                  ListTile(
                      title: Text(member['display_name']),
                      subtitle: Text(member['role']),
                      trailing: member['role'] == 'owner' ||
                              org!['role'] == 'reviewer'
                          ? null
                          : Wrap(children: [
                              if (org!['role'] == 'owner')
                                IconButton(
                                    tooltip:
                                        'Transfer ownership to ${member['display_name']}',
                                    icon: const Icon(Icons.key),
                                    onPressed: busy
                                        ? null
                                        : () => run(() async {
                                              if (await confirm(
                                                  'Transfer ownership to this member? You will become an administrator.')) {
                                                await change(
                                                    'transfer-owner', 'POST', {
                                                  'new_owner_id':
                                                      member['user_id'],
                                                  'confirm_transfer': true
                                                });
                                              }
                                            })),
                              if (org!['role'] == 'owner')
                                IconButton(
                                    tooltip:
                                        'Change role for ${member['display_name']}',
                                    icon: const Icon(Icons.manage_accounts),
                                    onPressed: busy
                                        ? null
                                        : () => run(() async {
                                              final role =
                                                  member['role'] == 'reviewer'
                                                      ? 'administrator'
                                                      : 'reviewer';
                                              if (await confirm(
                                                  'Change this member to $role?')) {
                                                await change(
                                                    'members/${member['user_id']}',
                                                    'PUT',
                                                    {'role': role});
                                              }
                                            })),
                              IconButton(
                                  tooltip: 'Remove ${member['display_name']}',
                                  icon:
                                      const Icon(Icons.person_remove_outlined),
                                  onPressed: busy
                                      ? null
                                      : () => run(() async {
                                            if (await confirm(
                                                'Remove this member and revoke their invitations?')) {
                                              await change(
                                                  'members/${member['user_id']}',
                                                  'DELETE');
                                            }
                                          })),
                            ])),
                if (org!['role'] != 'reviewer') ...[
                  TextField(
                      controller: email,
                      enabled: !busy,
                      decoration:
                          const InputDecoration(labelText: 'Recipient email')),
                  DropdownButton<String>(
                      isExpanded: true,
                      value: inviteRole,
                      items: const [
                        DropdownMenuItem(
                            value: 'reviewer', child: Text('Reviewer')),
                        DropdownMenuItem(
                            value: 'administrator',
                            child: Text('Administrator (owner only)'))
                      ],
                      onChanged: busy
                          ? null
                          : (value) => setState(() => inviteRole = value!)),
                  OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => run(() async {
                                final value = await widget.controller.api.call(
                                    '/organizations/${org!['id']}/invitations',
                                    method: 'POST',
                                    data: {
                                      'email': email.text,
                                      'role': inviteRole
                                    });
                                if (mounted) {
                                  setState(() => invitation = value['token']);
                                }
                                await open(org!['id']);
                              }),
                      child: const Text('Create seven-day invitation')),
                  if (invitation != null)
                    SelectableText(
                        'Invitation token (shown only now; no email sent): $invitation'),
                  for (final invite in org!['invitations'])
                    ListTile(
                        title: Text(invite['email']),
                        subtitle: Text(
                            '${invite['role']} · accepted ${invite['accepted']} · revoked ${invite['revoked']}'),
                        trailing: IconButton(
                            tooltip: 'Revoke invitation for ${invite['email']}',
                            icon: const Icon(Icons.link_off),
                            onPressed: busy
                                ? null
                                : () => run(() => change(
                                    'invitations/${invite['id']}', 'DELETE')))),
                ],
              ]),
          TextField(
              controller: query,
              enabled: !busy,
              decoration: const InputDecoration(
                  labelText: 'Find discoverable candidates')),
          OutlinedButton(
              onPressed: busy
                  ? null
                  : () => run(() async {
                        final values = await widget.controller.api.call(
                            '/candidates?q=${Uri.encodeQueryComponent(query.text)}');
                        if (mounted) {
                          setState(() => candidates = values);
                        }
                      }),
              child: const Text('Search organization candidates')),
          for (final candidate in candidates)
            ListTile(
                title: Text(candidate['profile']['display_name']),
                trailing: TextButton(
                    onPressed: busy ||
                            (org!['profiles'] as List).any((p) =>
                                p['candidate']['profile']['id'] ==
                                candidate['profile']['id'])
                        ? null
                        : () => run(() => change(
                            'profiles/${candidate['profile']['id']}',
                            'PUT',
                            {'revision': 0, 'text': ''})),
                    child: const Text('Save to organization'))),
          if (org!['unavailable_count'] > 0)
            Text(
                '${org!['unavailable_count']} saved profiles are withheld because consent is unavailable.'),
          for (final profile in org!['profiles'])
            ExpansionTile(
                key: ValueKey(
                    '${org!['id']}-${profile['candidate']['profile']['id']}'),
                title: Text(profile['candidate']['profile']['display_name']),
                subtitle: Text(
                    'Score ${profile['candidate']['score']['total']} · current reviewed sources ${(profile['candidate']['evidence'] as List).length}'),
                children: [
                  Text(
                      'Declared skills: ${(profile['candidate']['skills'] as List).join(', ')}'),
                  TextFormField(
                      key: ValueKey(
                          '${org!['id']}-${profile['candidate']['profile']['id']}-${profile['revision']}'),
                      initialValue:
                          notes[profile['candidate']['profile']['id']] ??
                              profile['note'],
                      enabled: !busy,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Organization-private review note'),
                      onChanged: (value) =>
                          notes[profile['candidate']['profile']['id']] = value),
                  OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => run(() => change(
                                  'profiles/${profile['candidate']['profile']['id']}',
                                  'PUT', {
                                'revision': profile['revision'],
                                'text': notes[profile['candidate']['profile']
                                        ['id']] ??
                                    profile['note']
                              })),
                      child: const Text('Save review note')),
                  TextButton(
                      onPressed: busy
                          ? null
                          : () => run(() async {
                                if (await confirm(
                                    'Remove this saved profile and its organization review note?')) {
                                  await change(
                                      'profiles/${profile['candidate']['profile']['id']}',
                                      'DELETE');
                                  notes.remove(
                                      profile['candidate']['profile']['id']);
                                }
                              }),
                      child: const Text('Remove saved profile')),
                  CheckboxListTile(
                      title: const Text(
                          'Include in shared comparison (up to three)'),
                      value: (org!['candidate_ids'] as List)
                          .contains(profile['candidate']['profile']['id']),
                      onChanged: busy
                          ? null
                          : (checked) => run(() {
                                final ids = List.from(org!['candidate_ids']);
                                final cid =
                                    profile['candidate']['profile']['id'];
                                checked == true
                                    ? ids.add(cid)
                                    : ids.remove(cid);
                                return change('comparison', 'PUT', {
                                  'revision': org!['revision'],
                                  'candidate_ids': ids
                                });
                              })),
                ]),
          const Text('Shared comparison — current public evidence'),
          for (final profile in (org!['profiles'] as List).where((p) =>
              (org!['candidate_ids'] as List)
                  .contains(p['candidate']['profile']['id'])))
            ListTile(
                title: Text(profile['candidate']['profile']['display_name']),
                subtitle: Text(
                    'Declared skills: ${(profile['candidate']['skills'] as List).join(', ')}\nAssessment badges: ${(profile['candidate']['badges'] as List).join(', ')}\nReviewed evidence: ${(profile['candidate']['evidence'] as List).length}')),
          ExpansionTile(title: const Text('Organization activity'), children: [
            for (final item in org!['history'])
              ListTile(
                  title: Text(item['action']),
                  subtitle: Text(
                      '${item['created_at']} · actor ${item['actor_id']} · ${item['target']}'))
          ]),
        ],
      ]));
}

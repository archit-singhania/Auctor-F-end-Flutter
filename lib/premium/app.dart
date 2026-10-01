import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controller.dart';
import 'package:flutter/foundation.dart';
import 'save_stub.dart' if (dart.library.io) 'save_io.dart';

final workspaceProvider =
    ChangeNotifierProvider<WorkspaceController>((ref) => WorkspaceController());
const pine = Color(0xff173e38), champagne = Color(0xffd6b77e);

class PremiumApp extends ConsumerStatefulWidget {
  const PremiumApp({super.key});
  @override
  ConsumerState<PremiumApp> createState() => _PremiumAppState();
}

class _PremiumAppState extends ConsumerState<PremiumApp> {
  late final GoRouter router;
  @override
  void initState() {
    super.initState();
    router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const EntryPage()),
      GoRoute(path: '/workspace', builder: (_, __) => const EntryPage()),
      GoRoute(
          path: '/public/:handle',
          builder: (_, s) =>
              PublicPage(path: '/public/${s.pathParameters['handle']}')),
      GoRoute(
          path: '/share/:token',
          builder: (_, s) =>
              PublicPage(path: '/share/${s.pathParameters['token']}')),
      for (final old in [
        'home',
        'dashboard',
        'profile',
        'cv-upload',
        'onboarding'
      ])
        GoRoute(path: '/$old', redirect: (_, __) => '/workspace')
    ]);
    Future.microtask(() => ref.read(workspaceProvider).initialize());
  }

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(workspaceProvider);
    return MaterialApp.router(
        title: 'Auctor · Proof of your craft',
        debugShowCheckedModeBanner: false,
        theme: theme(Brightness.light),
        darkTheme: theme(Brightness.dark),
        themeMode: c.theme,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                disableAnimations: c.reducedMotion ||
                    MediaQuery.of(context).disableAnimations),
            child: child!));
  }
}

ThemeData theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: pine, brightness: brightness)
      .copyWith(
          primary: dark ? const Color(0xffb5dcd0) : pine,
          secondary: champagne,
          surface: dark ? const Color(0xff192822) : const Color(0xfffffdf7));
  return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xff0c1815) : const Color(0xfff5f4ec),
      textTheme: Typography.material2021().black.apply(
          bodyColor: dark ? const Color(0xfff0f1e9) : const Color(0xff182821),
          displayColor:
              dark ? const Color(0xfff0f1e9) : const Color(0xff182821)),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: dark ? const Color(0xff20312a) : const Color(0xffeeefe7),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(18)),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)))),
      cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
      dividerColor: dark ? Colors.white12 : Colors.black12);
}

class AuctorMark extends StatelessWidget {
  final double size;
  const AuctorMark({super.key, this.size = 42});
  @override
  Widget build(BuildContext context) => Semantics(
      label: 'Auctor provenance mark',
      image: true,
      child: CustomPaint(size: Size.square(size), painter: _MarkPainter()));
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 128);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 128, 128), const Radius.circular(34)),
        Paint()..color = pine);
    final a = Path()
      ..moveTo(32, 91)
      ..lineTo(60, 30)
      ..lineTo(73, 30)
      ..lineTo(97, 91)
      ..lineTo(81, 91)
      ..lineTo(75, 74)
      ..lineTo(52, 74)
      ..lineTo(45, 91)
      ..close()
      ..moveTo(57, 61)
      ..lineTo(71, 61)
      ..lineTo(64, 42)
      ..close();
    a.fillType = PathFillType.evenOdd;
    canvas.drawPath(a, Paint()..color = const Color(0xfff3d5a0));
    canvas.drawPath(
        Path()
          ..moveTo(82, 43)
          ..lineTo(92, 53)
          ..lineTo(107, 35),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xfff4f5f0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Surface extends ConsumerWidget {
  final Widget child;
  final bool glass;
  final EdgeInsets padding;
  const Surface(
      {super.key,
      required this.child,
      this.glass = false,
      this.padding = const EdgeInsets.all(24)});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(workspaceProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final useGlass = glass && !c.reducedTransparency;
    final content = Container(
        padding: padding,
        decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surface
                .withValues(alpha: useGlass ? 0.76 : 1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color:
                    dark ? Colors.white12 : Colors.white.withValues(alpha: .8)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.12 : 0.025),
                  blurRadius: 32,
                  offset: const Offset(0, 12))
            ]),
        child: Material(type: MaterialType.transparency, child: child));
    return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: useGlass
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: content)
            : content);
  }
}

class Backdrop extends StatelessWidget {
  final Widget child;
  const Backdrop({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [
                        const Color(0xff0c1815),
                        const Color(0xff17322a),
                        const Color(0xff171e19)
                      ]
                    : [
                        const Color(0xfff4f3eb),
                        const Color(0xffe0eae0),
                        const Color(0xfff9efdd)
                      ])),
        child: child);
  }
}

class EntryPage extends ConsumerWidget {
  const EntryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(workspaceProvider);
    if (c.loading) {
      return const Scaffold(
          body: Backdrop(child: Center(child: CircularProgressIndicator())));
    }
    return c.workspace == null ? const WelcomePage() : const WorkspacePage();
  }
}

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});
  @override
  ConsumerState<WelcomePage> createState() => _WelcomeState();
}

class _WelcomeState extends ConsumerState<WelcomePage> {
  bool register = false;
  final email = TextEditingController(),
      password = TextEditingController(),
      name = TextEditingController(),
      handle = TextEditingController();
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    handle.dispose();
    super.dispose();
  }

  Widget auth(WorkspaceController c) => Surface(
      child: Form(
          key: form,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                register
                    ? 'Start your evidence journey'
                    : 'Welcome to your workspace',
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.7)),
            const SizedBox(height: 8),
            Text(register
                ? 'Build a profile that earns its credibility.'
                : 'Continue building proof of your craft.'),
            const SizedBox(height: 24),
            if (register) ...[
              TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Your name'),
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Enter your name' : null),
              const SizedBox(height: 12),
              TextFormField(
                  controller: handle,
                  decoration: const InputDecoration(labelText: 'Public handle'),
                  validator: (v) =>
                      !RegExp(r'^[a-z][a-z0-9-]{2,31}$').hasMatch(v ?? '')
                          ? '3–32 lowercase letters, numbers or hyphens'
                          : null),
              const SizedBox(height: 12)
            ],
            TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v?.contains('@') != true ? 'Enter an email' : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: password,
                obscureText: true,
                autofillHints: [
                  register ? AutofillHints.newPassword : AutofillHints.password
                ],
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) =>
                    (v ?? '').length < 10 ? 'At least 10 characters' : null),
            const SizedBox(height: 20),
            if (c.error != null) ErrorNotice(c.error!),
            const SizedBox(height: 8),
            SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: c.busy
                        ? null
                        : () {
                            if (form.currentState!.validate()) {
                              c.authenticate({
                                'email': email.text.trim(),
                                'password': password.text,
                                if (register) 'handle': handle.text.trim(),
                                if (register) 'display_name': name.text.trim()
                              }, register: register);
                            }
                          },
                    child: Text(c.busy
                        ? 'Connecting…'
                        : register
                            ? 'Create private workspace'
                            : 'Sign in'))),
            const SizedBox(height: 8),
            TextButton(
                onPressed: () => setState(() => register = !register),
                child: Text(register
                    ? 'Already have an account? Sign in'
                    : 'New here? Create an account')),
            const Divider(),
            const Text(
                'Your CV and proof files stay private. You decide what to share.',
                style: TextStyle(fontSize: 12))
          ])));
  @override
  Widget build(BuildContext context) {
    final c = ref.watch(workspaceProvider);
    return Scaffold(
        body: Backdrop(
            child: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Center(
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1250),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    const AuctorMark(),
                                    const SizedBox(width: 12),
                                    const Text('auctor',
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -1)),
                                    const Spacer(),
                                    PopupMenuButton<ThemeMode>(
                                        tooltip: 'Appearance',
                                        initialValue: c.theme,
                                        onSelected: (v) {
                                          c.previewTheme(v);
                                        },
                                        itemBuilder: (_) => [
                                              for (final v in ThemeMode.values)
                                                PopupMenuItem(
                                                    value: v,
                                                    child: Text(v.name))
                                            ],
                                        icon:
                                            const Icon(Icons.contrast_rounded))
                                  ]),
                                  const SizedBox(height: 68),
                                  LayoutBuilder(builder: (context, box) {
                                    final hero = Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Chip(
                                              label:
                                                  Text('PROOF OF YOUR CRAFT')),
                                          const SizedBox(height: 24),
                                          Text(
                                              'Let your work\nspeak beautifully.',
                                              style: TextStyle(
                                                  fontSize: box.maxWidth > 850
                                                      ? 66
                                                      : 44,
                                                  height: 1.05,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: -2.5)),
                                          const SizedBox(height: 24),
                                          const Text(
                                              'A considered home for your developer identity.\nTurn your CV, repositories and assessed skills into\na clear, honest story of what you can do.',
                                              style: TextStyle(
                                                  fontSize: 18, height: 1.6)),
                                          const SizedBox(height: 32),
                                          const Wrap(
                                              spacing: 12,
                                              runSpacing: 12,
                                              children: [
                                                Chip(
                                                    avatar: Icon(
                                                        Icons.lock_outline,
                                                        size: 16),
                                                    label: Text(
                                                        'Private by default')),
                                                Chip(
                                                    avatar: Icon(
                                                        Icons
                                                            .account_tree_outlined,
                                                        size: 16),
                                                    label: Text(
                                                        'Evidence with provenance')),
                                                Chip(
                                                    avatar: Icon(
                                                        Icons.insights_outlined,
                                                        size: 16),
                                                    label: Text(
                                                        'Transparent score'))
                                              ]),
                                          const SizedBox(height: 32),
                                          Surface(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                const Text(
                                                    'A simple path to a stronger profile',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                const SizedBox(height: 16),
                                                for (final item in [
                                                  (
                                                    '01',
                                                    'Bring your story',
                                                    'Upload a CV and review what was extracted.'
                                                  ),
                                                  (
                                                    '02',
                                                    'Connect the evidence',
                                                    'Prove repository ownership and assess skills.'
                                                  ),
                                                  (
                                                    '03',
                                                    'Share with intention',
                                                    'Create a public profile or a revocable link.'
                                                  )
                                                ])
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10),
                                                      child: Row(children: [
                                                        Text(item.$1,
                                                            style:
                                                                const TextStyle(
                                                                    color:
                                                                        champagne,
                                                                    fontSize:
                                                                        20)),
                                                        const SizedBox(
                                                            width: 16),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(item.$2,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600)),
                                                              Text(item.$3)
                                                            ]))
                                                      ]))
                                              ]))
                                        ]);
                                    return box.maxWidth > 850
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                Expanded(flex: 6, child: hero),
                                                const SizedBox(width: 60),
                                                Expanded(
                                                    flex: 4, child: auth(c))
                                              ])
                                        : Column(children: [
                                            hero,
                                            const SizedBox(height: 28),
                                            auth(c)
                                          ]);
                                  }),
                                  const SizedBox(height: 50),
                                  const Text(
                                      'Evidence is contextual. Auctor records claims, sources and assessment results; it does not guarantee employment or hiring outcomes.',
                                      style:
                                          TextStyle(fontSize: 12, height: 1.6))
                                ])))))));
  }
}

class ErrorNotice extends StatelessWidget {
  final String message;
  const ErrorNotice(this.message, {super.key});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16)),
      child: Text(message,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer)));
}

const destinations = [
  ('Overview', Icons.space_dashboard_outlined),
  ('Evidence', Icons.layers_outlined),
  ('Challenges', Icons.verified_outlined),
  ('Activity', Icons.notifications_none_rounded),
  ('Discover', Icons.people_outline),
  ('Profile', Icons.person_outline),
  ('Reviews', Icons.fact_check_outlined)
];

class WorkspacePage extends ConsumerStatefulWidget {
  const WorkspacePage({super.key});
  @override
  ConsumerState<WorkspacePage> createState() => _WorkspaceState();
}

class _WorkspaceState extends ConsumerState<WorkspacePage> {
  Timer? poll;
  @override
  void initState() {
    super.initState();
    poll = Timer.periodic(const Duration(seconds: 4), (_) {
      final c = ref.read(workspaceProvider);
      if (c
              .list('documents')
              .any((d) => ['queued', 'running'].contains(d['status'])) &&
          !c.busy) {
        c.run(c.refresh);
      }
    });
  }

  @override
  void dispose() {
    poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(workspaceProvider);
    final nav =
        destinations.take(c.profile['role'] == 'reviewer' ? 7 : 6).toList();
    final current = c.destination < nav.length ? c.destination : 0;
    final page = switch (current) {
      0 => const OverviewPane(),
      1 => const EvidencePane(),
      2 => const ChallengesPane(),
      3 => const ActivityPane(),
      4 => const DiscoverPane(),
      5 => const ProfilePane(),
      _ => const ReviewsPane()
    };
    return Scaffold(body:
        Backdrop(child: SafeArea(child: LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= 1000;
      return Row(children: [
        if (wide)
          Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                  width: 230,
                  child: Surface(
                      glass: true,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              AuctorMark(),
                              SizedBox(width: 12),
                              Expanded(
                                  child: Text('auctor',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -1)))
                            ]),
                            const SizedBox(height: 40),
                            for (final item in nav.asMap().entries)
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      selected: current == item.key,
                                      selectedTileColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: .12),
                                      leading: Icon(item.value.$2),
                                      title: Text(item.value.$1),
                                      onTap: () => c.select(item.key))),
                            const Spacer(),
                            const Text('PROOF, WITH CONTEXT',
                                style: TextStyle(
                                    fontSize: 10, letterSpacing: 1.8)),
                            const SizedBox(height: 12),
                            Text('@${c.profile['handle']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            TextButton.icon(
                                onPressed: c.busy ? null : c.logout,
                                icon: const Icon(Icons.logout, size: 16),
                                label: const Text('Sign out'))
                          ])))),
        Expanded(
            child: Column(children: [
          Padding(
              padding: EdgeInsets.fromLTRB(wide ? 12 : 20, 24, 24, 16),
              child: Row(children: [
                if (!wide) ...[
                  const AuctorMark(size: 32),
                  const SizedBox(width: 12)
                ],
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(destinations[current].$1,
                          style: const TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.8)),
                      Text('Your craft. Your evidence. Your story.',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant))
                    ])),
                if (c.busy)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                IconButton(
                    tooltip: 'Refresh workspace',
                    onPressed: c.busy ? null : () => c.run(c.refresh),
                    icon: const Icon(Icons.refresh)),
                PopupMenuButton<ThemeMode>(
                    tooltip: 'Appearance',
                    onSelected: (v) => c.preferences(mode: v),
                    itemBuilder: (_) => [
                          for (final v in ThemeMode.values)
                            PopupMenuItem(value: v, child: Text(v.name))
                        ],
                    icon: const Icon(Icons.contrast)),
                if (!wide)
                  IconButton(
                      tooltip: 'Sign out',
                      onPressed: c.logout,
                      icon: const Icon(Icons.logout))
              ])),
          Expanded(
              child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(wide ? 12 : 20, 8, 24, 32),
                  child: Center(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(children: [
                            if (c.error != null) ErrorNotice(c.error!),
                            AnimatedSwitcher(
                                duration:
                                    MediaQuery.of(context).disableAnimations
                                        ? Duration.zero
                                        : const Duration(milliseconds: 260),
                                child: KeyedSubtree(
                                    key: ValueKey(current), child: page))
                          ]))))),
          if (!wide)
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Surface(
                    glass: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (final item in nav.asMap().entries)
                            Expanded(
                                child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () => c.select(item.key),
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(item.value.$2,
                                                  color: current == item.key
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant),
                                              const SizedBox(height: 4),
                                              Text(item.value.$1,
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: current ==
                                                              item.key
                                                          ? FontWeight.w700
                                                          : FontWeight.w400))
                                            ]))))
                        ])))
        ]))
      ]);
    }))));
  }
}

class SectionTitle extends StatelessWidget {
  final String title, subtitle;
  final Widget? trailing;
  const SectionTitle(this.title,
      {super.key, this.subtitle = '', this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 18),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.6)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(subtitle,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4))
          ]
        ])),
        if (trailing != null) trailing!
      ]));
}

class EmptyState extends StatelessWidget {
  final String title, body;
  final Widget? action;
  const EmptyState(this.title, this.body, {super.key, this.action});
  @override
  Widget build(BuildContext context) => Surface(
          child: Column(children: [
        const Icon(Icons.blur_on_rounded, size: 40, color: champagne),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(body,
            textAlign: TextAlign.center, style: const TextStyle(height: 1.5)),
        if (action != null) ...[const SizedBox(height: 20), action!]
      ]));
}

class OverviewPane extends ConsumerWidget {
  const OverviewPane({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(workspaceProvider);
    final score = (c.score['total'] as num).toDouble();
    final components = Map<String, dynamic>.from(c.score['components']);
    final passed = c
        .list('badges')
        .where((b) => b['passed'] == true)
        .map((b) => b['badge_id'])
        .toSet();
    final github =
        Map<String, dynamic>.from(c.profile['github_identity'] ?? {});
    final repos = List<Map<String, dynamic>>.from(
        (github['repositories'] as List? ?? [])
            .map((r) => Map<String, dynamic>.from(r)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle('A clearer picture of your craft',
          subtitle:
              'Welcome back, ${c.profile['display_name']}. Every point has a source.'),
      LayoutBuilder(builder: (context, box) {
        final summary = Surface(
            child: Row(children: [
          SizedBox(
              width: 125,
              height: 125,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox.expand(
                    child: CircularProgressIndicator(
                        value: score / 10,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: champagne.withValues(alpha: .18),
                        color: champagne)),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(score.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 38, fontWeight: FontWeight.w500)),
                  const Text('OUT OF 10',
                      style: TextStyle(fontSize: 9, letterSpacing: 2))
                ])
              ])),
          const SizedBox(width: 24),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Auctor score',
                    style:
                        TextStyle(fontSize: 23, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text(
                    'A transparent summary of evidence.\nFormula v1 • five weighted signals',
                    style: TextStyle(height: 1.5)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  Chip(label: Text('${passed.length} badges')),
                  Chip(label: Text('${c.cv['projects'].length} projects'))
                ])
              ]))
        ]));
        final breakdown = Surface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('What contributes',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          for (final entry in components.entries)
            Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  SizedBox(width: 86, child: Text(entry.key)),
                  Expanded(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                              value:
                                  (entry.value['fraction'] as num).toDouble(),
                              minHeight: 6,
                              color: champagne,
                              backgroundColor:
                                  champagne.withValues(alpha: .15)))),
                  const SizedBox(width: 12),
                  Text(
                      '${entry.value['points']} / ${(entry.value['weight'] as num) * 10}',
                      style: const TextStyle(fontSize: 11))
                ]))
        ]));
        return box.maxWidth > 750
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: summary),
                const SizedBox(width: 18),
                Expanded(child: breakdown)
              ])
            : Column(
                children: [summary, const SizedBox(height: 18), breakdown]);
      }),
      const SizedBox(height: 28),
      const SectionTitle('Your next meaningful step',
          subtitle: 'Build evidence where it changes the story.'),
      Wrap(spacing: 16, runSpacing: 16, children: [
        _ActionCard('Bring your CV', 'Upload, review and refine your claims.',
            Icons.upload_file_outlined, () => c.select(1)),
        _ActionCard(
            'Assess your skills',
            'Five-minute, server-graded challenges.',
            Icons.verified_outlined,
            () => c.select(2)),
        _ActionCard(
            'Share your story',
            'A polished profile with privacy controls.',
            Icons.ios_share_rounded,
            () => c.select(5))
      ]),
      const SizedBox(height: 28),
      const SectionTitle('Skill roadmap',
          subtitle:
              'Skills from your latest CV, paired with available assessments.'),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ((c.cv['skills'] as List).isEmpty)
          const Text('Add a CV to see your personal roadmap.'),
        for (final skill in (c.cv['skills'] as List))
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Icon(
                    passed.any((b) => skill
                            .toString()
                            .toLowerCase()
                            .contains(b.toString().split('-')[0]))
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: champagne),
                const SizedBox(width: 12),
                Expanded(child: Text(skill.toString())),
                TextButton(
                    onPressed: () => c.select(2), child: const Text('Assess'))
              ]))
      ])),
      const SizedBox(height: 28),
      SectionTitle('Repository intelligence',
          subtitle: github.isEmpty
              ? 'Connect GitHub to confirm account ownership.'
              : 'Snapshot ${dateLabel(github['synced_at'])} • public repositories you own'),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(
                  github.isEmpty
                      ? 'Connect the source of your work'
                      : '@${github['login']}',
                  style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w600))),
          FilledButton.tonalIcon(
              onPressed: c.busy
                  ? null
                  : () => c.run(() async {
                        final result =
                            await c.api.call('/github/connect', method: 'POST');
                        await openLink(result['url']);
                      }),
              icon: const Icon(Icons.link),
              label: Text(
                  github.isEmpty ? 'Connect GitHub' : 'Refresh connection'))
        ]),
        const SizedBox(height: 16),
        Text(github.isEmpty
            ? 'OAuth proves you control the account. An extracted URL or a public username does not.'
            : '${repos.length} public owned repositories • ${repos.fold<int>(0, (sum, r) => sum + (r['stars'] as num).toInt())} stars'),
        if (github['recent_activity'] != null) ...[
          const SizedBox(height: 12),
          Text(
              '${(github['recent_activity'] as List).length} recent public events · ${(github['recent_activity'] as List).where((e) => e['type'] == 'PushEvent').length} push events'),
          Text(github['activity_scope'] ?? '',
              style: const TextStyle(fontSize: 11)),
        ],
        if (repos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: repos
                  .map((r) => ActionChip(
                      label: Text('${r['name']} · ${r['language'] ?? 'Mixed'}'),
                      onPressed: () => openLink(r['url'])))
                  .toList()),
          const SizedBox(height: 12),
          const Text(
              'Repository ownership is provenance; it is not an assessment of code quality.',
              style: TextStyle(fontSize: 12))
        ]
      ]))
    ]);
  }
}

class _ActionCard extends StatelessWidget {
  final String title, body;
  final IconData icon;
  final VoidCallback action;
  const _ActionCard(this.title, this.body, this.icon, this.action);
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 290,
      child: Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: champagne, size: 28),
        const SizedBox(height: 18),
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(body),
        const SizedBox(height: 10),
        TextButton.icon(
            onPressed: action,
            label: const Text('Open'),
            icon: const Icon(Icons.arrow_forward, size: 16))
      ])));
}

String dateLabel(dynamic value) {
  if (value == null) return '';
  try {
    final d = DateTime.parse(value.toString()).toLocal();
    return '${d.day.toString().padLeft(2, '0')} ${const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][d.month - 1]} ${d.year}';
  } catch (_) {
    return value.toString();
  }
}

Future<void> openLink(String value) async {
  final uri = Uri.tryParse(value);
  if (uri == null || !['https', 'http', 'mailto'].contains(uri.scheme)) {
    throw ApiFailure('Invalid link', 0);
  }
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw ApiFailure('Could not open the link', 0);
  }
}

Future<void> download(PlatformApi api, String path, String name) async {
  final bytes = await api.bytes(path);
  final destination = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Auctor report',
      fileName: name,
      type: FileType.custom,
      allowedExtensions: [name.split('.').last],
      bytes: bytes);
  await completeSave(destination, bytes);
}

class EvidencePane extends ConsumerWidget {
  const EvidencePane({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(workspaceProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle('A library of your evidence',
          subtitle:
              'Your claims and supporting sources, kept in one considered place.',
          trailing: FilledButton.icon(
              onPressed: c.busy ? null : () => uploadCv(c),
              icon: const Icon(Icons.add),
              label: const Text('Upload CV'))),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(
              child: Text('Your current CV',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600))),
          TextButton.icon(
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => CvEditor(
                      data: c.cv,
                      onSave: (data) => c.mutate('/cv', method: 'PUT', data: {
                            'data': data,
                            'note': 'CV reviewed and edited'
                          }))),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Review & edit'))
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final skill in c.cv['skills'])
            Chip(label: Text(skill.toString()))
        ]),
        if ((c.cv['skills'] as List).isEmpty)
          const Text('Upload a PDF or create your CV manually.'),
        const SizedBox(height: 18),
        for (final p in c.cv['projects'])
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.code, color: champagne),
              title: Text(p['name']),
              subtitle: Text(p['description'] ?? '')),
        for (final e in c.cv['experience'])
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.work_outline, color: champagne),
              title: Text('${e['role']} · ${e['company']}'),
              subtitle: Text(e['duration'] ?? '')),
        const Divider(),
        const Text(
            'Extraction produces unverified claims. Review the original file and correct anything that was missed.',
            style: TextStyle(fontSize: 12, height: 1.5))
      ])),
      if (c.list('documents').isNotEmpty) ...[
        const SizedBox(height: 24),
        const SectionTitle('Extraction jobs'),
        for (final doc in c.list('documents'))
          Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Surface(
                  child: Row(children: [
                Icon(
                    doc['status'] == 'succeeded'
                        ? Icons.check_circle_outline
                        : Icons.description_outlined,
                    color: champagne),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(doc['filename'],
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                          '${doc['status']} · ${dateLabel(doc['created_at'])}'),
                      if (doc['error'] != null) Text(doc['error']),
                      if ((doc['source'] as Map?)?.isNotEmpty == true)
                        Text(
                            '${doc['source']['parser']} · ${doc['source']['confidence']}',
                            style: const TextStyle(fontSize: 11))
                    ])),
                if (['queued', 'running'].contains(doc['status']))
                  TextButton(
                      onPressed: () => c.mutate('/cv/jobs/${doc['id']}/cancel'),
                      child: const Text('Cancel')),
                if (['failed', 'cancelled'].contains(doc['status']))
                  TextButton(
                      onPressed: () => c.mutate('/cv/jobs/${doc['id']}/retry'),
                      child: const Text('Retry')),
                IconButton(
                    tooltip: 'Download original CV source',
                    onPressed: () => c.run(() => download(
                        c.api, '/cv/jobs/${doc['id']}/file', 'cv-source.pdf')),
                    icon: const Icon(Icons.download_outlined))
              ])))
      ],
      const SizedBox(height: 24),
      SectionTitle('Supporting proof',
          subtitle:
              'Evidence is verified by ownership or an independent review.',
          trailing: FilledButton.tonalIcon(
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => EvidenceEditor(controller: c)),
              icon: const Icon(Icons.add),
              label: const Text('Add evidence'))),
      if (c.list('evidence').isEmpty)
        const EmptyState('Make your work tangible',
            'Link an owned repository, import a coding profile, or submit experience and certificate proof.'),
      for (final e in c.list('evidence'))
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Surface(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(e['title'],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          Text('${e['kind']} · ${dateLabel(e['updated_at'])}')
                        ])),
                    Chip(label: Text(e['status']))
                  ]),
                  if ((e['review_note'] ?? '').toString().isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('Review: ${e['review_note']}')),
                  Wrap(spacing: 8, children: [
                    if ((e['url'] ?? '').toString().isNotEmpty)
                      TextButton.icon(
                          onPressed: () => c.run(() => openLink(e['url'])),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Source')),
                    if (!['project', 'github'].contains(e['kind']) &&
                        e['status'] != 'verified')
                      TextButton.icon(
                          onPressed: () => attachProof(c, e['id']),
                          icon:
                              const Icon(Icons.upload_file_outlined, size: 16),
                          label: const Text('Attach PDF proof')),
                    if (!['project', 'github'].contains(e['kind']))
                      TextButton.icon(
                          onPressed: () => c.run(() => download(c.api,
                              '/evidence/${e['id']}/file', 'evidence.pdf')),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Download proof')),
                    TextButton(
                        onPressed: () => confirmDelete(context, c, e),
                        child: const Text('Remove'))
                  ])
                ]))),
      const SizedBox(height: 24),
      const SectionTitle('CV history',
          subtitle: 'Compare changes and restore a previous revision.'),
      if (c.list('versions').isEmpty)
        const Text('Your first saved CV creates a version.'),
      for (final v in c.list('versions'))
        Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Surface(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(v['note'],
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(dateLabel(v['created_at']))
                      ])),
                  TextButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (_) => VersionComparison(
                              current: c.cv,
                              previous: Map<String, dynamic>.from(v['data']))),
                      child: const Text('Compare')),
                  TextButton(
                      onPressed: () =>
                          c.mutate('/cv/versions/${v['id']}/restore'),
                      child: const Text('Restore'))
                ])))
    ]);
  }
}

Future<void> uploadCv(WorkspaceController c) => c.run(() async {
      final selected = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
      if (selected == null) return;
      final f = selected.files.single;
      if (f.bytes == null) throw ApiFailure('Could not read that PDF', 0);
      await c.api.upload('/cv/jobs', f.bytes!, f.name);
      await c.refresh();
    });
Future<void> attachProof(WorkspaceController c, String id) => c.run(() async {
      final selected = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
      if (selected == null) return;
      final f = selected.files.single;
      if (f.bytes == null) throw ApiFailure('Could not read that PDF', 0);
      await c.api.upload('/evidence/$id/file', f.bytes!, f.name);
      await c.refresh();
    });
Future<void> confirmDelete(
    BuildContext context, WorkspaceController c, Map<String, dynamic> e) async {
  final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
              title: const Text('Remove this evidence?'),
              content: const Text(
                  'Your score is recalculated from the remaining sources.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Keep')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Remove'))
              ]));
  if (yes == true) {
    await c.mutate(e['kind'] == 'github' ? '/github' : '/evidence/${e['id']}',
        method: 'DELETE');
  }
}

class CvEditor extends StatefulWidget {
  final Map<String, dynamic> data;
  final Future<void> Function(Map<String, dynamic>) onSave;
  const CvEditor({super.key, required this.data, required this.onSave});
  @override
  State<CvEditor> createState() => _CvEditorState();
}

class _CvEditorState extends State<CvEditor> {
  late Map<String, dynamic> data;
  late TextEditingController skills;
  bool saving = false;
  @override
  void initState() {
    super.initState();
    data = jsonDecode(jsonEncode(widget.data));
    skills = TextEditingController(text: (data['skills'] as List).join(', '));
  }

  @override
  void dispose() {
    skills.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Review your story'),
          content: SizedBox(
              width: 650,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text(
                        'Edit extracted claims before connecting evidence. Verification is recorded separately.'),
                    const SizedBox(height: 18),
                    TextField(
                        controller: skills,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            labelText: 'Skills, separated by commas')),
                    const SizedBox(height: 18),
                    const Text('Projects',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    for (final entry
                        in (data['projects'] as List).asMap().entries)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(children: [
                            TextFormField(
                                initialValue: entry.value['name'],
                                decoration: const InputDecoration(
                                    labelText: 'Project name'),
                                onChanged: (v) => entry.value['name'] = v),
                            const SizedBox(height: 8),
                            TextFormField(
                                initialValue: entry.value['description'],
                                maxLines: 2,
                                decoration: const InputDecoration(
                                    labelText: 'What you built'),
                                onChanged: (v) =>
                                    entry.value['description'] = v),
                            TextButton(
                                onPressed: () => setState(() =>
                                    (data['projects'] as List)
                                        .removeAt(entry.key)),
                                child: const Text('Remove project'))
                          ])),
                    TextButton.icon(
                        onPressed: () => setState(() =>
                            (data['projects'] as List).add({
                              'name': '',
                              'description': '',
                              'tech_stack': [],
                              'is_verified': false
                            })),
                        icon: const Icon(Icons.add),
                        label: const Text('Add project')),
                    const SizedBox(height: 16),
                    const Text('Experience',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    for (final entry
                        in (data['experience'] as List).asMap().entries)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(children: [
                            for (final key in ['company', 'role', 'duration'])
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TextFormField(
                                      initialValue: entry.value[key] ?? '',
                                      decoration:
                                          InputDecoration(labelText: key),
                                      onChanged: (v) => entry.value[key] = v)),
                            TextButton(
                                onPressed: () => setState(() =>
                                    (data['experience'] as List)
                                        .removeAt(entry.key)),
                                child: const Text('Remove experience'))
                          ])),
                    TextButton.icon(
                        onPressed: () => setState(() =>
                            (data['experience'] as List).add({
                              'company': '',
                              'role': '',
                              'duration': '',
                              'is_verified': false
                            })),
                        icon: const Icon(Icons.add),
                        label: const Text('Add experience')),
                    const SizedBox(height: 16),
                    const Text('Profile links',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    for (final key in [
                      'github',
                      'linkedin',
                      'leetcode',
                      'portfolio'
                    ])
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: TextFormField(
                              initialValue: data['profiles'][key] ?? '',
                              decoration: InputDecoration(labelText: key),
                              onChanged: (v) => data['profiles'][key] = v))
                  ]))),
          actions: [
            TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        data['skills'] = skills.text
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toSet()
                            .toList();
                        if ((data['projects'] as List).any(
                                (p) => p['name'].toString().trim().isEmpty) ||
                            (data['experience'] as List).any((p) =>
                                p['company'].toString().trim().isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Name every project and employer before saving')));
                          return;
                        }
                        setState(() => saving = true);
                        await widget.onSave(data);
                        if (context.mounted) Navigator.pop(context);
                      },
                child: Text(saving ? 'Saving…' : 'Save reviewed CV'))
          ]);
}

class VersionComparison extends StatelessWidget {
  final Map<String, dynamic> current, previous;
  const VersionComparison(
      {super.key, required this.current, required this.previous});
  @override
  Widget build(BuildContext context) {
    final now = (current['skills'] as List).toSet(),
        then = (previous['skills'] as List).toSet();
    return AlertDialog(
        title: const Text('Revision comparison'),
        content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      'Skills added since this revision: ${now.difference(then).join(', ')}'),
                  const SizedBox(height: 12),
                  Text(
                      'Skills removed since this revision: ${then.difference(now).join(', ')}'),
                  const SizedBox(height: 18),
                  Text(
                      'Previous projects: ${(previous['projects'] as List).map((p) => p['name']).join(', ')}'),
                  const SizedBox(height: 12),
                  Text(
                      'Current projects: ${(current['projects'] as List).map((p) => p['name']).join(', ')}')
                ]))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ]);
  }
}

class EvidenceEditor extends StatefulWidget {
  final WorkspaceController controller;
  const EvidenceEditor({super.key, required this.controller});
  @override
  State<EvidenceEditor> createState() => _EvidenceEditorState();
}

class _EvidenceEditorState extends State<EvidenceEditor> {
  String kind = 'experience';
  String? repository, project;
  final title = TextEditingController(),
      url = TextEditingController(),
      solved = TextEditingController();
  bool saving = false;
  String? error;
  @override
  void dispose() {
    title.dispose();
    url.dispose();
    solved.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final repos =
        (c.profile['github_identity']?['repositories'] as List? ?? []);
    final projects = c.cv['projects'] as List;
    return AlertDialog(
        title: const Text('Add supporting evidence'),
        content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
                child: Column(children: [
              if (error != null) ErrorNotice(error!),
              DropdownButtonFormField<String>(
                  initialValue: kind,
                  decoration: const InputDecoration(labelText: 'Evidence type'),
                  items: [
                    for (final value in [
                      'experience',
                      'certificate',
                      'coding',
                      'project'
                    ])
                      DropdownMenuItem(value: value, child: Text(value))
                  ],
                  onChanged: (v) => setState(() => kind = v!)),
              const SizedBox(height: 12),
              TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              if (kind == 'project') ...[
                DropdownButtonFormField<String>(
                    initialValue: project,
                    decoration: const InputDecoration(labelText: 'CV project'),
                    items: [
                      for (final p in projects)
                        DropdownMenuItem(
                            value: p['name'].toString(), child: Text(p['name']))
                    ],
                    onChanged: (v) => project = v),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                    initialValue: repository,
                    decoration:
                        const InputDecoration(labelText: 'Owned repository'),
                    items: [
                      for (final r in repos)
                        DropdownMenuItem(
                            value: r['full_name'].toString(),
                            child: Text(r['name']))
                    ],
                    onChanged: (v) => repository = v),
                if (repos.isEmpty)
                  const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                          'Connect GitHub on Overview before linking a project.'))
              ] else ...[
                TextField(
                    controller: url,
                    keyboardType: TextInputType.url,
                    decoration:
                        const InputDecoration(labelText: 'Source URL (HTTPS)')),
                if (kind == 'coding') ...[
                  const SizedBox(height: 12),
                  TextField(
                      controller: solved,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Solved problems claimed'))
                ],
                const SizedBox(height: 12),
                const Text(
                    'This enters independent review. Attach a private PDF after creating the submission. Imported counts remain unverified until reviewed.',
                    style: TextStyle(fontSize: 12, height: 1.5))
              ]
            ]))),
        actions: [
          TextButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (title.text.trim().isEmpty) {
                        setState(() => error = 'Add a title');
                        return;
                      }
                      if (kind == 'project' &&
                          (repository == null || project == null)) {
                        setState(() => error =
                            'Choose your CV project and owned repository');
                        return;
                      }
                      setState(() => saving = true);
                      try {
                        await c.api.call('/evidence', method: 'POST', data: {
                          'kind': kind,
                          'title': title.text.trim(),
                          'url': kind == 'project'
                              ? (repos.firstWhere(
                                  (r) => r['full_name'] == repository)['url'])
                              : url.text.trim(),
                          'detail': {
                            'claimed': true,
                            if (kind == 'coding')
                              'solved': int.tryParse(solved.text) ?? 0,
                            if (kind == 'project') 'repository': repository,
                            if (kind == 'project') 'project': project
                          }
                        });
                        await c.refresh();
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        setState(() {
                          saving = false;
                          error = e.toString();
                        });
                      }
                    },
              child: Text(saving ? 'Saving…' : 'Add evidence'))
        ]);
  }
}

class ChallengesPane extends ConsumerStatefulWidget {
  const ChallengesPane({super.key});
  @override
  ConsumerState<ChallengesPane> createState() => _ChallengesState();
}

class _ChallengesState extends ConsumerState<ChallengesPane> {
  List<dynamic>? items;
  String? error;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        final data = await ref.read(workspaceProvider).api.call('/challenges');
        if (mounted) setState(() => items = data);
      } catch (e) {
        if (mounted) setState(() => error = e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(workspaceProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('Put your skills into practice',
          subtitle:
              'Five minutes. Five questions. Results graded on the server.'),
      if (error != null) ErrorNotice(error!),
      if (items == null && error == null)
        const Center(child: CircularProgressIndicator()),
      Wrap(spacing: 16, runSpacing: 16, children: [
        for (final item in items ?? [])
          SizedBox(
              width: 330,
              child: Surface(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Icon(Icons.verified_outlined,
                        color: champagne, size: 32),
                    const SizedBox(height: 20),
                    Text(item['name'],
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                        '${item['questions']} questions · 5 min\nPass ${item['pass_threshold']} or more to earn a badge.',
                        style: const TextStyle(height: 1.5)),
                    const SizedBox(height: 20),
                    FilledButton.tonal(
                        onPressed: () => showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => ChallengeDialog(
                                api: c.api,
                                badge: item,
                                onComplete: c.refresh)),
                        child: const Text('Start challenge'))
                  ])))
      ]),
      const SizedBox(height: 28),
      const SectionTitle('Assessment history',
          subtitle: 'A later failed attempt never removes an earned badge.'),
      if (c.list('badges').isEmpty)
        const EmptyState('Your first assessment awaits',
            'Choose a topic above. Completion and score changes are recorded honestly.'),
      for (final attempt in c.list('badges'))
        Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Surface(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Icon(
                      attempt['passed'] == true
                          ? Icons.check_circle_outline
                          : Icons.history,
                      color: champagne),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Text(
                          '${attempt['badge_id']} · ${dateLabel(attempt['started_at'])}')),
                  Text(attempt['submitted_at'] == null
                      ? 'Started'
                      : '${attempt['correct_count']}/5 · ${attempt['passed'] == true ? 'Passed' : 'Practice'}'),
                  const SizedBox(width: 12),
                  Text(attempt['score_delta'] == null
                      ? ''
                      : ' +${attempt['score_delta']}')
                ])))
    ]);
  }
}

class ChallengeDialog extends StatefulWidget {
  final PlatformApi api;
  final dynamic badge;
  final Future<void> Function() onComplete;
  const ChallengeDialog(
      {super.key,
      required this.api,
      required this.badge,
      required this.onComplete});
  @override
  State<ChallengeDialog> createState() => _ChallengeState();
}

class _ChallengeState extends State<ChallengeDialog> {
  Map<String, dynamic>? attempt, result;
  String? error;
  final answers = <String, int>{};
  Timer? clock;
  int remaining = 300;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    start();
  }

  Future<void> start() async {
    try {
      final a = Map<String, dynamic>.from(await widget.api
          .call('/challenges/${widget.badge['id']}/attempts', method: 'POST'));
      if (!mounted) return;
      setState(() => attempt = a);
      tick();
      clock = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  void tick() {
    if (!mounted || attempt == null) return;
    setState(() => remaining = DateTime.parse(attempt!['expires_at'])
        .difference(DateTime.now())
        .inSeconds
        .clamp(0, 300));
  }

  @override
  void dispose() {
    clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Row(children: [
            Expanded(child: Text(widget.badge['name'])),
            if (result == null)
              Text(
                  '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18, color: champagne))
          ]),
          content: SizedBox(
              width: 650,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (error != null) ErrorNotice(error!),
                    if (attempt == null && error == null)
                      const Center(child: CircularProgressIndicator()),
                    if (remaining == 0 && result == null)
                      const Text(
                          'Time expired. Close this assessment and start a fresh attempt.'),
                    if (result != null) ...[
                      Icon(
                          result!['passed']
                              ? Icons.verified
                              : Icons.school_outlined,
                          size: 56,
                          color: champagne),
                      const SizedBox(height: 20),
                      Text(
                          result!['passed']
                              ? 'Evidence earned. Well done.'
                              : 'A useful signal for your next practice.',
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Text(
                          '${result!['correct_count']}/5 correct. Actual score change: +${result!['score_delta']}.',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      const Text(
                          'Assessment results measure these questions, rather than comprehensive professional competency.')
                    ] else if (attempt != null)
                      for (final question in attempt!['questions'])
                        Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(question['prompt'],
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  for (final option
                                      in (question['options'] as List)
                                          .asMap()
                                          .entries)
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                                backgroundColor:
                                                    answers[question['id'].toString()] ==
                                                            option.key
                                                        ? champagne.withValues(
                                                            alpha: .18)
                                                        : null,
                                                alignment: Alignment.centerLeft,
                                                minimumSize: const Size(
                                                    double.infinity, 44)),
                                            onPressed: remaining == 0 || busy
                                                ? null
                                                : () =>
                                                    setState(() => answers[question['id'].toString()] = option.key),
                                            child: Text(option.value.toString())))
                                ]))
                  ]))),
          actions: [
            TextButton(
                onPressed: busy ? null : () => Navigator.pop(context),
                child: Text(result == null ? 'Close' : 'Done')),
            if (attempt != null && result == null)
              FilledButton(
                  onPressed: busy || remaining == 0 || answers.length != 5
                      ? null
                      : () async {
                          setState(() => busy = true);
                          try {
                            final r = Map<String, dynamic>.from(await widget.api
                                .call('/attempts/${attempt!['id']}/submit',
                                    method: 'POST',
                                    data: {'answers': answers}));
                            await widget.onComplete();
                            if (mounted) setState(() => result = r);
                            clock?.cancel();
                          } catch (e) {
                            if (mounted) setState(() => error = e.toString());
                          } finally {
                            if (mounted) setState(() => busy = false);
                          }
                        },
                  child: Text(busy ? 'Grading…' : 'Submit answers'))
          ]);
}

class ActivityPane extends ConsumerWidget {
  const ActivityPane({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(workspaceProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle('The progress behind your profile',
          subtitle: 'An honest record of changes and assessments.',
          trailing: TextButton(
              onPressed: () => c.mutate('/activity/read'),
              child: const Text('Mark all read'))),
      for (final event in c.list('activity'))
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Surface(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  Icon(
                      event['read'] == true
                          ? Icons.check_circle_outline
                          : Icons.circle_notifications_outlined,
                      color: champagne),
                  const SizedBox(width: 18),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(event['message'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text(
                            '${event['kind']} · ${dateLabel(event['created_at'])}',
                            style: const TextStyle(fontSize: 12))
                      ]))
                ]))),
      const SizedBox(height: 24),
      const SectionTitle('Score evolution',
          subtitle: 'Only genuine signal changes create a new score snapshot.'),
      for (final snapshot in c.list('history'))
        Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Surface(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Text('${snapshot['score']['total']}',
                      style: const TextStyle(
                          fontSize: 25,
                          color: champagne,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 20),
                  Expanded(child: Text(snapshot['reason'])),
                  Text(dateLabel(snapshot['created_at']))
                ])))
    ]);
  }
}

class ProfilePane extends ConsumerStatefulWidget {
  const ProfilePane({super.key});
  @override
  ConsumerState<ProfilePane> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<ProfilePane> {
  TextEditingController? name, bio;
  bool? discoverable;
  @override
  void dispose() {
    name?.dispose();
    bio?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(workspaceProvider);
    name ??= TextEditingController(text: c.profile['display_name']);
    bio ??= TextEditingController(text: c.profile['bio']);
    discoverable ??= c.profile['discoverable'] == true;
    final publicUrl = '${shareOrigin()}/#/public/${c.profile['handle']}';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('A profile that feels like you',
          subtitle: 'A clear identity, with deliberate sharing choices.'),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const AuctorMark(size: 68),
          const SizedBox(width: 20),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(c.profile['display_name'],
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w600)),
                Text('@${c.profile['handle']}')
              ]))
        ]),
        const SizedBox(height: 24),
        TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Display name')),
        const SizedBox(height: 12),
        TextField(
            controller: bio,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(labelText: 'Your story')),
        SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Discoverable public profile'),
            subtitle: const Text(
                'Show reviewed evidence and assessments to recruiters. Contact details and proof files stay private.'),
            value: discoverable!,
            onChanged: (v) => setState(() => discoverable = v)),
        const SizedBox(height: 12),
        FilledButton(
            onPressed: c.busy
                ? null
                : () => c.mutate('/me', method: 'PATCH', data: {
                      'display_name': name!.text.trim(),
                      'bio': bio!.text.trim(),
                      'discoverable': discoverable,
                      'preferences': c.profile['preferences']
                    }),
            child: const Text('Save profile')),
        if (c.profile['discoverable'] == true) ...[
          const Divider(height: 36),
          SelectableText(publicUrl),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            TextButton.icon(
                onPressed: () => context.go('/public/${c.profile['handle']}'),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Preview public profile')),
            TextButton.icon(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: publicUrl)),
                icon: const Icon(Icons.copy),
                label: const Text('Copy profile link')),
            TextButton.icon(
                onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                            title: const Text('Share your profile'),
                            content: SizedBox(
                                width: 240,
                                height: 240,
                                child: QrImageView(
                                    data: publicUrl,
                                    backgroundColor: Colors.white)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Done'))
                            ])),
                icon: const Icon(Icons.qr_code),
                label: const Text('QR code'))
          ])
        ]
      ])),
      const SizedBox(height: 24),
      SectionTitle('Private sharing',
          subtitle:
              'Share without joining discovery. Revoke access at any time.',
          trailing: FilledButton.tonalIcon(
              onPressed: () => c.mutate('/shares'),
              icon: const Icon(Icons.link),
              label: const Text('Create link'))),
      for (final share in c.list('shares'))
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Surface(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Expanded(
                      child: Text(
                          '${share['revoked'] ? 'Revoked' : 'Active'} · ${dateLabel(share['created_at'])}')),
                  if (!share['revoked']) ...[
                    TextButton(
                        onPressed: () => Clipboard.setData(ClipboardData(
                            text: '${shareOrigin()}/#/share/${share['id']}')),
                        child: const Text('Copy')),
                    TextButton(
                        onPressed: () => c.mutate('/shares/${share['id']}',
                            method: 'DELETE'),
                        child: const Text('Revoke'))
                  ]
                ]))),
      const SizedBox(height: 24),
      const SectionTitle('A considered experience',
          subtitle:
              'Appearance and accessibility choices follow your account.'),
      Surface(
          child: Column(children: [
        DropdownButtonFormField<ThemeMode>(
            initialValue: c.theme,
            decoration: const InputDecoration(labelText: 'Appearance'),
            items: [
              for (final value in ThemeMode.values)
                DropdownMenuItem(value: value, child: Text(value.name))
            ],
            onChanged: (v) => c.preferences(mode: v)),
        const SizedBox(height: 12),
        SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reduce motion'),
            subtitle: const Text('Use immediate transitions.'),
            value: c.reducedMotion,
            onChanged: (v) => c.preferences(motion: v)),
        SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reduce transparency'),
            subtitle: const Text('Use opaque navigation and panels.'),
            value: c.reducedTransparency,
            onChanged: (v) => c.preferences(transparency: v))
      ])),
      const SizedBox(height: 24),
      const SectionTitle('Take your evidence with you'),
      Surface(
          child: Wrap(spacing: 16, runSpacing: 12, children: [
        FilledButton.tonalIcon(
            onPressed: () => c.run(() =>
                download(c.api, '/export?format=pdf', 'auctor-evidence.pdf')),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Download PDF report')),
        FilledButton.tonalIcon(
            onPressed: () => c.run(() =>
                download(c.api, '/export?format=json', 'auctor-evidence.json')),
            icon: const Icon(Icons.data_object),
            label: const Text('Export structured data')),
        if (c.profile['discoverable'] == true)
          TextButton.icon(
              onPressed: () => Clipboard.setData(ClipboardData(
                  text:
                      '<a href="$publicUrl"><img src="${PlatformApi.base}/api/badge/${c.profile['handle']}.svg" alt="Auctor evidence score" /></a>')),
              icon: const Icon(Icons.code),
              label: const Text('Copy embed badge'))
      ]))
    ]);
  }
}

class DiscoverPane extends ConsumerStatefulWidget {
  const DiscoverPane({super.key});
  @override
  ConsumerState<DiscoverPane> createState() => _DiscoverState();
}

class _DiscoverState extends ConsumerState<DiscoverPane> {
  final query = TextEditingController();
  double minimum = 0;
  bool onlySaved = false, busy = true;
  String? error;
  List<Map<String, dynamic>> people = [];
  final selected = <int>{};
  @override
  void initState() {
    super.initState();
    Future.microtask(load);
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => busy = true);
    try {
      final data = await ref.read(workspaceProvider).api.call(
          '/candidates?q=${Uri.encodeQueryComponent(query.text)}&min_score=$minimum');
      if (mounted) {
        setState(() {
          people =
              (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(workspaceProvider);
    final filtered =
        people.where((p) => !onlySaved || p['saved'] == true).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('Discover the work behind the name',
          subtitle:
              'An opt-in directory of profiles, with evidence you can inspect.'),
      Surface(
          child: Column(children: [
        TextField(
            controller: query,
            onSubmitted: (_) => load(),
            decoration: InputDecoration(
                labelText: 'Name, handle or skill',
                suffixIcon: IconButton(
                    onPressed: load,
                    tooltip: 'Search',
                    icon: const Icon(Icons.search)))),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Minimum score'),
          Expanded(
              child: Slider(
                  value: minimum,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: minimum.toStringAsFixed(1),
                  onChanged: (v) => setState(() => minimum = v),
                  onChangeEnd: (_) => load())),
          Text(minimum.toStringAsFixed(1))
        ]),
        Wrap(spacing: 16, children: [
          FilterChip(
              label: const Text('Saved candidates'),
              selected: onlySaved,
              onSelected: (v) => setState(() => onlySaved = v)),
          FilledButton.tonal(
              onPressed: selected.length < 2
                  ? null
                  : () => showDialog(
                      context: context,
                      builder: (_) => CandidateComparison(
                          candidates: people
                              .where(
                                  (p) => selected.contains(p['profile']['id']))
                              .toList())),
              child: Text('Compare (${selected.length}/3)'))
        ])
      ])),
      const SizedBox(height: 24),
      if (error != null) ErrorNotice(error!),
      if (busy) const Center(child: CircularProgressIndicator()),
      if (!busy && filtered.isEmpty)
        const EmptyState('No profiles match yet',
            'Only candidates who choose discovery are listed. Try another skill or lower the minimum score.'),
      for (final person in filtered)
        Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Surface(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    const AuctorMark(size: 42),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(person['profile']['display_name'],
                              style: const TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w600)),
                          Text('@${person['profile']['handle']}')
                        ])),
                    Text('${person['score']['total']}/10',
                        style: const TextStyle(fontSize: 23, color: champagne))
                  ]),
                  const SizedBox(height: 14),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final skill in person['skills'])
                      Chip(label: Text(skill.toString()))
                  ]),
                  Text(person['profile']['bio'] ?? ''),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: [
                    TextButton(
                        onPressed: () => context
                            .go('/public/${person['profile']['handle']}'),
                        child: const Text('View evidence')),
                    TextButton.icon(
                        onPressed: () async {
                          try {
                            await c.api.call(
                                '/candidates/${person['profile']['id']}/save',
                                method: person['saved'] == true
                                    ? 'DELETE'
                                    : 'POST');
                            await load();
                          } catch (e) {
                            setState(() => error = e.toString());
                          }
                        },
                        icon: Icon(person['saved'] == true
                            ? Icons.bookmark
                            : Icons.bookmark_outline),
                        label:
                            Text(person['saved'] == true ? 'Saved' : 'Save')),
                    FilterChip(
                        label: const Text('Compare'),
                        selected: selected.contains(person['profile']['id']),
                        onSelected: (v) => setState(() {
                              if (v && selected.length < 3) {
                                selected.add(person['profile']['id']);
                              } else {
                                selected.remove(person['profile']['id']);
                              }
                            }))
                  ])
                ])))
    ]);
  }
}

class CandidateComparison extends StatelessWidget {
  final List<Map<String, dynamic>> candidates;
  const CandidateComparison({super.key, required this.candidates});
  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Evidence side by side'),
          content: SizedBox(
              width: 900,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final p in candidates)
                          SizedBox(
                              width: 260,
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(p['profile']['display_name'],
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 12),
                                        Text('${p['score']['total']}/10',
                                            style: const TextStyle(
                                                fontSize: 30,
                                                color: champagne)),
                                        const SizedBox(height: 12),
                                        Text(
                                            'Skills\n${(p['skills'] as List).join(', ')}'),
                                        const SizedBox(height: 16),
                                        Text(
                                            'Earned badges\n${(p['badges'] as List).join(', ')}'),
                                        const SizedBox(height: 16),
                                        Text(
                                            'Reviewed or owned evidence: ${(p['evidence'] as List).length}'),
                                        const SizedBox(height: 16),
                                        for (final e
                                            in p['score']['components'].entries)
                                          Text(
                                              '${e.key}: ${e.value['points']} pts')
                                      ])))
                      ]))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'))
          ]);
}

class ReviewsPane extends ConsumerStatefulWidget {
  const ReviewsPane({super.key});
  @override
  ConsumerState<ReviewsPane> createState() => _ReviewsState();
}

class _ReviewsState extends ConsumerState<ReviewsPane> {
  List<dynamic>? queue;
  String? error;
  @override
  void initState() {
    super.initState();
    Future.microtask(load);
  }

  Future<void> load() async {
    try {
      final q = await ref.read(workspaceProvider).api.call('/reviews');
      if (mounted) {
        setState(() {
          queue = q;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(workspaceProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle('Independent evidence review',
          subtitle:
              'Inspect the source. Record your rationale. Never review your own proof.',
          trailing:
              TextButton(onPressed: load, child: const Text('Refresh queue'))),
      if (error != null) ErrorNotice(error!),
      if (queue == null && error == null)
        const Center(child: CircularProgressIndicator()),
      if (queue?.isEmpty == true)
        const EmptyState('The review queue is clear',
            'New experience, certificate and coding submissions appear here.'),
      for (final e in queue ?? [])
        Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Surface(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(e['title'],
                      style: const TextStyle(
                          fontSize: 23, fontWeight: FontWeight.w600)),
                  Text('@${e['handle']} · ${e['kind']}'),
                  if (e['kind'] == 'coding')
                    Text('Claimed solved count: ${e['detail']['solved']}'),
                  const SizedBox(height: 16),
                  Wrap(spacing: 12, children: [
                    if ((e['url'] ?? '').isNotEmpty)
                      TextButton.icon(
                          onPressed: () => c.run(() => openLink(e['url'])),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Inspect source')),
                    TextButton.icon(
                        onPressed: () => c.run(() => download(
                            c.api, '/evidence/${e['id']}/file', 'proof.pdf')),
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download proof')),
                    FilledButton.tonal(
                        onPressed: () =>
                            decision(context, c, e['id'], 'verified'),
                        child: const Text('Verify evidence')),
                    OutlinedButton(
                        onPressed: () =>
                            decision(context, c, e['id'], 'rejected'),
                        child: const Text('Reject'))
                  ])
                ])))
    ]);
  }

  Future<void> decision(BuildContext context, WorkspaceController c, String id,
      String status) async {
    final note = TextEditingController();
    final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(status == 'verified'
                    ? 'Record verification'
                    : 'Record rejection'),
                content: TextField(
                    controller: note,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                        labelText:
                            'Review rationale (at least 10 characters)')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () {
                        if (note.text.trim().length >= 10) {
                          Navigator.pop(ctx, note.text.trim());
                        }
                      },
                      child: const Text('Record decision'))
                ]));
    note.dispose();
    if (result != null) {
      await c.mutate('/reviews/$id', data: {'status': status, 'note': result});
      await load();
    }
  }
}

class PublicPage extends ConsumerStatefulWidget {
  final String path;
  const PublicPage({super.key, required this.path});
  @override
  ConsumerState<PublicPage> createState() => _PublicState();
}

class _PublicState extends ConsumerState<PublicPage> {
  Map<String, dynamic>? data;
  String? error;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        final p = Map<String, dynamic>.from(await ref
            .read(workspaceProvider)
            .api
            .call(widget.path, authenticated: false));
        if (mounted) setState(() => data = p);
      } catch (e) {
        if (mounted) setState(() => error = e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Backdrop(
          child: SafeArea(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Center(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 950),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const AuctorMark(),
                                  const SizedBox(width: 12),
                                  const Text('auctor',
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w700)),
                                  const Spacer(),
                                  TextButton(
                                      onPressed: () => context.go('/workspace'),
                                      child: const Text('Your workspace'))
                                ]),
                                const SizedBox(height: 48),
                                if (error != null)
                                  EmptyState(
                                      'This profile is unavailable', error!),
                                if (data == null && error == null)
                                  const Center(
                                      child: CircularProgressIndicator()),
                                if (data != null) ...[
                                  Surface(
                                      glass: true,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Chip(
                                                label: Text(
                                                    'PROOF OF YOUR CRAFT')),
                                            const SizedBox(height: 18),
                                            Text(
                                                data!['profile']
                                                    ['display_name'],
                                                style: const TextStyle(
                                                    fontSize: 45,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: -1.7)),
                                            Text(
                                                '@${data!['profile']['handle']}',
                                                style: const TextStyle(
                                                    fontSize: 18)),
                                            const SizedBox(height: 18),
                                            Text(data!['profile']['bio'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 18, height: 1.6)),
                                            const SizedBox(height: 24),
                                            Row(children: [
                                              Text('${data!['score']['total']}',
                                                  style: const TextStyle(
                                                      fontSize: 56,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: champagne)),
                                              const SizedBox(width: 16),
                                              const Text(
                                                  'Auctor score / 10\nEvidence summary • formula v1')
                                            ])
                                          ])),
                                  const SizedBox(height: 28),
                                  const SectionTitle(
                                      'Skills and assessed badges'),
                                  Surface(
                                      child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                        for (final skill in data!['skills'])
                                          Chip(label: Text(skill.toString())),
                                        for (final badge in data!['badges'])
                                          Chip(
                                              avatar: const Icon(
                                                  Icons.verified_outlined,
                                                  size: 16,
                                                  color: champagne),
                                              label: Text(badge.toString()))
                                      ])),
                                  const SizedBox(height: 28),
                                  const SectionTitle(
                                      'Evidence, with provenance'),
                                  for (final e in data!['evidence'])
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 14),
                                        child: Surface(
                                            child: Row(children: [
                                          const Icon(Icons.verified_outlined,
                                              color: champagne),
                                          const SizedBox(width: 18),
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                Text(e['title'],
                                                    style: const TextStyle(
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                Text(
                                                    '${e['kind']} · ${e['status']}'),
                                                if ((e['review_note'] ?? '')
                                                    .isNotEmpty)
                                                  Text(e['review_note'])
                                              ])),
                                          if ((e['url'] ?? '').isNotEmpty)
                                            IconButton(
                                                tooltip: 'Open source',
                                                onPressed: () =>
                                                    openLink(e['url']),
                                                icon: const Icon(
                                                    Icons.open_in_new))
                                        ]))),
                                  const SizedBox(height: 28),
                                  const SectionTitle('Score explained'),
                                  Surface(
                                      child: Column(children: [
                                    for (final entry
                                        in data!['score']['components'].entries)
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Row(children: [
                                            Expanded(child: Text(entry.key)),
                                            Text(
                                                '${entry.value['points']} / ${(entry.value['weight'] as num) * 10} points')
                                          ]))
                                  ])),
                                  const SizedBox(height: 32),
                                  const Text(
                                      'Auctor records ownership, supplied evidence, reviewer decisions and assessments. A score is contextual and is not a hiring guarantee. Private contacts and proof files are excluded.',
                                      style:
                                          TextStyle(fontSize: 12, height: 1.6))
                                ]
                              ])))))));
}

String shareOrigin() => kIsWeb
    ? Uri.base.origin
    : const String.fromEnvironment('WEB_BASE_URL',
        defaultValue: 'http://localhost:8080');

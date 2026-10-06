import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controller.dart';
import 'liquid_glass.dart';
import 'visual_theme.dart';
import 'package:flutter/foundation.dart';
import 'save_stub.dart'
    if (dart.library.io) 'save_io.dart'
    if (dart.library.js_interop) 'save_web.dart';

final workspaceProvider =
    ChangeNotifierProvider<WorkspaceController>((ref) => WorkspaceController());
const pine = AuctorPalette.jade, champagne = AuctorPalette.champagne;

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
        theme: theme(Brightness.light, highContrast: c.highContrast),
        darkTheme: theme(Brightness.dark, highContrast: c.highContrast),
        highContrastTheme: theme(Brightness.light, highContrast: true),
        highContrastDarkTheme: theme(Brightness.dark, highContrast: true),
        themeMode: c.theme,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                highContrast:
                    c.highContrast || MediaQuery.of(context).highContrast,
                disableAnimations: c.reducedMotion ||
                    MediaQuery.of(context).disableAnimations),
            child: child!));
  }
}

ThemeData theme(Brightness brightness, {bool highContrast = false}) =>
    auctorTheme(brightness, highContrast: highContrast);

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
    final contrast = c.highContrast || MediaQuery.highContrastOf(context);
    if (glass) {
      return LiquidGlass(
          padding: padding,
          opaque: c.reducedTransparency,
          reducedMotion: c.reducedMotion,
          highContrast: contrast,
          child: child);
    }
    final content = Container(
        padding: padding,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: contrast
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: dark ? .65 : .75)),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xff132b31)
                      .withValues(alpha: dark ? 0.14 : 0.045),
                  blurRadius: 36,
                  offset: const Offset(0, 14))
            ]),
        child: Material(type: MaterialType.transparency, child: child));
    return content;
  }
}

class AuctorDialog extends ConsumerWidget {
  final Widget? title, content;
  final List<Widget>? actions;
  const AuctorDialog({super.key, this.title, this.content, this.actions});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(workspaceProvider);
    return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: SizedBox(
            width: 720,
            child: LiquidGlass(
                opaque: c.reducedTransparency,
                highContrast:
                    c.highContrast || MediaQuery.highContrastOf(context),
                reducedMotion: c.reducedMotion,
                padding: EdgeInsets.zero,
                radius: 28,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (title != null)
                        Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Semantics(
                                header: true,
                                namesRoute: true,
                                container: true,
                                child: DefaultTextStyle(
                                    style:
                                        Theme.of(context).textTheme.titleLarge!,
                                    child: title!))),
                      if (content != null)
                        Flexible(
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: SingleChildScrollView(child: content!))),
                      if (actions != null)
                        Padding(
                            padding: const EdgeInsets.all(20),
                            child: Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 10,
                                runSpacing: 8,
                                children: actions!)),
                    ]))));
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
                        const Color(0xff11191f),
                        const Color(0xff192d2f),
                        const Color(0xff2a2728)
                      ]
                    : [
                        const Color(0xfff4f1eb),
                        const Color(0xffe6eeec),
                        const Color(0xfff3e8da)
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
                    fontFamily: 'Newsreader',
                    fontSize: 30,
                    height: 1.12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -.5)),
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
                                                  fontFamily: 'Newsreader',
                                                  fontSize: box.maxWidth > 850
                                                      ? 72
                                                      : 46,
                                                  height: 1.05,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: -1.3)),
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
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .secondary,
                                                                fontSize: 20)),
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
                                  child: GlassDestination(
                                      label: item.value.$1,
                                      icon: item.value.$2,
                                      selected: current == item.key,
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
              child: Surface(
                  glass: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: LayoutBuilder(builder: (context, toolbar) {
                    final title = Row(children: [
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
                                    fontFamily: 'Newsreader',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -.4)),
                            if (wide)
                              Text('Your craft. Your evidence. Your story.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant))
                          ])),
                    ]);
                    final actions =
                        Row(mainAxisSize: MainAxisSize.min, children: [
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
                            icon: const Icon(Icons.logout)),
                    ]);
                    return toolbar.maxWidth < 520
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                title,
                                const SizedBox(height: 4),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: actions)
                              ])
                        : Row(children: [Expanded(child: title), actions]);
                  }))),
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
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          for (final item in nav.asMap().entries)
                            SizedBox(
                                width: 88 *
                                    MediaQuery.textScalerOf(context).scale(11) /
                                    11,
                                child: GlassDestination(
                                    compact: true,
                                    label: item.value.$1,
                                    icon: item.value.$2,
                                    selected: current == item.key,
                                    onTap: () => c.select(item.key)))
                        ]))))
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
      child: LayoutBuilder(builder: (context, box) {
        final copy =
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Newsreader',
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  height: 1.16,
                  letterSpacing: -.3)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(subtitle,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4))
          ],
        ]);
        return trailing != null &&
                (box.maxWidth < 600 ||
                    MediaQuery.textScalerOf(context).scale(14) > 20)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [copy, const SizedBox(height: 14), trailing!])
            : Row(children: [
                Expanded(child: copy),
                if (trailing != null) trailing!
              ]);
      }));
}

class EmptyState extends StatelessWidget {
  final String title, body;
  final Widget? action;
  const EmptyState(this.title, this.body, {super.key, this.action});
  @override
  Widget build(BuildContext context) => Surface(
          child: Column(children: [
        Icon(Icons.blur_on_rounded,
            size: 40, color: Theme.of(context).colorScheme.secondary),
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
    final passed = (c.workspace?['earned_badges'] as List? ??
            c
                .list('badges')
                .where((b) => b['passed'] == true)
                .map((b) => b['badge_id'])
                .toList())
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
        final ring = SizedBox(
            width: 150,
            height: 150,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox.expand(
                  child: CircularProgressIndicator(
                      value: score / 10,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: .18),
                      color: Theme.of(context).colorScheme.secondary)),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(score.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 38, fontWeight: FontWeight.w500)),
                        const Text('OUT OF 10',
                            style: TextStyle(fontSize: 9, letterSpacing: 2))
                      ]))),
            ]));
        final summaryCopy =
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Auctor score',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
              'A transparent summary of evidence.\nFormula v1 • five weighted signals',
              style: TextStyle(height: 1.5)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            Chip(label: Text('${passed.length} badges')),
            Chip(label: Text('${c.cv['projects'].length} projects'))
          ]),
        ]);
        final summary = Surface(
            child: box.maxWidth < 520 ||
                    MediaQuery.textScalerOf(context).scale(14) > 20
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Center(child: ring),
                        const SizedBox(height: 24),
                        summaryCopy
                      ])
                : Row(children: [
                    ring,
                    const SizedBox(width: 24),
                    Expanded(child: summaryCopy)
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
                              color: Theme.of(context).colorScheme.secondary,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: .15)))),
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
              'Prioritized gaps from your CV, project sources and earned assessments.'),
      SkillRoadmapPane(controller: c),
      const SizedBox(height: 28),
      const SectionTitle('Skills and their evidence',
          subtitle: 'Select a skill to inspect its actual source connections.'),
      EvidenceSkillsGraph(
          controller: c,
          nodes: insightItems(c, 'skill_graph', nested: 'nodes')),
      const SizedBox(height: 28),
      SectionTitle('Repository intelligence',
          subtitle: github.isEmpty
              ? 'Connect GitHub to confirm account ownership.'
              : 'Snapshot ${dateLabel(github['synced_at'])} • public repositories you own'),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              github.isEmpty
                  ? 'Connect the source of your work'
                  : '@${github['login']}',
              style:
                  const TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
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
        if (github.isNotEmpty) RepositoryFreshness(controller: c),
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

List<Map<String, dynamic>> insightItems(WorkspaceController c, String key,
    {String? nested}) {
  dynamic value = c.workspace?['insights']?[key];
  if (nested != null) value = value?[nested];
  return (value as List? ?? [])
      .map((v) => Map<String, dynamic>.from(v))
      .toList();
}

Future<void> showBadgeDetails(
        BuildContext context, WorkspaceController c, String id) =>
    showDialog<void>(
        context: context,
        builder: (_) => BadgeDetailsDialog(api: c.api, id: id));

class BadgeDetailsDialog extends StatefulWidget {
  final PlatformApi api;
  final String id;
  const BadgeDetailsDialog({super.key, required this.api, required this.id});
  @override
  State<BadgeDetailsDialog> createState() => _BadgeDetailsState();
}

class _BadgeDetailsState extends State<BadgeDetailsDialog> {
  late Future<dynamic> detail;
  @override
  void initState() {
    super.initState();
    detail = widget.api.call('/challenges/${widget.id}');
  }

  @override
  Widget build(BuildContext context) => AuctorDialog(
          title: const Text('Badge details'),
          content: SizedBox(
              width: 620,
              child: FutureBuilder<dynamic>(
                  future: detail,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Column(mainAxisSize: MainAxisSize.min, children: [
                        ErrorNotice(snapshot.error.toString()),
                        TextButton(
                            onPressed: () => setState(() => detail =
                                widget.api.call('/challenges/${widget.id}')),
                            child: const Text('Retry'))
                      ]);
                    }
                    if (!snapshot.hasData) {
                      return const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()));
                    }
                    final data = snapshot.data;
                    final attempts = data['attempts'] as List;
                    return SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(data['name'],
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Chip(
                              label: Text(data['earned']
                                  ? 'Badge earned'
                                  : 'Not yet earned')),
                          Text(
                              '${data['skill']} · ${data['questions']} questions · pass ${data['pass_threshold']}/5 · ${data['duration_seconds'] ~/ 60} minutes'),
                          const SizedBox(height: 12),
                          Text(data['scope']),
                          const Divider(height: 30),
                          const Text('Your attempts',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          if (attempts.isEmpty)
                            const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                    'No attempt recorded for this account.')),
                          for (final a in attempts)
                            Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${dateLabel(a['started_at'])} · ${a['submitted_at'] == null ? 'Started' : '${a['correct_count']}/5 · ${a['passed'] ? 'Passed' : 'Practice'}'}'),
                                      Text('Server expiry: ${a['expires_at']}'),
                                      if (a['submitted_at'] != null)
                                        Text(
                                            'Submitted: ${a['submitted_at']} · actual delta +${a['score_delta']}'),
                                    ])),
                        ]));
                  })),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'))
          ]);
}

class SkillRoadmapPane extends StatelessWidget {
  final WorkspaceController controller;
  const SkillRoadmapPane({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    final steps = insightItems(controller, 'roadmap');
    return Surface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (steps.isEmpty)
        const Text('Add or review a CV to see your personal evidence gaps.'),
      for (final step in steps)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(step['skill'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    Chip(label: Text(step['status'])),
                    if (step['track_id'] != null)
                      TextButton(
                          onPressed: () => showDialog<void>(
                              context: context,
                              builder: (_) => ChallengeDialog(
                                  api: controller.api,
                                  badge: {
                                    'id': step['track_id'],
                                    'name': step['skill']
                                  },
                                  onComplete: controller.refresh)),
                          child: Text(step['status'] == 'assessed'
                              ? 'Practice again'
                              : 'Assess this gap')),
                  ]),
              Text(step['reason']),
              const SizedBox(height: 6),
              Text(step['next_step'],
                  style: const TextStyle(fontSize: 12, height: 1.5)),
            ])),
    ]));
  }
}

class EvidenceSkillsGraph extends StatefulWidget {
  final WorkspaceController controller;
  final List<Map<String, dynamic>> nodes;
  const EvidenceSkillsGraph(
      {super.key, required this.controller, required this.nodes});
  @override
  State<EvidenceSkillsGraph> createState() => _EvidenceSkillsGraphState();
}

class _EvidenceSkillsGraphState extends State<EvidenceSkillsGraph> {
  String? selected;
  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) {
      return const Surface(
          child: Text(
              'CV claims, project sources and passed assessments build this graph.'));
    }
    final node = widget.nodes.firstWhere((n) => n['id'] == selected,
        orElse: () => widget.nodes.first);
    final sources = node['sources'] as List;
    return Surface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final n in widget.nodes)
          ChoiceChip(
              label: Text(n['name']),
              selected: n['id'] == node['id'],
              onSelected: (_) => setState(() => selected = n['id']))
      ]),
      const SizedBox(height: 22),
      Center(
          child: Chip(
              avatar: const Icon(Icons.hub_outlined, size: 18),
              label: Text('${node['name']} · ${node['status']}'))),
      Center(
          child: Container(
              width: 1,
              height: 20,
              color: Theme.of(context).colorScheme.secondary)),
      for (final source in sources)
        Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Semantics(
                label:
                    '${node['name']} connected to ${source['label']}: ${source['status']}',
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: .6),
                                width: 2)),
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: .06)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                              spacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(source['label'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Chip(label: Text(source['status']))
                              ]),
                          if (source['scope'] != null)
                            Text(source['scope'],
                                style:
                                    const TextStyle(fontSize: 12, height: 1.5)),
                          TextButton.icon(
                              onPressed: () => source['kind'] == 'assessment'
                                  ? showBadgeDetails(context, widget.controller,
                                      source['badge_id'])
                                  : widget.controller.select(1),
                              icon: const Icon(Icons.account_tree_outlined,
                                  size: 16),
                              label: const Text('Inspect source connection')),
                        ])))),
      const Text(
          'Declarations, owned provenance and assessed results are distinct. No source silently verifies every skill.',
          style: TextStyle(fontSize: 12, height: 1.5)),
    ]));
  }
}

class RepositoryFreshness extends StatelessWidget {
  final WorkspaceController controller;
  const RepositoryFreshness({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    final data =
        controller.workspace?['insights']?['repository_analytics'] as Map? ??
            {};
    final age = data['age_seconds'] as num?;
    return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              'Cache ${data['freshness'] ?? 'unknown'} · ${age == null ? 'Age unavailable' : '${(age / 3600).floor()} hours old'}'),
          if (data['synced_at'] != null)
            Text('Synced: ${data['synced_at']}',
                style: const TextStyle(fontSize: 12)),
          Wrap(spacing: 8, children: [
            for (final entry in (data['languages'] as Map? ?? {}).entries)
              Chip(label: Text('${entry.key} · ${entry.value} repositories'))
          ]),
          if (data['scope'] != null)
            Text(data['scope'],
                style: const TextStyle(fontSize: 12, height: 1.5)),
        ]));
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
        Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 28),
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
  await saveReport(name, bytes);
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
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your current CV',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextButton.icon(
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => CvEditor(
                      data: c.cv,
                      onSave: (data) async {
                        await c.mutate('/cv', method: 'PUT', data: {
                          'data': data,
                          'note': 'CV reviewed and edited'
                        });
                        if (c.error != null) throw StateError(c.error!);
                      })),
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
              leading: Icon(Icons.code,
                  color: Theme.of(context).colorScheme.secondary),
              title: Text(p['name']),
              subtitle: Text(p['description'] ?? '')),
        for (final e in c.cv['experience'])
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.work_outline,
                  color: Theme.of(context).colorScheme.secondary),
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
                    color: Theme.of(context).colorScheme.secondary),
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
      TextButton.icon(
          onPressed: () => c.run(() async {
                final selected = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                    withData: true);
                if (selected == null || selected.files.single.bytes == null) {
                  return;
                }
                final file = selected.files.single;
                await c.api.upload('/coding/import', file.bytes!, file.name,
                    mime: 'application/json');
                await c.refresh();
              }),
          icon: const Icon(Icons.file_upload_outlined, size: 18),
          label: const Text('Import coding profile JSON')),
      const Text(
          'Imports need source_url and solved fields. Submitted counts stay unverified until an independent source review.',
          style: TextStyle(fontSize: 12, height: 1.5)),
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
                  if (e['kind'] == 'coding')
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                            'Claimed solved count: ${e['detail']['solved']}\n${e['detail']['import_method'] ?? 'Manual claim; independent review required'}',
                            style: const TextStyle(fontSize: 12, height: 1.5))),
                  if ((e['review_note'] ?? '').toString().isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('Review: ${e['review_note']}')),
                  if (e['kind'] == 'certificate')
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                            'Issuer: ${e['detail']['issuer'] ?? 'Not supplied'} · Reference: ${e['detail']['reference'] ?? 'Not supplied'}\nIssued: ${e['detail']['issued_on'] ?? 'Not supplied'}')),
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
                    if (e['has_file'] == true)
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
      builder: (ctx) => AuctorDialog(
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
  String? saveError;
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
  Widget build(BuildContext context) => AuctorDialog(
          title: const Text('Review your story'),
          content: SizedBox(
              width: 650,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text(
                        'Edit extracted claims before connecting evidence. Verification is recorded separately.'),
                    if (saveError != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(saveError!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error))),
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
                        setState(() {
                          saving = true;
                          saveError = null;
                        });
                        try {
                          await widget.onSave(data);
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (mounted) {
                            setState(() {
                              saving = false;
                              saveError = e.toString();
                            });
                          }
                        }
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
    return AuctorDialog(
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
      solved = TextEditingController(),
      issuer = TextEditingController(),
      reference = TextEditingController(),
      issuedOn = TextEditingController();
  bool saving = false;
  String? error;
  @override
  void dispose() {
    title.dispose();
    url.dispose();
    solved.dispose();
    issuer.dispose();
    reference.dispose();
    issuedOn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final repos =
        (c.profile['github_identity']?['repositories'] as List? ?? []);
    final projects = c.cv['projects'] as List;
    return AuctorDialog(
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
                if (kind == 'certificate') ...[
                  const SizedBox(height: 12),
                  TextField(
                      controller: issuer,
                      decoration: const InputDecoration(
                          labelText: 'Certificate issuer')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: reference,
                      decoration: const InputDecoration(
                          labelText: 'Credential/reference ID (optional)')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: issuedOn,
                      decoration: const InputDecoration(
                          labelText: 'Issued date (optional)')),
                ],
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
                      if (kind == 'certificate' && issuer.text.trim().isEmpty) {
                        setState(() => error =
                            'Name the certificate issuer for inspection');
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
                            if (kind == 'project') 'project': project,
                            if (kind == 'certificate')
                              'issuer': issuer.text.trim(),
                            if (kind == 'certificate')
                              'reference': reference.text.trim(),
                            if (kind == 'certificate')
                              'issued_on': issuedOn.text.trim()
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
                    Icon(Icons.verified_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 32),
                    const SizedBox(height: 20),
                    Text(item['name'],
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                        '${item['questions']} questions · 5 min\nPass ${item['pass_threshold']} or more to earn a badge.',
                        style: const TextStyle(height: 1.5)),
                    const SizedBox(height: 20),
                    TextButton.icon(
                        onPressed: () =>
                            showBadgeDetails(context, c, item['id']),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Badge details')),
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
                      color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            '${attempt['badge_id']} · ${dateLabel(attempt['started_at'])}'),
                        const SizedBox(height: 4),
                        Wrap(spacing: 12, children: [
                          Text(attempt['submitted_at'] == null
                              ? 'Started'
                              : '${attempt['correct_count']}/5 · ${attempt['passed'] == true ? 'Passed' : 'Practice'}'),
                          if (attempt['score_delta'] != null)
                            Text('Actual delta: +${attempt['score_delta']}'),
                        ]),
                      ])),
                  IconButton(
                      tooltip: 'Open badge details',
                      onPressed: () =>
                          showBadgeDetails(context, c, attempt['badge_id']),
                      icon: const Icon(Icons.info_outline, size: 18)),
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
  Widget build(BuildContext context) => AuctorDialog(
          title: Row(children: [
            Expanded(child: Text(widget.badge['name'])),
            if (result == null)
              Text(
                  '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary))
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
                          color: Theme.of(context).colorScheme.secondary),
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
                                  for (final option in (question['options'] as List)
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
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .secondary
                                                            .withValues(
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
                      color: Theme.of(context).colorScheme.secondary),
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
          subtitle:
              'Compare evidence changes, including updates that add zero points.'),
      for (final snapshot in c.list('history'))
        Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Surface(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Text('${snapshot['score']['total']}',
                      style: TextStyle(
                          fontSize: 25,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 20),
                  Expanded(child: Text(snapshot['reason'])),
                  Text(dateLabel(snapshot['created_at'])),
                  IconButton(
                      tooltip: 'Compare score signals',
                      onPressed: () =>
                          showScoreComparison(context, c, snapshot['id']),
                      icon: const Icon(Icons.compare_arrows)),
                ]))),
      const SizedBox(height: 24),
      const SectionTitle('Reviewer decision audit',
          subtitle:
              'Recorded decisions persist after the evidence is removed.'),
      if (c.list('review_audit').isEmpty)
        const Text('No independent review decision recorded.'),
      for (final decision in c.list('review_audit'))
        ReviewAuditCard(decision: decision),
    ]);
  }
}

Future<void> showScoreComparison(
    BuildContext context, WorkspaceController c, dynamic id) {
  final rows = insightItems(c, 'score_comparisons');
  final item = rows.firstWhere((r) => r['history_id'] == id, orElse: () => {});
  return showDialog<void>(
      context: context,
      builder: (_) => AuctorDialog(
              title: const Text('Evidence change comparison'),
              content: SizedBox(
                  width: 580,
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(item['total_delta'] == null
                            ? 'Initial or oldest available snapshot; no earlier score is assumed.'
                            : 'Actual score delta: ${item['total_delta']}'),
                        const SizedBox(height: 12),
                        if (item['baseline_known'] != true)
                          const Text(
                              'An earlier input baseline was not recorded; changes cannot be fully reconstructed.'),
                        for (final entry
                            in (item['component_deltas'] as Map? ?? {}).entries)
                          Text('${entry.key}: ${entry.value} points'),
                        const Divider(height: 28),
                        for (final change in item['changes'] as List? ?? [])
                          Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(change)),
                        const Text(
                            'A certificate review or CV correction can change evidence without changing formula v1 points.',
                            style: TextStyle(fontSize: 12, height: 1.5)),
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ]));
}

class ReviewAuditCard extends StatelessWidget {
  final Map<String, dynamic> decision;
  const ReviewAuditCard({super.key, required this.decision});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${decision['title']} · ${decision['status']}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('Reviewer #${decision['reviewer_id']} · ${decision['created_at']}',
            style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Text(decision['note']),
        if (decision['source']?['detail']?['issuer'] != null)
          Text('Issuer inspected: ${decision['source']['detail']['issuer']}'),
        if ((decision['source']?['url'] ?? '').toString().isNotEmpty)
          SelectableText('Source: ${decision['source']['url']}',
              style: const TextStyle(fontSize: 12)),
        Text(
            'Private proof attached at review: ${decision['source']?['has_file'] == true ? 'Yes' : 'No'}',
            style: const TextStyle(fontSize: 12)),
      ])));
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
                    builder: (_) => AuctorDialog(
                            title: const Text('Share your profile'),
                            content: SizedBox(
                                width: 240,
                                height: 240,
                                child: QrImageView(
                                    data: publicUrl,
                                    padding: const EdgeInsets.all(16),
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
            onChanged: (v) => c.preferences(transparency: v)),
        SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Increase contrast'),
            subtitle: const Text('Stronger text, borders and opaque controls.'),
            value: c.highContrast,
            onChanged: (v) => c.preferences(contrast: v))
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
          selected.retainAll(people.map((p) => p['profile']['id'] as int));
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
        const Align(
            alignment: Alignment.centerLeft, child: Text('Minimum score')),
        Row(children: [
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
                        style: TextStyle(
                            fontSize: 23,
                            color: Theme.of(context).colorScheme.secondary))
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
  Widget build(BuildContext context) => AuctorDialog(
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
                                            style: TextStyle(
                                                fontSize: 30,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary)),
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
  List<Map<String, dynamic>> audit = [];
  String? error;
  @override
  void initState() {
    super.initState();
    Future.microtask(load);
  }

  Future<void> load() async {
    try {
      final q = await ref.read(workspaceProvider).api.call('/reviews');
      final decisions =
          await ref.read(workspaceProvider).api.call('/reviews/audit');
      if (mounted) {
        setState(() {
          queue = q;
          audit = (decisions as List)
              .map((d) => Map<String, dynamic>.from(d))
              .toList();
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
      if (audit.isNotEmpty) ...[
        const SizedBox(height: 20),
        const SectionTitle('Recorded decisions',
            subtitle: 'Who reviewed each source, when, and why.'),
        for (final decision in audit) ReviewAuditCard(decision: decision),
        const SizedBox(height: 20),
      ],
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
                  if (e['kind'] == 'certificate')
                    Text(
                        'Issuer: ${e['detail']['issuer'] ?? 'Not supplied'} · Reference: ${e['detail']['reference'] ?? 'Not supplied'}\nIssued: ${e['detail']['issued_on'] ?? 'Not supplied'}'),
                  const SizedBox(height: 16),
                  Wrap(spacing: 12, children: [
                    if ((e['url'] ?? '').isNotEmpty)
                      TextButton.icon(
                          onPressed: () => c.run(() => openLink(e['url'])),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Inspect source')),
                    if (e['has_file'] == true)
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
        builder: (ctx) => AuctorDialog(
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
                                                  style: TextStyle(
                                                      fontSize: 56,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary)),
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
                                              avatar: Icon(
                                                  Icons.verified_outlined,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary),
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
                                          Icon(Icons.verified_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/app.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/proof_motion.dart';
import 'package:auctor_app/premium/visual_theme.dart';
import 'premium_test.dart' show FixtureController;

void main() {
  testWidgets('Reduced motion settles immediately and retains child identity',
      (tester) async {
    final fieldKey = GlobalKey();
    Widget view(bool reduced) => MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child:
                Scaffold(body: ProofReveal(child: TextField(key: fieldKey)))));
    await tester.pumpWidget(view(false));
    await tester.pump(const Duration(milliseconds: 50));
    final original = fieldKey.currentState;
    await tester.pumpWidget(view(true));
    expect(fieldKey.currentState, same(original));
    expect(
        tester
            .widget<FadeTransition>(find.byType(FadeTransition).first)
            .opacity
            .value,
        1);
    expect(
        tester
            .widget<Transform>(find.byType(Transform).first)
            .transform
            .storage[13],
        0);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets(
      'Destination revisits retain profile draft and independent scroll',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = FixtureController(signedIn: true)..select(5);
    await tester.pumpWidget(ProviderScope(
        overrides: [workspaceProvider.overrideWith((ref) => fixture)],
        child: MaterialApp(
            theme: theme(Brightness.light), home: const WorkspacePage())));
    await tester.pumpAndSettle();
    final name = find.byWidgetPredicate((widget) =>
        widget is TextField && widget.decoration?.labelText == 'Display name');
    await tester.enterText(name, 'An unsaved considered draft');
    final controller = tester.widget<TextField>(name).controller;
    final editable = tester.widget<EditableText>(
        find.descendant(of: name, matching: find.byType(EditableText)));
    expect(editable.focusNode.hasFocus, isTrue);
    fixture.previewTheme(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(editable.focusNode.hasFocus, isTrue);
    fixture.error = 'Synthetic failed refresh';
    fixture.previewTheme(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(name).controller, same(controller));
    expect(editable.focusNode.hasFocus, isTrue);
    fixture.error = null;
    fixture.previewTheme(ThemeMode.dark);
    await tester.pumpAndSettle();
    final scroll = tester.state<ScrollableState>(find
        .descendant(
            of: find.byKey(const PageStorageKey('destination-scroll-5')),
            matching: find.byType(Scrollable))
        .first);
    scroll.position.jumpTo(180);
    fixture.select(0);
    await tester.pumpAndSettle();
    fixture.select(5);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(name).controller, same(controller));
    expect(controller!.text, 'An unsaved considered draft');
    expect(scroll.position.pixels, 180);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'Only a server result reveals the exact independently accessible score delta',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    final api = PlatformApi(
        client: MockClient((request) async => http.Response(
            jsonEncode(request.url.path.endsWith('/submit')
                ? {'passed': true, 'correct_count': 5, 'score_delta': .6}
                : {
                    'id': 'synthetic-owned-attempt',
                    'expires_at': DateTime.now()
                        .add(const Duration(minutes: 5))
                        .toUtc()
                        .toIso8601String(),
                    'questions': [
                      for (var i = 0; i < 5; i++)
                        {
                          'id': '$i',
                          'prompt': 'Synthetic question $i',
                          'options': ['Yes $i', 'No $i']
                        }
                    ]
                  }),
            200)));
    await tester.pumpWidget(ProviderScope(
        overrides: [
          workspaceProvider.overrideWith((ref) => FixtureController())
        ],
        child: MaterialApp(
            home: ChallengeDialog(
                api: api,
                badge: const {'id': 'docker', 'name': 'Synthetic assessment'},
                onComplete: () async {}))));
    await tester.pumpAndSettle();
    expect(find.text('Evidence earned. Well done.'), findsNothing);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Yes $i'));
      await tester.pump();
    }
    await tester.tap(find.text('Submit answers'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('5/5 correct. Actual score change: +0.6.'),
        findsOneWidget);
    expect(
        find.bySemanticsLabel('Evidence earned. Well done.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
    api.client.close();
  });

  test(
      'Curated palette persists using existing profile preferences and falls back safely',
      () async {
    var prefs = <String, dynamic>{
      'palette': 'future-palette',
      'reduced_motion': true,
      'custom': 'preserved'
    };
    final controller = WorkspaceController(
        api: PlatformApi(client: MockClient((request) async {
      if (request.method == 'PATCH') {
        prefs =
            Map<String, dynamic>.from(jsonDecode(request.body)['preferences']);
        return http.Response('{}', 200);
      }
      return http.Response(
          jsonEncode({
            'profile': {
              'preferences': prefs,
              'display_name': 'Synthetic QA',
              'bio': '',
              'discoverable': false
            }
          }),
          200);
    })));
    await controller.refresh();
    expect(controller.edition, AuctorEdition.atelier);
    await controller.preferences(palette: AuctorEdition.archive);
    expect(controller.edition, AuctorEdition.archive);
    expect(prefs['palette'], 'archive');
    expect(prefs['custom'], 'preserved');
    expect(controller.reducedMotion, isTrue);
    controller.dispose();
  });
}

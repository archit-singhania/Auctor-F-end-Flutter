import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auctor_app/premium/recruiter_presentation.dart';

void main() {
  testWidgets(
      'Presentation saves private draft but requires reviewed public sharing',
      (tester) async {
    final draft = {
      'revision': 0,
      'title': 'Draft title',
      'introduction': 'Public introduction',
      'private_notes': 'PRIVATE_NOTES',
      'milestone_ids': [],
      'project_names': [],
      'evidence_ids': [],
      'role_run_id': null
    };
    int publishes = 0;
    final c =
        WorkspaceController(api: PlatformApi(client: MockClient((r) async {
      if (r.method == 'PUT') {
        final value = jsonDecode(r.body);
        expect(value['private_notes'], 'PRIVATE_NOTES');
        return http.Response(jsonEncode({...value, 'revision': 1}), 200);
      }
      if (r.method == 'POST') {
        publishes++;
        return http.Response('{}', 201);
      }
      if (r.url.path.endsWith('/role-fit'))
        return http.Response('{"runs":[]}', 200);
      if (r.url.path.endsWith('/preview'))
        return http.Response(
            jsonEncode({
              'revision': 1,
              'preview_sha256': '0' * 64,
              'data': {
                'profile': {'display_name': 'Alex', 'handle': 'alex'},
                'title': 'Reviewed title',
                'introduction': 'Public introduction',
                'scope': 'Public fields only',
                'career_story': {'milestones': []},
                'projects': [],
                'evidence': [],
                'role_fit': null
              }
            }),
            200);
      return http.Response(jsonEncode(draft), 200);
    })))
          ..workspace = {
            'profile': {},
            'cv': {'projects': []},
            'evidence': [],
            'career_story': {'milestones': []}
          }
          ..reducedMotion = true;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: RecruiterPresentationEditor(controller: c)))));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Presentation title'),
        'Edited title');
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<OutlinedButton>(find.widgetWithText(
                OutlinedButton, 'Review public walkthrough'))
            .onPressed,
        isNull);
    await tester.ensureVisible(find.text('Save presentation'));
    await tester.tap(find.text('Save presentation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review public walkthrough'));
    await tester.pumpAndSettle();
    expect(find.text('Reviewed title'), findsOneWidget);
    expect(find.text('PRIVATE_NOTES'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Share reviewed walkthrough'));
    await tester.tap(find.text('Share reviewed walkthrough'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(publishes, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });

  for (final width in [390.0, 1440.0]) {
    testWidgets(
        'Recruiter walkthrough keyboard and source inspection at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final evidence = {
        'id': 'proof',
        'title': 'Reviewed source',
        'kind': 'certificate',
        'status': 'verified',
        'url': 'https://example.test/proof'
      };
      final data = {
        'profile': {'display_name': 'Alex', 'handle': 'alex'},
        'title': 'Selected recruiter story',
        'introduction': 'A focused introduction',
        'scope': 'Candidate-written narrative',
        'career_story': {
          'milestones': [
            {
              'date': '2026-01-01',
              'title': 'First release',
              'narrative': 'Built a service',
              'evidence': [evidence]
            }
          ]
        },
        'projects': [
          {'name': 'Selected API', 'description': 'Observable result'}
        ],
        'role_fit': null,
        'evidence': [evidence]
      };
      await tester
          .pumpWidget(MaterialApp(home: RecruiterWalkthrough(data: data)));
      await tester.pumpAndSettle();
      expect(find.text('Selected recruiter story'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('First release'), findsOneWidget);
      await tester.tap(find.text('Reviewed source'));
      await tester.pumpAndSettle();
      expect(find.textContaining('https://example.test/proof'), findsOneWidget);
      await tester.tap(find.text('Close evidence'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(find.text('Selected evidence'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(find.text('Selected recruiter story'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

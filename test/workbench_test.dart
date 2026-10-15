import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/evidence_workbench.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Owned comparison annotations and practice drafts at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime.now().toUtc();
      final comparison = {
        'id': 'cmp',
        'left_id': 's1',
        'right_id': 's2',
        'revision': 0,
        'annotations': <dynamic>[],
        'data': {
          'scope': 'Text comparison only',
          'operations': [
            ['replace', 0, 1, 0, 1]
          ]
        }
      };
      final session = <String, dynamic>{
        'id': 'sess',
        'status': 'active',
        'revision': 0,
        'started_at': now.toIso8601String(),
        'expires_at': now.add(const Duration(seconds: 60)).toIso8601String(),
        'questions': [
          {
            'id': '0',
            'skill': 'Docker',
            'prompt': 'Describe a real container decision'
          }
        ],
        'answers': <String, dynamic>{},
        'review': <String, dynamic>{},
        'feedback': <String, dynamic>{}
      };
      bool conflict = true;
      Map? savedAnswers;
      final c =
          WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        dynamic result;
        if (r.method == 'PUT' && r.url.path.endsWith('/annotations')) {
          if (conflict) {
            return http.Response('{"detail":"Annotations changed"}', 409);
          }
          final d = jsonDecode(r.body);
          comparison['annotations'] = d['annotations'];
          comparison['revision'] = 1;
          return http.Response('{"revision":1}', 200);
        }
        if (r.method == 'PUT') {
          savedAnswers = jsonDecode(r.body);
          session['answers'] = savedAnswers!['answers'];
          session['review'] = savedAnswers!['review'];
          session['revision'] = 1;
          return http.Response('{"revision":1}', 200);
        }
        if (r.url.path.endsWith('/snapshots')) {
          result = [
            for (final id in ['s1', 's2'])
              {
                'id': id,
                'status': 'ready',
                'kind': 'cv_version',
                'source_id': id,
                'data': {
                  'text': id == 's1' ? 'Docker claim' : 'Redis claim',
                  'scope': 'Structured metadata',
                  'source': {},
                  'truncated': false
                }
              }
          ];
        } else if (r.url.path.endsWith('/comparisons')) {
          result = [comparison];
        } else if (r.url.path.endsWith('/practice')) {
          result = {
            'server_now': now.toIso8601String(),
            'sessions': [session]
          };
        } else {
          result = {
            'document': {
              'reviewed': true,
              'requirements': [
                {'skill': 'Docker'}
              ]
            }
          };
        }
        return http.Response(jsonEncode(result), 200);
      })))
            ..workspace = {'evidence': [], 'versions': [], 'profile': {}}
            ..workbenchDraft = {
              'annotations': <String, dynamic>{},
              'practice': <String, dynamic>{},
              'requirements': <int>[],
              'evidence': <String>[],
              'comparisonId': 'cmp',
              'sessionId': 'sess'
            }
            ..reducedMotion = true;
      Future<void> open() => tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: EvidenceWorkbench(controller: c)))));
      await open();
      await tester.pumpAndSettle();
      expect(find.text('Docker claim'), findsOneWidget);
      expect(find.text('Redis claim'), findsOneWidget);
      await tester.ensureVisible(find.text('Add line annotation'));
      await tester.tap(find.text('Add line annotation'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Annotation'), 'Claim changed');
      await tester.tap(find.text('Keep annotation'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save annotations'));
      await tester.tap(find.text('Save annotations'));
      await tester.pumpAndSettle();
      expect(find.text('Annotations changed'), findsOneWidget);
      expect(
          c.workbenchDraft!['annotations']['cmp']['annotations'], hasLength(1));
      conflict = false;
      await tester.tap(find.text('Save annotations'));
      await tester.pumpAndSettle();
      expect(comparison['annotations'], hasLength(1));
      await tester.ensureVisible(find.text('Interview practice'));
      await tester.tap(find.text('Interview practice'));
      await tester.pumpAndSettle();
      final field = find.widgetWithText(TextFormField, 'Practice answer 0');
      await tester.ensureVisible(field);
      await tester.enterText(field, 'I measured a 20 percent improvement.');
      await tester.pumpWidget(const SizedBox());
      await open();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Interview practice'));
      await tester.pumpAndSettle();
      expect(c.workbenchDraft!['practice']['sess']['answers']['0'],
          'I measured a 20 percent improvement.');
      await tester.ensureVisible(find.text('Save practice answers'));
      await tester.tap(find.text('Save practice answers'));
      await tester.pumpAndSettle();
      expect(savedAnswers!['answers']['0'],
          'I measured a 20 percent improvement.');
      expect(tester.takeException(), isNull);
      session['expires_at'] =
          now.subtract(const Duration(seconds: 1)).toIso8601String();
      await tester.ensureVisible(find.text('Refresh workbench'));
      await tester.tap(find.text('Refresh workbench'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Practice time elapsed'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      c.dispose();
    });
  }
}

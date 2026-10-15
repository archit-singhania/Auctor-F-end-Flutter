import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/role_fit.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Reviewed role requirements and unknown evidence at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Map<String, dynamic> saved = {
        'revision': 0,
        'title': 'Target role',
        'description': 'Required Docker\nPreferred PostgreSQL',
        'reviewed': false,
        'requirements': []
      };
      final List runs = [];
      bool offline = false;
      final c =
          WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        if (offline) {
          throw http.ClientException('Offline fixture');
        }
        if (r.method == 'PUT') {
          saved = {...jsonDecode(r.body), 'revision': 1};
          return http.Response(jsonEncode(saved), 200);
        }
        if (r.method == 'POST') {
          expect(saved['reviewed'], true);
          runs.add({
            'id': 'sample-run',
            'result': {
              'coverage_percent': 0,
              'formula_version': 'v1',
              'vocabulary_version': 'skills-v1',
              'explanation': 'Unknown is not inability',
              'contributions': []
            }
          });
          return http.Response('{}', 201);
        }
        return http.Response(
            jsonEncode({
              'document': {
                'requirements': saved['requirements'],
                'reviewed': saved['reviewed'],
                'description': saved['description'],
                'title': saved['title'],
                'revision': saved['revision']
              },
              'runs': runs
            }),
            200);
      })))
            ..reducedMotion = true;
      Future<void> open() => tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: RoleFitWorkspace(controller: c)))));
      await open();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Suggest known requirements'));
      await tester.tap(find.text('Suggest known requirements'));
      await tester.pumpAndSettle();
      expect(c.roleDraft!['requirements'], hasLength(2));
      expect(c.roleDraft!['requirements'][1]['weight'], 1);
      await tester.pumpWidget(const SizedBox());
      await open();
      await tester.pumpAndSettle();
      expect(c.roleDraft!['requirements'], hasLength(2));
      await tester.ensureVisible(
          find.text('I reviewed these requirements and weights'));
      await tester.tap(find.text('I reviewed these requirements and weights'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save requirements'));
      await tester.tap(find.text('Save requirements'));
      await tester.pumpAndSettle();
      expect(saved['reviewed'], true);
      await tester.ensureVisible(find.text('Run evidence match'));
      await tester.tap(find.text('Run evidence match'));
      await tester.pumpAndSettle();
      expect(find.text('0% evidenced coverage'), findsOneWidget);
      expect(
          tester
              .widget<OutlinedButton>(
                  find.widgetWithText(OutlinedButton, 'Run evidence match'))
              .onPressed,
          isNotNull);
      expect(
          find.text(
              'Unsaved requirements · retained during navigation. Save before matching.'),
          findsNothing);
      await tester.ensureVisible(find.text('Reload role'));
      await tester.tap(find.text('Reload role'));
      await tester.pumpAndSettle();
      offline = true;
      await tester.tap(find.text('Reload saved role'));
      await tester.pumpAndSettle();
      expect(c.roleDraft!['requirements'], hasLength(2));
      expect(find.textContaining('Offline fixture'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      c.dispose();
    });
  }
}

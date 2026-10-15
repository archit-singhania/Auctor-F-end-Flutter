import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/career_story.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets(
        'Career story retains draft, validates dates and saves at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Map<String, dynamic>? received;
      final c =
          WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        received = Map<String, dynamic>.from(jsonDecode(r.body));
        return http.Response(jsonEncode({...received!, 'revision': 1}), 200);
      })))
            ..workspace = {
              'career_story': {'revision': 0, 'milestones': []},
              'evidence': []
            }
            ..reducedMotion = true;
      Future<void> open() => tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(child: CareerStory(controller: c)))));
      await open();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add milestone'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Title'), 'Built a verified API');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Date (YYYY-MM-DD)'),
          '2026-02-30');
      await tester.ensureVisible(find.text('Keep milestone'));
      await tester.tap(find.text('Keep milestone'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid calendar date'), findsOneWidget);
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Date (YYYY-MM-DD)'),
          '2026-02-28');
      await tester.ensureVisible(find.text('Keep milestone'));
      await tester.tap(find.text('Keep milestone'));
      await tester.pumpAndSettle();
      expect(c.careerDraft!['milestones'], hasLength(1));
      expect(received, isNull);
      await tester.pumpWidget(const SizedBox());
      await open();
      await tester.pumpAndSettle();
      expect(find.text('Built a verified API'), findsOneWidget);
      await tester.ensureVisible(find.text('Save story'));
      await tester.tap(find.text('Save story'));
      await tester.pumpAndSettle();
      expect(received!['revision'], 0);
      expect(received!['milestones'][0]['visible'], false);
      expect(find.text('Story saved · revision 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      c.dispose();
    });
  }
}

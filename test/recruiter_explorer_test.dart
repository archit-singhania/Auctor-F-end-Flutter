import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/recruiter_explorer.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Recruiter search and persistent tray at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Map prefs = {'revision': 0, 'candidate_ids': [], 'density': 'comfortable'};
      final person = {'profile': {'id': 1, 'handle': 'alex', 'display_name': 'Alex', 'bio': 'Candidate narrative'}, 'score': {'total': 1.0, 'components': {}}, 'skills': ['Python'], 'badges': [], 'evidence': [], 'saved': false};
      final controller = WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        if (r.url.path.endsWith('/candidates')) {
          return http.Response(jsonEncode(r.url.queryParameters['q'] == 'missing' ? [] : [person]), 200);
        }
        if (r.method == 'PUT') { prefs = {...jsonDecode(r.body), 'revision': prefs['revision'] + 1}; }
        return http.Response(jsonEncode({...prefs, 'candidates': (prefs['candidate_ids'] as List).isEmpty ? [] : [person], 'unavailable_count': 0, 'scope': 'Only discoverable profiles'}), 200);
      })));
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: RecruiterExplorer(controller: controller))))));
      final search = find.widgetWithText(TextField, 'Search name, handle or declared skill');
      await tester.enterText(search, 'Alex');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Compare Alex'));
      await tester.tap(find.text('Compare Alex'));
      await tester.pumpAndSettle();
      expect(prefs['candidate_ids'], [1]);
      await tester.ensureVisible(search);
      await tester.enterText(search, 'missing');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Saved comparison tray — 1 of 3 profiles'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

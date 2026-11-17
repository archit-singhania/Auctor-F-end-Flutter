import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/applications.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Application draft saves and retains edits at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Map<String, dynamic>? saved;
      final controller = WorkspaceController(api: PlatformApi(client: MockClient((request) async {
        if (request.method == 'PUT') {
          saved = {...jsonDecode(request.body), 'revision': 1};
          return http.Response(jsonEncode(saved), 200);
        }
        if (request.url.path.endsWith('/applications')) {
          return http.Response(jsonEncode(saved == null ? [] : [saved]), 200);
        }
        if (request.url.path.endsWith('/role-fit')) {
          return http.Response('{"runs":[]}', 200);
        }
        return http.Response('{"available_evidence":[]}', 200);
      })));
      Widget view() => ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: ApplicationWorkspace(controller: controller)))));
      await tester.pumpWidget(view());
      await tester.tap(find.text('New application'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Employer'), 'Example');
      await tester.enterText(find.widgetWithText(TextFormField, 'Role'), 'Engineer');
      await tester.ensureVisible(find.text('Save application'));
      await tester.tap(find.text('Save application'));
      await tester.pumpAndSettle();
      expect(saved!['employer'], 'Example');
      expect(controller.applicationDraft!['revision'], 1);
      expect(find.text('Engineer · Example'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(view());
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Example'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

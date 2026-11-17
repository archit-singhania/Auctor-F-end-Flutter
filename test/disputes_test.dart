import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/disputes.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Candidate appeal exposes response without reviewer decisions at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final dispute = {'id': 'appeal', 'user_id': 1, 'revision': 3, 'state': 'awaiting_information', 'reviewer_id': 2, 'data': {'requested_correction': 'Review issuer record'}, 'current_source': {'status': 'rejected'}, 'history': [], 'reviewers': []};
      final c = WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        final Object result = r.url.path.endsWith('/evidence-collection') ? {'available_evidence': []} : r.url.path.endsWith('/disputes') ? [dispute] : dispute;
        return http.Response(jsonEncode(result), 200);
      })))..workspace = {'profile': {'id': 1, 'role': 'developer'}};
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: DisputesWorkspace(controller: c))))));
      await tester.tap(find.text('Load disputes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Review issuer record'));
      await tester.pumpAndSettle();
      expect(find.text('Submit information'), findsOneWidget);
      expect(find.text('Withdraw dispute'), findsOneWidget);
      expect(find.text('Uphold original decision'), findsNothing);
      expect(find.text('Record reassignment'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

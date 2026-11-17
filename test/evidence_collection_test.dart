import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/evidence_collection.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Collection loads on request and preserves pending status at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var requests = 0;
      final controller = WorkspaceController(api: PlatformApi(client: MockClient((request) async {
        requests++;
        return http.Response(jsonEncode({'claims': [{'id': 'skill', 'title': 'Python', 'kind': 'skill', 'origin': 'CV', 'status': 'no eligible reviewed source', 'checklist': ['Select a work sample.'], 'scope': 'Candidate-selected source', 'linked': [{'id': 'source', 'title': 'Course', 'kind': 'certificate', 'status': 'pending', 'eligibility_state': 'current'}]}], 'available_evidence': []}), 200);
      })));
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: EvidenceCollection(controller: controller, submitEvidence: () async {}))))));
      await tester.pumpAndSettle();
      expect(requests, 0);
      await tester.tap(find.text('Load collection checklists'));
      await tester.pumpAndSettle();
      expect(requests, 1);
      await tester.tap(find.text('Python'));
      await tester.pumpAndSettle();
      expect(find.text('Select a work sample.'), findsOneWidget);
      expect(find.text('certificate · pending · current'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

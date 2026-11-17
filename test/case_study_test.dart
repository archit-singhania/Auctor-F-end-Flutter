import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/case_study.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Case study requires explicit public confirmation at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var publishes = 0;
      final data = {'revision': 1, 'title': 'My project', 'scope': 'Candidate-written narrative', 'sections': [for (final kind in ['problem', 'contribution', 'approach', 'outcome', 'reflection']) {'kind': kind, 'text': 'Example narrative', 'evidence_ids': [], 'evidence': []}]};
      final c = WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        if (r.method == 'POST') { publishes++; return http.Response('{}', 201); }
        if (r.url.path.endsWith('/shares')) { return http.Response('[]', 200); }
        if (r.url.path.endsWith('/evidence-collection')) { return http.Response('{"available_evidence":[]}', 200); }
        if (r.url.path.endsWith('/preview')) { return http.Response(jsonEncode({'data': data, 'sha256': 'a' * 64}), 200); }
        return http.Response(jsonEncode(data), 200);
      })));
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: CaseStudyBuilder(controller: c))))));
      await tester.tap(find.text('Load case study'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Preview saved publication'));
      await tester.tap(find.text('Preview saved publication'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(publishes, 0);
      expect(find.text('Candidate-written narrative'), findsOneWidget);
      await tester.tap(find.text('Close preview'));
      await tester.pumpAndSettle();
      expect(publishes, 0);
      expect(tester.takeException(), isNull);
    });
  }
}

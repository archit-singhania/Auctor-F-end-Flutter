import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/assessment_quality.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Quality report suppresses small cohorts and requires confirmation at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var writes = 0;
      final c = WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        if (r.method == 'POST') { writes++; }
        final Object value = r.url.path.endsWith('/report') ? {'suppressed': true, 'eligible_completed': 3, 'scope': 'Whole-attempt timing only'} : {'version': 1, 'questions': [], 'history': []};
        return http.Response(jsonEncode(value), 200);
      })))..workspace = {'profile': {'role': 'reviewer'}};
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: AssessmentQuality(controller: c))))));
      await tester.tap(find.text('Load assessment quality'));
      await tester.pumpAndSettle();
      expect(find.text('Statistics suppressed — fewer than 20 eligible completed attempts'), findsOneWidget);
      await tester.ensureVisible(find.text('Review publication preview'));
      await tester.tap(find.text('Review publication preview'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(writes, 0);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(writes, 0);
      expect(tester.takeException(), isNull);
    });
  }
}

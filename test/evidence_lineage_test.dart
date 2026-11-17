import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/evidence_lineage.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Withdrawn source retains inspectable history at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        final Object value = r.url.path.endsWith('/lineage') ? [{'evidence_id': 'one', 'title': 'Original source', 'operation': 'DELETE', 'captured_at': '2026-11-16'}] : {'evidence_id': 'one', 'withdrawn': true, 'currently_eligible': false, 'scope': 'Historical source, not proof of truth', 'revisions': [{'id': 1, 'operation': 'INSERT', 'captured_at': '2026-11-16', 'sha256': 'a' * 64, 'payload': {'title': 'Original source'}}], 'downstream': []};
        return http.Response(jsonEncode(value), 200);
      })));
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: EvidenceLineage(controller: c))))));
      await tester.tap(find.text('Load source history'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trace source'));
      await tester.pumpAndSettle();
      expect(find.text('Source withdrawn; history retained'), findsOneWidget);
      await tester.tap(find.text('Source revision 1 · INSERT'));
      await tester.pumpAndSettle();
      expect(find.textContaining('SHA-256'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

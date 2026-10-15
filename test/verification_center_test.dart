import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/verification_center.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets(
        'Verification ownership and cancelled recruiter consent at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final workspace = {
        'profile': {'id': 7, 'role': 'developer', 'preferences': {}},
        'evidence': []
      };
      int writes = 0;
      final c =
          WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        if (r.method != 'GET') {
          writes++;
          return http.Response('{}', 200);
        }
        if (r.url.path.endsWith('/me')) {
          return http.Response(jsonEncode(workspace), 200);
        }
        if (r.url.path.endsWith('/verification/evidence')) {
          return http.Response(
              jsonEncode([
                {
                  'id': 'proof',
                  'user_id': 7,
                  'title': 'Owned eligible source',
                  'kind': 'certificate',
                  'status': 'verified',
                  'eligibility_state': 'current',
                  'review_due_at': null
                }
              ]),
              200);
        }
        if (r.url.path.endsWith('/verification/receipts')) {
          return http.Response(
              jsonEncode([
                {
                  'id': 'receipt',
                  'revoked': false,
                  'payload': {'scope': 'Reviewed evidence scope'}
                }
              ]),
              200);
        }
        if (r.url.path.endsWith('/verification/receipts/receipt')) {
          return http.Response(
              '{"status":{"signature_valid":true,"currently_eligible":true,"revoked":false}}',
              200);
        }
        return http.Response('[]', 200);
      })))
            ..workspace = workspace
            ..reducedMotion = true;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: VerificationCenter(controller: c)))));
      await tester.pumpAndSettle();
      expect(find.text('Owned eligible source'), findsOneWidget);
      expect(find.text('Review eligibility'), findsNothing);
      await tester.ensureVisible(find.text('Check receipt status'));
      await tester.tap(find.text('Check receipt status'));
      await tester.pumpAndSettle();
      expect(find.textContaining('signature_valid'), findsOneWidget);
      await tester.tap(find.text('Close details'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Authorize recruiter integration'));
      await tester.tap(
          find.widgetWithText(FilledButton, 'Authorize recruiter integration'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<FilledButton>(
                  find.widgetWithText(FilledButton, 'Create scoped credential'))
              .onPressed,
          isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(writes, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      c.dispose();
    });
  }
}

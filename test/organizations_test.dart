import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/organizations.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Organization membership and withdrawn consent layout at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        final Object value = r.url.path.endsWith('/organizations') ? [{'id': 'team', 'name': 'Research team', 'role': 'owner'}] : {'id': 'team', 'name': 'Research team', 'role': 'owner', 'revision': 0, 'candidate_ids': [], 'members': [{'user_id': 1, 'display_name': 'Owner', 'role': 'owner'}], 'profiles': [], 'invitations': [], 'unavailable_count': 1, 'history': []};
        return http.Response(jsonEncode(value), 200);
      })));
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: OrganizationWorkspace(controller: c))))));
      await tester.tap(find.text('Load organizations'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Research team'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Members and invitations'));
      await tester.pumpAndSettle();
      expect(find.text('Owner'), findsOneWidget);
      expect(find.byTooltip('Remove Owner'), findsNothing);
      expect(find.text('1 saved profiles are withheld because consent is unavailable.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

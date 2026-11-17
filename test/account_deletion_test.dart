import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/account_deletion.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Deletion requires review and preserves ownership blocker at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var writes = 0;
      final controller = WorkspaceController(api: PlatformApi(client: MockClient((request) async {
        if (request.method != 'GET') writes++;
        return http.Response(jsonEncode({'handle': 'fixture', 'scope': 'Owned data', 'backup_policy_days': 30, 'counts': {'evidence': 2}, 'owned_organizations': [{'name': 'Owned team'}]}), 200);
      })));
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: AccountDeletion(controller: controller))))));
      expect(find.text('Review final deletion confirmation'), findsNothing);
      await tester.tap(find.text('Review deletion inventory'));
      await tester.pumpAndSettle();
      expect(find.text('Owned team'), findsOneWidget);
      expect(find.text('Review final deletion confirmation'), findsNothing);
      expect(writes, 0);
      expect(tester.takeException(), isNull);
    });
  }
}

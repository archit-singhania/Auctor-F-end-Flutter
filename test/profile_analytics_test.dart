import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/profile_analytics.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('Analytics consent and reset at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var enabled = false, resets = 0;
      final c = WorkspaceController(api: PlatformApi(client: MockClient((r) async {
        if (r.method == 'PUT') { enabled = jsonDecode(r.body)['enabled']; }
        if (r.method == 'DELETE') { resets++; }
        return http.Response(jsonEncode({'enabled': enabled, 'days': [], 'scope': 'Approximate interactions, not unique people.'}), 200);
      })));
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: ProfileAnalytics(controller: c))))));
      await tester.tap(find.text('Load analytics'));
      await tester.pumpAndSettle();
      expect(enabled, isFalse);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(enabled, isTrue);
      await tester.tap(find.text('Reset analytics'));
      await tester.pumpAndSettle();
      expect(resets, 0);
      await tester.tap(find.text('Delete counts'));
      await tester.pumpAndSettle();
      expect(resets, 1);
      expect(enabled, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}

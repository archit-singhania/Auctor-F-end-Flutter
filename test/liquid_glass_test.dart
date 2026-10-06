import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:auctor_app/main.dart';
import 'package:auctor_app/premium/app.dart';
import 'package:auctor_app/premium/controller.dart';
import 'package:auctor_app/premium/liquid_glass.dart';
import 'premium_test.dart' show FixtureController;

class StalledBodyClient extends http.BaseClient {
  final body = StreamController<List<int>>();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(body.stream, 200);
}

void main() {
  testWidgets('Navigation announces its label once and remains actionable',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: GlassDestination(
                  label: 'Evidence',
                  icon: Icons.layers_outlined,
                  selected: true,
                  onTap: () => tapped = true))));
      expect(find.bySemanticsLabel('Evidence'), findsOneWidget);
      expect(find.bySemanticsLabel('Evidence Evidence'), findsNothing);
      await tester.tap(find.text('Evidence'));
      expect(tapped, isTrue);
    } finally {
      semantics.dispose();
    }
  });
  for (final size in [const Size(390, 844), const Size(1440, 1000)]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('All evidence destinations use readable glass at $size/$mode',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final fixture = FixtureController(signedIn: true)..previewTheme(mode);
        await tester.pumpWidget(ProviderScope(
            overrides: [workspaceProvider.overrideWith((ref) => fixture)],
            child: const AuctorApp()));
        await tester.pumpAndSettle();
        for (var destination = 0; destination < 6; destination++) {
          fixture.select(destination);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: 'Destination $destination at $size/$mode');
          expect(find.byType(LiquidGlass), findsWidgets);
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  testWidgets(
      'Large text keeps mobile navigation reachable and contrast disables blur',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = FixtureController(signedIn: true)
      ..highContrast = true
      ..reducedMotion = true
      ..reducedTransparency = true;
    await tester.pumpWidget(ProviderScope(
        overrides: [workspaceProvider.overrideWith((ref) => fixture)],
        child: MaterialApp(
            theme: theme(Brightness.light, highContrast: true),
            home: const MediaQuery(
                data: MediaQueryData(
                    size: Size(390, 844),
                    textScaler: TextScaler.linear(1.8),
                    highContrast: true,
                    disableAnimations: true),
                child: WorkspacePage()))));
    await tester.pumpAndSettle();
    for (var destination = 0; destination < 6; destination++) {
      fixture.select(destination);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'Large text destination $destination');
    }
    expect(
        tester
            .widgetList<BackdropFilter>(find.byType(BackdropFilter))
            .every((filter) => !filter.enabled),
        isTrue);
    expect(find.text('Profile'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });
  test('Accessibility preferences persist through the API contract', () async {
    Map<String, dynamic>? written;
    final controller = WorkspaceController(
        api: PlatformApi(client: MockClient((request) async {
      if (request.method == 'PATCH') {
        written = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{"ok":true}', 200);
      }
      return http.Response(
          jsonEncode({
            'profile': {
              'display_name': 'QA',
              'bio': '',
              'discoverable': false,
              'preferences': written?['preferences'] ?? {}
            }
          }),
          200);
    })))
      ..workspace = {
        'profile': {'display_name': 'QA'}
      };
    await controller.preferences(
        mode: ThemeMode.dark, motion: true, transparency: true, contrast: true);
    expect(controller.theme, ThemeMode.dark);
    expect(
        controller.reducedMotion &&
            controller.reducedTransparency &&
            controller.highContrast,
        isTrue);
    expect(written?['preferences']['high_contrast'], true);
    controller.dispose();
  });
  test('An HTTP body stalled after headers has a bounded deadline', () async {
    final client = StalledBodyClient();
    final api = PlatformApi(
        client: client, requestTimeout: const Duration(milliseconds: 40));
    await expectLater(api.call('/me'), throwsA(isA<TimeoutException>()));
    await client.body.close();
    client.close();
  });
  test(
      'Offline sign-out clears private local state and explains remote revocation',
      () async {
    FlutterSecureStorage.setMockInitialValues(
        {'auctor-session': 'local-test-session'});
    final controller = WorkspaceController(
        api: PlatformApi(
            client: MockClient((request) async =>
                http.Response('{"detail":"Unavailable"}', 503))));
    controller.api.token = 'local-test-session';
    controller.workspace = {
      'profile': {'display_name': 'Private test account'}
    };
    await controller.logout();
    expect(controller.api.token, isNull);
    expect(controller.workspace, isNull);
    expect(await controller.storage.read(key: 'auctor-session'), isNull);
    expect(controller.error, contains('could not revoke'));
    controller.dispose();
  });
}

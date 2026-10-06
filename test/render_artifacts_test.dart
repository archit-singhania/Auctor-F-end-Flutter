// Optional offscreen software-rendering artifacts. These are labelled fixtures.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auctor_app/main.dart';
import 'package:auctor_app/premium/app.dart';
import 'premium_test.dart' show FixtureController;

void main() {
  final fontRoot = Platform.environment['AUCTOR_QA_FONT_ROOT'];
  if (fontRoot == null) return;
  setUpAll(() async {
    for (final family in ['Inter', 'Newsreader']) {
      final bundled = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$family.ttf'));
      await bundled.load();
    }
    final body = FontLoader('Roboto');
    for (final file in [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
      'roboto-light.ttf'
    ]) {
      body.addFont(File('$fontRoot/$file')
          .readAsBytes()
          .then((bytes) => ByteData.view(bytes.buffer)));
    }
    await body.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(File('$fontRoot/materialicons-regular.otf')
          .readAsBytes()
          .then((bytes) => ByteData.view(bytes.buffer)));
    await icons.load();
  });
  for (final entry in [
    ('landing-desktop', false, 1440.0, 1050.0, 0),
    ('overview-desktop', true, 1440.0, 1050.0, 0),
    ('overview-mobile', true, 390.0, 844.0, 0),
    ('overview-dark', true, 1440.0, 1050.0, 0),
    ('evidence-desktop', true, 1440.0, 1050.0, 1)
  ]) {
    testWidgets('Render ${entry.$1}', (tester) async {
      tester.view.physicalSize = Size(entry.$3, entry.$4);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = FixtureController(signedIn: entry.$2)..select(entry.$5);
      if (entry.$1.contains('dark')) fixture.previewTheme(ThemeMode.dark);
      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
          key: key,
          child: ProviderScope(
              overrides: [workspaceProvider.overrideWith((ref) => fixture)],
              child: const AuctorApp())));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final capture = await boundary.toImage(pixelRatio: 1);
        final bytes = await capture.toByteData(format: ui.ImageByteFormat.png);
        final out = Directory('build/qa');
        await out.create(recursive: true);
        await File('${out.path}/${entry.$1}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
      });
      await tester.pumpWidget(const SizedBox());
    });
  }
}

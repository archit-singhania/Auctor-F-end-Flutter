import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auctor_app/main.dart';

void main() {
  testWidgets('AuctorApp smoke test — renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AuctorApp()),
    );
    // App mounts successfully if no exception is thrown.
    expect(tester.takeException(), isNull);
  });
}

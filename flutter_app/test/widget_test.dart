import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App title and bottom navigation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app bar title is rendered.
    expect(find.text('Linedance Community'), findsOneWidget);

    // Verify the bottom navigation labels exist.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('All Dances'), findsOneWidget);
  });
}

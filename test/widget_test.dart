// Basic smoke test for the app shell and the home entry-logging flow.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tracking_system_motion/app/app.dart';

void main() {
  testWidgets('logs a new entry from the home page', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('No entries yet.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Went for a run');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Went for a run'), findsOneWidget);
    expect(find.text('No entries yet.'), findsNothing);
  });
}

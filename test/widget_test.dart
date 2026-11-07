// Smoke test for the checklist app shell: create a checklist manually, add
// an item, and check it off. Uses a temp-dir Hive instance instead of
// hive_flutter's platform-channel init, since widget tests run without a
// real platform.
//
// flutter_test runs the test body in a synthetic time zone that never
// drains real OS-level async I/O on its own — a genuine disk write (Hive's
// Box.put) never completes under plain pump()/pumpAndSettle(). Real async
// work has to run inside `runAsync`, which briefly switches to the real
// zone. Note this test deliberately does NOT call Hive's Box.close() /
// deleteFromDisk() in tearDown: that call itself hangs indefinitely in this
// same environment (a known Hive/flutter_test friction point) even wrapped
// in runAsync. Each run gets its own unique temp directory, so skipping
// cleanup only leaves harmless litter in the OS temp folder — it doesn't
// affect correctness or test isolation.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:tracking_system_motion/app/app.dart';
import 'package:tracking_system_motion/features/checklist/data/checklist_repository.dart';

Future<void> _settleRealAsync(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
}

void main() {
  late ChecklistRepository repository;

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('checklist_test');
    Hive.init(tempDir.path);
    repository = ChecklistRepository();
    await repository.init();
  });

  testWidgets('creates a checklist manually, adds an item, checks it off', (
    tester,
  ) async {
    await tester.pumpWidget(App(checklistRepository: repository));
    await tester.pumpAndSettle();

    expect(
      find.text('No checklists yet. Add one with the + button.'),
      findsOneWidget,
    );

    // Create a checklist via the manual "+" FAB.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'My Checklist');
    await tester.tap(find.text('Create'));
    await _settleRealAsync(tester);

    expect(find.text('My Checklist'), findsOneWidget);

    // Open it.
    await tester.tap(find.text('My Checklist'));
    await tester.pumpAndSettle();

    expect(find.text('No items yet.'), findsOneWidget);

    // Add an item.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Buy groceries');
    await tester.tap(find.text('Add'));
    await _settleRealAsync(tester);

    expect(find.text('Buy groceries'), findsOneWidget);
    expect(find.text('No items yet.'), findsNothing);

    // Check it off.
    await tester.tap(find.byType(Checkbox));
    await _settleRealAsync(tester);

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
  });
}

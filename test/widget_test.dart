import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_dating_app/main.dart';

void main() {
  testWidgets('App Boots Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: StudentDatingApp()));

    // Verify that the app starts without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

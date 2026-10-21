import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        anonKey: 'dummy-anon-key',
      );
    } catch (_) {}
  });

  testWidgets('App Boots Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: StudentDatingApp()));

    // Verify that the app starts without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

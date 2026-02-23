import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/core/config/supabase_config.dart';
import 'package:student_dating_app/core/routing/app_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Could not load .env file: $e');
  }

  // Try to initialize Supabase. If the keys are still the placeholders,
  // we can catch the error so the app doesn't completely crash on boot,
  // allowing us to still see the UI while you get the keys.
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint(
      'Supabase initialization failed (likely placeholders). Please update supabase_config.dart',
    );
  }

  runApp(const ProviderScope(child: StudentDatingApp()));
}

class StudentDatingApp extends ConsumerWidget {
  const StudentDatingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Intent',
      theme: AppTheme.lightTheme,
      darkTheme:
          AppTheme.lightTheme, // Force light theme everywhere for this version
      themeMode:
          ThemeMode.light, // Default to light mode for the warm aesthetic
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

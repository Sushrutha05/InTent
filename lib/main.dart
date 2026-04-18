import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_dating_app/firebase_options.dart';
import 'package:student_dating_app/core/notifications/notification_service.dart';
import 'package:student_dating_app/core/config/supabase_config.dart';
import 'package:student_dating_app/core/routing/app_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase (Required for Push Notifications)
  // Note: You must run 'flutterfire configure' to generate firebase_options.dart
  try {
    // We use the generated configuration for full functionality
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint(
      'Supabase initialization failed. Please verify supabase_config.dart',
    );
  }

  // Initialize Notification Service in the background (Non-blocking)
  NotificationService().initialize();

  runApp(const ProviderScope(child: StudentDatingApp()));
}

class StudentDatingApp extends ConsumerWidget {
  const StudentDatingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'InTent',
      theme: AppTheme.lightTheme,
      darkTheme:
          AppTheme.lightTheme, // Force light theme everywhere for this version
      themeMode:
          ThemeMode.light, // Default to light mode for the warm aesthetic
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}

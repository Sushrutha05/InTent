import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/features/auth/domain/auth_state.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  SplashScreenState();
  @override
  void initState() {
    super.initState();
    // Start auth check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  void _routeBasedOnAuth(AuthState state) {
    state.maybeWhen(
      unauthenticated: () {
        if (mounted) {
          context.go('/login');
        }
      },
      authenticated: (user) async {
        if (!mounted) return;
        try {
          final supabase = Supabase.instance.client;
          final profile = await supabase
              .from('profiles')
              .select('is_onboarded')
              .eq('id', user.id)
              .maybeSingle();

          final bool isOnboarded =
              profile != null ? (profile['is_onboarded'] as bool? ?? false) : false;

          if (mounted) {
            if (isOnboarded) {
              context.go('/');
            } else {
              context.go('/onboarding/intent');
            }
          }
        } catch (e) {
          debugPrint('Splash Screen DB Error: $e');
          if (mounted) {
            context.go('/onboarding/intent');
          }
        }
      },
      orElse: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen for state changes
    ref.listen(authProvider, (previous, next) {
      _routeBasedOnAuth(next);
    });

    // 2. Check current state in case it resolved instantly before the listener was attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(authProvider);
      currentState.maybeWhen(
        loading: () {}, // Do nothing if still loading
        initial: () {}, // Do nothing if initial
        orElse: () => _routeBasedOnAuth(currentState),
      );
    });

    // Show the logo with a loading indicator to signify background checks
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('lib/images/Intent_logo.png'),
              height: 88,
              width: 88,
            ),
            const SizedBox(height: 32), // Space between logo and loader
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}


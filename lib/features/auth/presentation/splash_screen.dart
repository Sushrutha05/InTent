import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/services/onboarding_service.dart';
import 'package:student_dating_app/features/auth/domain/auth_state.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(authProvider);
      current.maybeWhen(
        authenticated: (user) => _routeBasedOnAuth(current),
        unauthenticated: () => _routeBasedOnAuth(current),
        orElse: () => ref.read(authProvider.notifier).checkAuth(),
      );
    });
  }

  Future<void> _routeBasedOnAuth(AuthState state) async {
    if (_isNavigating || !mounted) return;

    await state.maybeWhen(
      unauthenticated: () async {
        if (!mounted || _isNavigating) return;
        _isNavigating = true;
        context.go('/login');
      },
      authenticated: (user) async {
        if (!mounted || _isNavigating) return;
        _isNavigating = true;

        final bool isOnboarded = await OnboardingService.isOnboarded(user.id);
        if (mounted) {
          if (isOnboarded) {
            context.go('/');
          } else {
            context.go('/onboarding/intent');
          }
        }
      },
      orElse: () async {},
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


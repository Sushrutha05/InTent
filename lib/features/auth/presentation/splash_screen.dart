import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _taglineFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Simulate initial loading sequence before deciding routing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes to route appropriately
    // Usually this is handled directly in a router redirect, but listening here
    // allows us to ensure the splash animation plays out gracefully first.
    ref.listen(authProvider, (previous, next) {
      next.maybeWhen(
        unauthenticated: () {
          // Delay routing slightly so animation isn't jarringly cut off
          Future.delayed(const Duration(milliseconds: 800), () {
            if (context.mounted) context.go('/login');
          });
        },
        authenticated: (user) {
          Future.delayed(const Duration(milliseconds: 800), () async {
            if (!context.mounted) return;
            try {
              final supabase = Supabase.instance.client;
              // Check if user actually finished onboarding
              final profile =
                  await supabase
                      .from('profiles')
                      .select('is_onboarded')
                      .eq('id', user.id)
                      .maybeSingle();

              final bool isOnboarded =
                  profile != null
                      ? (profile['is_onboarded'] as bool? ?? false)
                      : false;

              if (context.mounted) {
                if (isOnboarded) {
                  context.go('/');
                } else {
                  context.go('/onboarding/intent');
                }
              }
            } catch (e) {
              debugPrint('Splash Screen DB Error: $e');
              if (context.mounted) context.go('/onboarding/intent');
            }
          });
        },
        orElse: () {},
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage('lib/images/Intent_logo.png'),
                      height: 88,
                      width: 88,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Intent',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 48,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _taglineFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _taglineFadeAnimation.value,
                          child: Text(
                            'Real Connections. Student-First.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontSize: 14, letterSpacing: 0.5),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

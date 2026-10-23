import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_dating_app/features/auth/presentation/login_screen.dart';
import 'package:student_dating_app/features/auth/presentation/signup_screen.dart';
import 'package:student_dating_app/features/auth/presentation/splash_screen.dart';
import 'package:student_dating_app/features/onboarding/presentation/screens/intent_selection_screen.dart';
import 'package:student_dating_app/features/onboarding/presentation/screens/basic_info_screen.dart';
import 'package:student_dating_app/features/onboarding/presentation/screens/photo_upload_screen.dart';
import 'package:student_dating_app/features/discovery/presentation/screens/main_navigation_screen.dart';
import 'package:student_dating_app/features/matching/presentation/screens/match_confirmation_screen.dart';
import 'package:student_dating_app/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/discovery/presentation/screens/full_screen_image_screen.dart';
import 'package:student_dating_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:student_dating_app/features/profile/presentation/screens/settings_screen.dart';
import 'package:student_dating_app/features/explore/presentation/screens/campus_explore_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/core/services/onboarding_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// A listener that triggers GoRouter refresh when authentication state changes.
class RouterListenable extends ChangeNotifier {
  RouterListenable(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = RouterListenable(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: listenable,
    errorBuilder: (context, state) {
      debugPrint('GoRouter navigation error on location ${state.uri}: ${state.error}');
      return const MainNavigationScreen();
    },

    // Redirect logic for onboarding & security
    redirect: (context, state) async {
      final authState = ref.read(authProvider);

      final isAuthenticated = authState.maybeMap(
        authenticated: (_) => true,
        orElse: () => false,
      );

      final isLoading = authState.maybeMap(
        loading: (_) => true,
        initial: (_) => true,
        orElse: () => false,
      );

      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isOnboarding = state.matchedLocation.startsWith('/onboarding');

      // 1. If we are just starting or loading:
      if (isLoading) {
        if (isLoggingIn || isSigningUp || isSplash) return null;
        return '/splash';
      }

      // Let the Splash Screen handle initial routing
      if (isSplash) return null;

      // 2. If NOT authenticated:
      if (!isAuthenticated && !isLoading) {
        if (isLoggingIn || isSigningUp) return null;
        return '/login';
      }

      // 3. If authenticated:
      if (isAuthenticated) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final bool onboarded = await OnboardingService.isOnboarded(user.id);

          // If the user has already onboarded:
          // Never allow them to see login, signup, splash, or onboarding
          if (onboarded) {
            if (isLoggingIn || isSigningUp || isOnboarding) {
              return '/';
            }
          } else {
            // First time login / not onboarded yet:
            // Must complete onboarding
            if (!isOnboarding) {
              return '/onboarding/intent';
            }
          }
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding/intent',
        name: 'onboarding_intent',
        builder: (context, state) => const IntentSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/info',
        name: 'onboarding_info',
        builder: (context, state) => const BasicInfoScreen(),
      ),
      GoRoute(
        path: '/onboarding/photos',
        name: 'onboarding_photos',
        builder: (context, state) => const PhotoUploadScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/match',
        name: 'match',
        builder: (context, state) {
          final profile = state.extra as ProfileCardModel;
          return MatchConfirmationScreen(matchedProfile: profile);
        },
      ),
      GoRoute(
        path: '/chat',
        redirect: (context, state) => '/',
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat_room',
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          return ChatRoomScreen(chatId: chatId);
        },
      ),
      GoRoute(
        path: '/image',
        name: 'full_image',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, String>;
          return CustomTransitionPage(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 350),
            reverseTransitionDuration: const Duration(milliseconds: 350),
            child: FullScreenImageScreen(
              imageUrl: data['imageUrl']!,
              heroTag: data['heroTag']!,
            ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCubic,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit_profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/explore',
        name: 'explore',
        builder: (context, state) => const CampusExploreScreen(),
      ),
    ],
  );
});

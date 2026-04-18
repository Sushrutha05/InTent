import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_dating_app/features/auth/presentation/login_screen.dart';
import 'package:student_dating_app/features/auth/presentation/splash_screen.dart';
import 'package:student_dating_app/features/onboarding/presentation/screens/intent_selection_screen.dart';
import 'package:student_dating_app/features/onboarding/presentation/screens/basic_info_screen.dart';
import 'package:student_dating_app/features/onboarding/presentation/screens/photo_upload_screen.dart';
import 'package:student_dating_app/features/discovery/presentation/screens/discovery_feed_screen.dart';
import 'package:student_dating_app/features/matching/presentation/screens/match_confirmation_screen.dart';
import 'package:student_dating_app/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:student_dating_app/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/intents/presentation/screens/my_intents_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// A listener that triggers GoRouter refresh when authentication state changes.
class RouterListenable extends ChangeNotifier {
  RouterListenable(WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // We use this to trigger a refresh whenever auth state changes
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    
    // Redirect logic for security (HIGH-1)
    redirect: (context, state) {
      final isAuthenticated = authState.maybeMap(
        authenticated: (_) => true,
        orElse: () => false,
      );
      
      final isLoading = authState.maybeMap(
        loading: (_) => true,
        orElse: () => false,
      );

      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';

      // 1. If we are just starting or loading, stay on splash
      if (isLoading && !isSplash) return '/splash';

      // 2. If NOT authenticated:
      // - If trying to access guarded routes, force to login
      // - If already on splash or login, stay there
      if (!isAuthenticated) {
        if (isLoggingIn || isSplash) return null;
        return '/login';
      }

      // 3. If authenticated:
      // - If on login or splash, redirect to home
      // - Otherwise, let them through
      if (isLoggingIn || isSplash) return '/';

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
        builder: (context, state) => const DiscoveryFeedScreen(),
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
        path: '/intents',
        name: 'intents',
        builder: (context, state) => const MyIntentsScreen(),
      ),
      GoRoute(
        path: '/chats',
        name: 'chat_list',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat_room',
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          return ChatRoomScreen(chatId: chatId);
        },
      ),
    ],
  );
});

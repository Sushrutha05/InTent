import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
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
  // Note: For a real enterprise app, redirect logic would be handled here based on Riverpod watch
  // Example:
  // redirect: (context, state) {
  //    final authState = ref.read(authProvider);
  //    final isAuth = authState is _Authenticated;
  //    final isLoggingIn = state.matchedLocation == '/login'; ...
  // }
);

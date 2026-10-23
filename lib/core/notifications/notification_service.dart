import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/routing/app_router.dart';
import 'package:student_dating_app/features/chat/domain/chat_message_payload.dart';
import 'package:dio/dio.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  // This function runs in a separate isolate when the app is CLOSED
  await Firebase.initializeApp();

  final data = message.data;
  final title = data['title'] ?? 'New Message';
  final rawBody = data['body'] ?? '';
  final displayBody = ChatMessageFormatter.formatPreview(rawBody);
  final photoUrl = data['sender_photo'];
  final matchId = data['match_id']?.toString();

  // Try to fetch user photo for native icons
  AndroidBitmap<Uint8List>? largeIcon;
  if (photoUrl != null && photoUrl.toString().isNotEmpty) {
    try {
      final response = await Dio().get<Uint8List>(
        photoUrl.toString(),
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null) {
        largeIcon = ByteArrayAndroidBitmap(response.data!);
      }
    } catch (e) {
      debugPrint('FCM BG: Failed to fetch notification photo: $e');
    }
  }

  final NotificationDetails details = NotificationDetails(
    android: AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: largeIcon,
    ),
  );

  // We use a low-level call here because the plugin instance isn't shared across isolates
  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await plugin.initialize(const InitializationSettings(android: androidInit));

  await plugin.show(message.hashCode, title, displayBody, details, payload: matchId);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static String? currentlyOpenChatId;

  static void handleNotificationClick(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      debugPrint('Notification click: empty payload, navigating to home');
      rootNavigatorKey.currentContext?.go('/');
      return;
    }
    final cleanId = payload.trim();
    debugPrint('Notification click: routing to $cleanId');
    if (cleanId.startsWith('/')) {
      rootNavigatorKey.currentContext?.push(cleanId);
    } else {
      rootNavigatorKey.currentContext?.push('/chat/$cleanId');
    }
  }
  bool _isInitialized = false;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // IMPORTANT: In some environments, multiple initializations occur.
    // Ensure the background handler is ONLY registered once globally.
    try {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    } catch (e) {
      debugPrint('FCM: Background handler already registered or failed: $e');
    }

    // 1. Request permissions (especially for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // 2. Initialize local notifications for foreground messages
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        handleNotificationClick(details.payload);
      },
    );

    // Check if app was opened via local notification
    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchDetails?.notificationResponse?.payload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationClick(launchDetails!.notificationResponse!.payload);
      });
    }

    // 3. Create Android notification channel
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    // 4. Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
        'FCM: Message received in foreground! ID: ${message.messageId}',
      );
      final data = message.data;
      debugPrint('FCM: Payload data: $data');

      final matchId = data['match_id']?.toString();

      // Don't show notification if we are already in this specific chat
      if (matchId != null && matchId == currentlyOpenChatId) {
        debugPrint(
          'FCM: Suppressing notification because user is in this chat: $matchId',
        );
        return;
      }

      // Format body cleanly so games, snaps, and replies look great
      final title = data['title'] ?? 'New Message';
      final rawBody = data['body'] ?? '';
      final displayBody = ChatMessageFormatter.formatPreview(rawBody);
      final photoUrl = data['sender_photo'];

      if (!kIsWeb) {
        debugPrint('FCM: Triggering RICH System Banner for: $title');

        // Try to fetch the user's photo for the native icon
        AndroidBitmap<Uint8List>? largeIcon;
        if (photoUrl != null && photoUrl.toString().isNotEmpty) {
          try {
            final response = await Dio().get<Uint8List>(
              photoUrl.toString(),
              options: Options(responseType: ResponseType.bytes),
            );
            if (response.data != null) {
              largeIcon = ByteArrayAndroidBitmap(response.data!);
            }
          } catch (e) {
            debugPrint('FCM: Failed to fetch notification photo: $e');
          }
        }

        _localNotifications.show(
          message.hashCode,
          title,
          displayBody,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              largeIcon: largeIcon,
            ),
          ),
          payload: matchId,
        );
      }
    });

    // 5. Handle tapping notification when app is in BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM: Notification tapped in background: ${message.data}');
      handleNotificationClick(message.data['match_id']?.toString());
    });

    // 6. Handle tapping notification when app is TERMINATED (Cold start)
    try {
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('FCM: Notification opened cold app: ${initialMessage.data}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handleNotificationClick(initialMessage.data['match_id']?.toString());
        });
      }
    } catch (e) {
      debugPrint('FCM: Failed reading initialMessage: $e');
    }

    // 5. Setup Token Refresh Listener
    _fcm.onTokenRefresh.listen((newToken) {
      _saveTokenToSupabase(newToken);
    });

    // 6. Setup Supabase Auth Listener to update token on login
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        updateFCMToken();
      }
    });

    // Initial Token Fetch if already logged in
    updateFCMToken();
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    debugPrint(
      'FCM: Attempting to save token. User Logged In: ${user != null}',
    );

    if (user != null) {
      try {
        String deviceType = 'other';
        if (kIsWeb) {
          deviceType = 'web';
        } else if (defaultTargetPlatform == TargetPlatform.android) {
          deviceType = 'android';
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          deviceType = 'ios';
        }

        await Supabase.instance.client.from('fcm_tokens').upsert({
          'user_id': user.id,
          'token': token,
          'device_type': deviceType,
        });

        debugPrint('FCM: Token saved successfully to Supabase');
      } catch (e) {
        debugPrint('FCM: Error saving token to Supabase: $e');
      }
    } else {
      debugPrint('FCM: Token NOT saved because user is not authenticated.');
    }
  }

  void updateFCMToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToSupabase(token);
      }
    } catch (e) {
      debugPrint('FCM: Failed to update token: $e');
    }
  }
}

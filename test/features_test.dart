import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_dating_app/core/services/swipe_queue_service.dart';
import 'package:student_dating_app/features/chat/domain/chat_activity_model.dart';
import 'package:student_dating_app/features/explore/domain/campus_spot_models.dart';
import 'package:student_dating_app/features/intents/domain/incoming_signal_model.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/chat/domain/chat_models.dart';
import 'package:student_dating_app/features/chat/domain/chat_message_payload.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('In-Chat Activities Model Tests', () {
    test('Two Truths and a Lie encodes and decodes accurately', () {
      final activity = ChatActivity(
        type: ActivityType.twoTruthsAndLie,
        title: '🎯 Two Truths & a Lie',
        creatorId: 'user_123',
        options: [
          'Visited 5 countries',
          'Never tried sushi',
          'Play cello',
        ],
        correctIndex: 1,
        blurBoost: 0.25,
      );

      final encoded = activity.encode();
      expect(ChatActivity.isActivity(encoded), isTrue);

      final decoded = ChatActivity.decode(encoded);
      expect(decoded, isNotNull);
      expect(decoded!.type, ActivityType.twoTruthsAndLie);
      expect(decoded.title, '🎯 Two Truths & a Lie');
      expect(decoded.creatorId, 'user_123');
      expect(decoded.options.length, 3);
      expect(decoded.correctIndex, 1);
      expect(decoded.blurBoost, 0.25);
      expect(decoded.isCompleted, isFalse);
    });

    test('Would You Rather updates and marks completed', () {
      final activity = ChatActivity(
        type: ActivityType.wouldYouRather,
        title: 'Campus WYR',
        creatorId: 'user_1',
        options: ['8 AM lecture', '2 PM snooze'],
        responses: {'user_1': 'A'},
      );

      expect(activity.responses['user_1'], 'A');
      final updated = activity.copyWith(
        responses: {'user_1': 'A', 'user_2': 'B'},
        isCompleted: true,
      );
      expect(updated.responses.length, 2);
      expect(updated.isCompleted, isTrue);
    });
  });

  group('Offline Swipes Queue Tests', () {
    test('Enqueueing swipes increments pending count and preserves data', () async {
      await SwipeQueueService.clearQueue();
      expect(await SwipeQueueService.getPendingCount(), 0);

      await SwipeQueueService.enqueueSwipe(
        actorId: 'user_me',
        targetId: 'target_1',
        actionType: 'ROMANTIC',
      );
      await SwipeQueueService.enqueueSwipe(
        actorId: 'user_me',
        targetId: 'target_2',
        actionType: 'FRIENDSHIP',
      );

      final count = await SwipeQueueService.getPendingCount();
      expect(count, 2);
    });
  });

  group('Campus Explore Domain Tests', () {
    test('SpotCheckIn calculates expiration correctly', () {
      final now = DateTime.now();
      final activeCheckIn = SpotCheckIn(
        id: 'c1',
        spotId: 'spot_library',
        userId: 'u1',
        userName: 'Sam',
        userUniversity: 'Campus Uni',
        userMajor: 'Design',
        userIntent: 'romance',
        vibeStatus: 'Reading books',
        checkedInAt: now,
        expiresAt: now.add(const Duration(hours: 2)),
      );

      expect(activeCheckIn.isExpired, isFalse);

      final expiredCheckIn = SpotCheckIn(
        id: 'c2',
        spotId: 'spot_library',
        userId: 'u2',
        userName: 'Alex',
        userUniversity: 'Campus Uni',
        userMajor: 'Physics',
        userIntent: 'collaboration',
        vibeStatus: 'Lab work',
        checkedInAt: now.subtract(const Duration(hours: 3)),
        expiresAt: now.subtract(const Duration(hours: 1)),
      );

      expect(expiredCheckIn.isExpired, isTrue);
    });
  });

  group('Blind Intent Matching Tests', () {
    test('IncomingSignal matches only when Person B picks identical intent', () {
      final signal = IncomingSignal(
        interactionId: 'int_1',
        senderId: 'user_a',
        createdAt: DateTime.now(),
        profile: const ProfileCardModel(
          id: 'user_a',
          name: 'Jordan',
          age: 20,
          university: 'Uni',
          major: 'CS',
          primaryIntent: 'friendship',
        ),
        hiddenIntent: 'ROMANTIC',
      );

      // Person B chooses Romantic -> MATCH!
      expect(signal.matchesIntent('ROMANTIC'), isTrue);
      expect(signal.matchesIntent('romantic'), isTrue);

      // Person B chooses Friendship -> NO MATCH! (stays completely private)
      expect(signal.matchesIntent('FRIENDSHIP'), isFalse);

      // Person B chooses Collaborate -> NO MATCH!
      expect(signal.matchesIntent('COLLABORATE'), isFalse);

      // Person B chooses Pass -> NO MATCH!
      expect(signal.matchesIntent('PASS'), isFalse);
    });
  });

  group('Chat Message Previews and Payloads Tests', () {
    test('Activity payloads format cleanly without raw JSON', () {
      final activity = const ChatActivity(
        type: ActivityType.twoTruthsAndLie,
        title: 'Two Truths & a Lie',
        creatorId: 'u1',
      );
      final raw = activity.encode();
      final preview = ChatMessageFormatter.formatPreview(raw);
      expect(preview.contains('{"type"'), isFalse);
      expect(preview, contains('🎮 Sent a game'));
    });

    test('Chat replies encode and decode accurately', () {
      final reply = const ChatReplyMeta(
        replyToId: 'msg_99',
        replyToSenderName: 'Maya',
        replyToSnippet: 'Are you going to the library?',
        actualMessage: 'Yes, heading there now!',
      );

      final encoded = reply.encode();
      expect(ChatReplyMeta.isReply(encoded), isTrue);

      final decoded = ChatReplyMeta.decode(encoded);
      expect(decoded, isNotNull);
      expect(decoded!.replyToId, 'msg_99');
      expect(decoded.replyToSenderName, 'Maya');
      expect(decoded.replyToSnippet, 'Are you going to the library?');
      expect(decoded.actualMessage, 'Yes, heading there now!');

      final preview = ChatMessageFormatter.formatPreview(encoded);
      expect(preview, '↩️ Yes, heading there now!');
    });

    test('Chat snap marks viewed correctly', () {
      final snap = const ChatSnapMeta(
        imageUrl: 'https://example.com/photo.jpg',
        isViewOnce: true,
        viewedByUserIds: [],
        caption: 'Campus sunset',
      );

      final encoded = snap.encode();
      expect(ChatSnapMeta.isSnap(encoded), isTrue);

      final decoded = ChatSnapMeta.decode(encoded);
      expect(decoded, isNotNull);
      expect(decoded!.isViewOnce, isTrue);
      expect(decoded.caption, 'Campus sunset');

      final viewed = decoded.markViewed('user_viewer');
      expect(viewed.viewedByUserIds.contains('user_viewer'), isTrue);
    });

    test('StreakHelper calculates streaks and unlocks correctly', () {
      final now = DateTime.now();
      final messages = [
        ChatMessage(
          id: '1',
          senderId: 'a',
          content: 'Hi',
          createdAt: now,
        ),
        ChatMessage(
          id: '2',
          senderId: 'b',
          content: 'Hey',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        ChatMessage(
          id: '3',
          senderId: 'a',
          content: 'How are you?',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
      ];

      final streak = StreakHelper.calculateStreak(messages);
      expect(streak, 3);

      // 3 days is locked without dev bypass
      final locked = StreakHelper.isPhotoUnlocked(
        matchCreatedAt: now.subtract(const Duration(days: 3)),
        messages: messages,
        unblurProgress: 0.3,
        devBypass: false,
      );
      expect(locked, isFalse);

      // Dev bypass immediately unlocks
      final devUnlocked = StreakHelper.isPhotoUnlocked(
        matchCreatedAt: now.subtract(const Duration(days: 3)),
        messages: messages,
        unblurProgress: 0.3,
        devBypass: true,
      );
      expect(devUnlocked, isTrue);

      // 14+ days of friendship unlocks
      final durationUnlocked = StreakHelper.isPhotoUnlocked(
        matchCreatedAt: now.subtract(const Duration(days: 15)),
        messages: messages,
        unblurProgress: 0.3,
        devBypass: false,
      );
      expect(durationUnlocked, isTrue);
    });
  });
}


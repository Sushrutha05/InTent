import 'dart:convert';
import 'package:student_dating_app/features/chat/domain/chat_activity_model.dart';
import 'package:student_dating_app/features/chat/domain/chat_models.dart';

/// Metadata for messages that reply to a previous message.
class ChatReplyMeta {
  final String replyToId;
  final String replyToSenderName;
  final String replyToSnippet;
  final String actualMessage;

  const ChatReplyMeta({
    required this.replyToId,
    required this.replyToSenderName,
    required this.replyToSnippet,
    required this.actualMessage,
  });

  Map<String, dynamic> toMap() => {
        'replyToId': replyToId,
        'replyToSender': replyToSenderName,
        'replyToSnippet': replyToSnippet,
      };

  String encode() {
    return '[REPLY]:${jsonEncode(toMap())}\n$actualMessage';
  }

  static bool isReply(String content) => content.startsWith('[REPLY]:');

  static ChatReplyMeta? decode(String content) {
    if (!isReply(content)) return null;
    try {
      final newlineIdx = content.indexOf('\n');
      final jsonPart = newlineIdx == -1
          ? content.substring('[REPLY]:'.length)
          : content.substring('[REPLY]:'.length, newlineIdx);
      final actualMessage =
          newlineIdx == -1 ? '' : content.substring(newlineIdx + 1);

      final map = jsonDecode(jsonPart) as Map<String, dynamic>;
      return ChatReplyMeta(
        replyToId: map['replyToId'] as String? ?? '',
        replyToSenderName: map['replyToSender'] as String? ?? 'Someone',
        replyToSnippet: map['replyToSnippet'] as String? ?? '',
        actualMessage: actualMessage,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Metadata for Snapchat-like photos & expiring view-once snaps.
class ChatSnapMeta {
  final String imageUrl;
  final bool isViewOnce;
  final List<String> viewedByUserIds;
  final String? caption;

  const ChatSnapMeta({
    required this.imageUrl,
    this.isViewOnce = false,
    this.viewedByUserIds = const [],
    this.caption,
  });

  Map<String, dynamic> toMap() => {
        'imageUrl': imageUrl,
        'isViewOnce': isViewOnce,
        'viewedByUserIds': viewedByUserIds,
        'caption': caption,
      };

  factory ChatSnapMeta.fromMap(Map<String, dynamic> map) {
    return ChatSnapMeta(
      imageUrl: map['imageUrl'] as String? ?? '',
      isViewOnce: map['isViewOnce'] as bool? ?? false,
      viewedByUserIds: (map['viewedByUserIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      caption: map['caption'] as String?,
    );
  }

  String encode() => '[SNAP]:${jsonEncode(toMap())}';

  static bool isSnap(String content) => content.startsWith('[SNAP]:');

  static ChatSnapMeta? decode(String content) {
    if (!isSnap(content)) return null;
    try {
      final jsonStr = content.substring('[SNAP]:'.length);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ChatSnapMeta.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  ChatSnapMeta markViewed(String userId) {
    if (viewedByUserIds.contains(userId)) return this;
    return ChatSnapMeta(
      imageUrl: imageUrl,
      isViewOnce: isViewOnce,
      viewedByUserIds: [...viewedByUserIds, userId],
      caption: caption,
    );
  }
}

/// Helper for clean message preview formatting and snippet display.
class ChatMessageFormatter {
  static String formatPreview(
    String content, {
    String? senderId,
    String? currentUserId,
  }) {
    String preview = '';

    if (ChatActivity.isActivity(content)) {
      final activity = ChatActivity.decode(content);
      if (activity == null) {
        preview = '🎮 Sent a game';
      } else {
        switch (activity.type) {
          case ActivityType.twoTruthsAndLie:
            preview = '🎮 Sent a game: Two Truths & a Lie';
            break;
          case ActivityType.wouldYouRather:
            preview = '🎮 Sent a game: Would You Rather';
            break;
          case ActivityType.icebreaker:
            preview = '🎮 Sent an icebreaker: ${activity.title}';
            break;
        }
      }
    } else if (ChatSnapMeta.isSnap(content)) {
      final snap = ChatSnapMeta.decode(content);
      if (snap?.isViewOnce == true) {
        final isViewedByMe =
            currentUserId != null && snap!.viewedByUserIds.contains(currentUserId);
        preview = isViewedByMe ? '🔥 Opened snap' : '🔥 Sent a snap';
      } else {
        preview = '📷 Sent a photo';
      }
    } else if (ChatReplyMeta.isReply(content)) {
      final reply = ChatReplyMeta.decode(content);
      preview = '↩️ ${reply?.actualMessage ?? content}';
    } else {
      preview = content;
    }

    if (senderId != null && currentUserId != null && senderId == currentUserId) {
      return 'You: $preview';
    }
    return preview;
  }
}

/// Helper calculating friendship duration, chat streaks, and unlock criteria.
class StreakHelper {
  /// Days since the match was created
  static int getFriendshipDays(DateTime? matchCreatedAt) {
    if (matchCreatedAt == null) return 0;
    final diff = DateTime.now().difference(matchCreatedAt).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Calculates consecutive days streak from exchanged messages
  static int calculateStreak(List<ChatMessage> messages) {
    if (messages.isEmpty) return 0;

    // Extract unique calendar day strings (YYYY-MM-DD)
    final daysSet = <String>{};
    for (final m in messages) {
      final d = m.createdAt.toLocal();
      daysSet.add('${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }

    final sortedDays = daysSet.toList()..sort((a, b) => b.compareTo(a));
    if (sortedDays.isEmpty) return 0;

    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final yesterdayDate = now.subtract(const Duration(days: 1));
    final yesterday = '${yesterdayDate.year}-${yesterdayDate.month.toString().padLeft(2, '0')}-${yesterdayDate.day.toString().padLeft(2, '0')}';

    // Must have at least a message today or yesterday for the streak to be active
    if (!sortedDays.contains(today) && !sortedDays.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = sortedDays.contains(today) ? now : yesterdayDate;

    for (int i = 0; i < 365; i++) {
      final dayKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if (sortedDays.contains(dayKey)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Checks if photo & snap sharing is unlocked:
  /// - Friendship duration >= 14 days OR
  /// - Chat streak >= 7 days OR
  /// - Unblur progress reached 1.0 OR
  /// - Dev bypass enabled
  static bool isPhotoUnlocked({
    required DateTime? matchCreatedAt,
    required List<ChatMessage> messages,
    double unblurProgress = 0.0,
    bool devBypass = false,
  }) {
    if (devBypass) return true;
    if (unblurProgress >= 1.0) return true;
    if (getFriendshipDays(matchCreatedAt) >= 14) return true;
    if (calculateStreak(messages) >= 7) return true;
    return false;
  }
}

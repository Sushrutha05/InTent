import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/features/chat/domain/chat_models.dart';
import 'package:student_dating_app/features/chat/domain/chat_activity_model.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:flutter/foundation.dart';

class ChatRepository {
  final SupabaseClient _client;

  ChatRepository(this._client);

  final Map<String, ProfileCardModel> _profileCache = {};

  // Gets a list of active matches for the current user
  Stream<List<ChatChannel>> watchChatChannels(String currentUserId) {
    return _client
        .from('matches')
        .stream(primaryKey: ['id'])
        .map(
          (matches) =>
              matches
                  .where(
                    (m) =>
                        m['user1_id'] == currentUserId ||
                        m['user2_id'] == currentUserId,
                  )
                  .toList(),
        )
        .asyncMap((data) async {
          if (data.isEmpty) return <ChatChannel>[];

          // Collect other user IDs and match IDs for batch fetching
          final List<String> matchIds = [];
          final Set<String> neededProfileIds = {};

          for (final match in data) {
            final matchId = match['id'] as String;
            matchIds.add(matchId);

            final otherUserId =
                match['user1_id'] == currentUserId
                    ? match['user2_id'] as String
                    : match['user1_id'] as String;

            if (!_profileCache.containsKey(otherUserId)) {
              neededProfileIds.add(otherUserId);
            }
          }

          // 1. Batch fetch uncached profiles in ONE query
          if (neededProfileIds.isNotEmpty) {
            try {
              final profilesResponse = await _client
                  .from('profiles')
                  .select()
                  .inFilter('id', neededProfileIds.toList());

              for (final profileData in profilesResponse) {
                final id = profileData['id'] as String;
                final interestsRaw =
                    profileData['interests'] as List<dynamic>? ?? [];
                final photosRaw =
                    profileData['photo_urls'] as List<dynamic>? ?? [];

                _profileCache[id] = ProfileCardModel(
                  id: id,
                  name: profileData['first_name'] as String? ?? 'Unknown',
                  age: _calculateAge(profileData['date_of_birth'] as String?),
                  university: profileData['university'] as String? ?? '',
                  major: profileData['major'] as String? ?? '',
                  primaryIntent:
                      profileData['primary_intent'] as String? ?? 'friendship',
                  interests: interestsRaw.map((e) => e.toString()).toList(),
                  photoUrls: photosRaw.map((e) => e.toString()).toList(),
                  currentBlurLevel: 0.0,
                );
              }
            } catch (e) {
              debugPrint('Error batch fetching profiles: $e');
            }
          }

          // 2. Batch fetch last messages in parallel
          final Map<String, ChatMessage> lastMessages = {};
          try {
            final messagesResponse = await _client
                .from('messages')
                .select()
                .inFilter('match_id', matchIds)
                .order('created_at', ascending: false);

            for (final msg in messagesResponse) {
              final mId = msg['match_id'] as String;
              if (!lastMessages.containsKey(mId)) {
                lastMessages[mId] = ChatMessage(
                  id: msg['id'],
                  senderId: msg['sender_id'],
                  content: msg['content'],
                  createdAt: DateTime.parse(msg['created_at']),
                  isRead: msg['is_read'],
                );
              }
            }
          } catch (e) {
            debugPrint('Error batch fetching last messages: $e');
          }

          List<ChatChannel> channels = [];
          for (final match in data) {
            final matchId = match['id'] as String;
            final otherUserId =
                match['user1_id'] == currentUserId
                    ? match['user2_id'] as String
                    : match['user1_id'] as String;

            final unblurProgress =
                (match['unblur_progress'] as num? ?? 0.0).toDouble();
            final cachedProfile =
                _profileCache[otherUserId] ??
                ProfileCardModel(
                  id: otherUserId,
                  name: 'Unknown',
                  age: 20,
                  university: '',
                  major: '',
                  primaryIntent: 'friendship',
                );

            final matchedProfile = cachedProfile.copyWith(
              currentBlurLevel: 1.0 - unblurProgress,
            );

            final lastMsg = lastMessages[matchId];
            channels.add(
              ChatChannel(
                id: matchId,
                matchedUser: matchedProfile,
                messages: lastMsg != null ? [lastMsg] : [],
                lastActivityAt: DateTime.parse(
                  match['last_message_at'] ?? match['created_at'],
                ),
                unblurProgress: unblurProgress,
              ),
            );
          }

          // Sort channels by most recent activity
          channels.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
          return channels;
        });
  }

  // Watch individual messages within a specific match
  Stream<List<ChatMessage>> watchMessages(String matchId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('created_at', ascending: true) // Oldest to newest for chat UI
        .map((data) {
          return data
              .map(
                (msg) => ChatMessage(
                  id: msg['id'],
                  senderId: msg['sender_id'],
                  content: msg['content'],
                  createdAt: DateTime.parse(msg['created_at']),
                  isRead: msg['is_read'],
                ),
              )
              .toList();
        });
  }

  // Watch metadata for a single match (e.g. unblur_progress)
  Stream<Map<String, dynamic>> watchMatch(String matchId) {
    return _client
        .from('matches')
        .stream(primaryKey: ['id'])
        .eq('id', matchId)
        .map((data) => data.isNotEmpty ? data.first : {});
  }

  // Send a message and update the unblur progress based on stages
  Future<void> sendMessage(
    String matchId,
    String senderId,
    String content,
  ) async {
    try {
      // 1. Insert the message
      await _client.from('messages').insert({
        'match_id': matchId,
        'sender_id': senderId,
        'content': content,
      });

      // 2. Calculate new unblur progress based on interaction stages (limit to 12 for speed)
      final allMessages = await _client
          .from('messages')
          .select('sender_id')
          .eq('match_id', matchId)
          .limit(12);

      final totalCount = allMessages.length;
      final uniqueSenders =
          allMessages.map((m) => m['sender_id'] as String).toSet();

      double newProgress = 0.0; // Stage 1 (Match)

      // Stage 2: Reciprocal (Both sent 1+ msg)
      if (uniqueSenders.length >= 2) {
        newProgress = 0.5;
      }

      // Stage 3: Ongoing (10+ total messages)
      if (totalCount >= 10) {
        newProgress = 1.0;
      }

      await _client
          .from('matches')
          .update({'unblur_progress': newProgress})
          .eq('id', matchId);
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // Mark all unread messages in a specific match as read
  Future<void> markMessagesAsRead(String matchId, String currentUserId) async {
    try {
      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('match_id', matchId)
          .neq('sender_id', currentUserId)
          .eq('is_read', false);
      debugPrint('Marked messages as read for match $matchId');
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Send an in-chat activity or mini-game
  Future<void> sendActivity(
    String matchId,
    String senderId,
    ChatActivity activity,
  ) async {
    await sendMessage(matchId, senderId, activity.encode());
  }

  // Update an existing activity when answered/guessed and grant accelerated unblur boost
  Future<void> updateActivityResponse(
    String matchId,
    String messageId,
    ChatActivity updatedActivity, {
    double boost = 0.25,
  }) async {
    try {
      await _client
          .from('messages')
          .update({'content': updatedActivity.encode()})
          .eq('id', messageId);

      if (updatedActivity.isCompleted) {
        await boostUnblurProgress(matchId, boost);
      }
    } catch (e) {
      debugPrint('Error updating activity response: $e');
      rethrow;
    }
  }

  // Accelerated blur drop boost (e.g. +0.25 on minigame completion)
  Future<void> boostUnblurProgress(String matchId, double additionalProgress) async {
    try {
      final matchData = await _client
          .from('matches')
          .select('unblur_progress')
          .eq('id', matchId)
          .single();

      final current = (matchData['unblur_progress'] as num? ?? 0.0).toDouble();
      final updated = (current + additionalProgress).clamp(0.0, 1.0);

      await _client
          .from('matches')
          .update({'unblur_progress': updated})
          .eq('id', matchId);
      debugPrint('Boosted match $matchId unblur_progress: $current -> $updated');
    } catch (e) {
      debugPrint('Error boosting unblur progress: $e');
    }
  }
  int _calculateAge(String? dobString) {
    if (dobString == null) return 18;
    try {
      final dob = DateTime.parse(dobString);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 18;
    }
  }
}


import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/features/chat/domain/chat_models.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:flutter/foundation.dart';

class ChatRepository {
  final SupabaseClient _client;

  ChatRepository(this._client);

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
          List<ChatChannel> channels = [];

          for (var match in data) {
            // Determine the ID of the *other* user in the match
            final otherUserId =
                match['user1_id'] == currentUserId
                    ? match['user2_id']
                    : match['user1_id'];

            // Fetch the profile for the other user
            final profileResponse =
                await _client
                    .from('profiles')
                    .select()
                    .eq('id', otherUserId)
                    .single();

            // Handle arrays safely
            final interestsRaw =
                profileResponse['interests'] as List<dynamic>? ?? [];
            final photosRaw =
                profileResponse['photo_urls'] as List<dynamic>? ?? [];

            final matchedProfile = ProfileCardModel(
              id: profileResponse['id'] as String,
              name: profileResponse['first_name'] as String? ?? 'Unknown',
              age: 20, // Should be calculated from DOB in a real app function
              university: profileResponse['university'] as String? ?? '',
              major: profileResponse['major'] as String? ?? '',
              primaryIntent:
                  profileResponse['primary_intent'] as String? ?? 'friendship',
              interests: interestsRaw.map((e) => e.toString()).toList(),
              photoUrls: photosRaw.map((e) => e.toString()).toList(),
              currentBlurLevel:
                  1.0 -
                  (match['unblur_progress'] as num? ??
                      0.0), // Inverse logic for UI
            );

            // Fetch the last message for the channel preview
            final messageResponse = await _client
                .from('messages')
                .select()
                .eq('match_id', match['id'])
                .order('created_at', ascending: false)
                .limit(1);

            List<ChatMessage> messages = [];
            if (messageResponse.isNotEmpty) {
              final msg = messageResponse[0];
              messages.add(
                ChatMessage(
                  id: msg['id'],
                  senderId: msg['sender_id'],
                  content: msg['content'],
                  createdAt: DateTime.parse(msg['created_at']),
                  isRead: msg['is_read'],
                ),
              );
            }

            channels.add(
              ChatChannel(
                id: match['id'] as String,
                matchedUser: matchedProfile,
                messages: messages,
                lastActivityAt:
                    messages.isNotEmpty
                        ? messages.first.createdAt
                        : DateTime.parse(match['created_at']),
                unblurProgress:
                    (match['unblur_progress'] as num? ?? 0.0).toDouble(),
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

      // 2. Calculate new unblur progress based on interaction stages
      final allMessages = await _client
          .from('messages')
          .select('sender_id')
          .eq('match_id', matchId);

      final totalCount = allMessages.length;
      final uniqueSenders =
          allMessages.map((m) => m['sender_id'] as String).toSet();

      double newProgress = 0.0; // Stage 1 (Match)

      // Stage 2: Reciprocal (Both sent 1+ msg)
      if (uniqueSenders.length >= 2) {
        newProgress = 0.5;
      }

      // Stage 3: Ongoing (6+ total messages)
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
}

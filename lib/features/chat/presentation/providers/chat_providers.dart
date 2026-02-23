import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/features/chat/data/chat_repository.dart';
import 'package:student_dating_app/features/chat/domain/chat_models.dart';

// Provides the singleton instance of the repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(Supabase.instance.client);
});

// Provides a realtime stream of ChatChannels (Matches) for a user ID
final chatChannelsStreamProvider =
    StreamProvider.family<List<ChatChannel>, String>((ref, userId) {
      final repo = ref.watch(chatRepositoryProvider);
      return repo.watchChatChannels(userId);
    });

// Provides a realtime stream of messages for a specific match ID
final messagesStreamProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, matchId) {
    final repo = ref.watch(chatRepositoryProvider);
    return repo.watchMessages(matchId);
  },
);

// Provides a realtime stream for a single match observation
final matchStreamProvider = StreamProvider.family<Map<String, dynamic>, String>(
  (ref, matchId) {
    final repo = ref.watch(chatRepositoryProvider);
    return repo.watchMatch(matchId);
  },
);

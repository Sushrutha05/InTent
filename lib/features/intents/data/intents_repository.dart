import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/features/intents/domain/intent_model.dart';
import 'package:student_dating_app/features/intents/domain/incoming_signal_model.dart';
import 'package:student_dating_app/core/services/swipe_queue_service.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';

final intentsRepositoryProvider = Provider<IntentsRepository>((ref) {
  return IntentsRepository(Supabase.instance.client);
});

class IntentsRepository {
  final SupabaseClient _client;

  IntentsRepository(this._client);

  Future<List<IntentModel>> getSentIntents() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Query matches where current user is involved.
      final response = await _client
          .from('matches')
          .select('''
            id,
            user1_id,
            user2_id,
            intent_type,
            created_at,
            user1_profile:profiles!user1_id(
              id, first_name, university, major, date_of_birth, primary_intent, bio, interests, photo_urls, vibe_prompt, vibe_answer
            ),
            user2_profile:profiles!user2_id(
              id, first_name, university, major, date_of_birth, primary_intent, bio, interests, photo_urls, vibe_prompt, vibe_answer
            )
          ''')
          .or('user1_id.eq.${user.id},user2_id.eq.${user.id}')
          .order('created_at', ascending: false);

      final intentsData = response as List<dynamic>;

      return intentsData.map((data) {
        final isUser1 = data['user1_id'] == user.id;
        final profileData =
            isUser1 ? data['user2_profile'] : data['user1_profile'];

        final interestsRaw = profileData['interests'] as List<dynamic>? ?? [];
        final photosRaw = profileData['photo_urls'] as List<dynamic>? ?? [];

        final targetProfile = ProfileCardModel(
          id: profileData['id'] as String,
          name: profileData['first_name'] as String? ?? 'Unknown',
          age: _calculateAge(profileData['date_of_birth'] as String?),
          university: profileData['university'] as String? ?? '',
          major: profileData['major'] as String? ?? '',
          primaryIntent:
              profileData['primary_intent'] as String? ?? 'friendship',
          bio: profileData['bio'] as String? ?? '',
          vibePrompt: profileData['vibe_prompt'] as String? ?? '',
          vibeAnswer: profileData['vibe_answer'] as String? ?? '',
          interests: interestsRaw.map((e) => e.toString()).toList(),
          photoUrls: photosRaw.map((e) => e.toString()).toList(),
          currentBlurLevel: AppTheme.getRevealBlurLevel(
              0.5), // Stage 1: Consistent 20% softness for matches
        );

        return IntentModel(
          id: data['id'] as String,
          actorId: user.id,
          targetId: targetProfile.id,
          actionType: data['intent_type'] as String? ?? 'FRIENDSHIP',
          createdAt: DateTime.parse(data['created_at'] as String),
          targetProfile: targetProfile,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching intents: $e');
      rethrow;
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

  /// Fetch incoming signals (swipes sent to current user) where intent is kept hidden
  Future<List<IncomingSignal>> getIncomingSignals() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('interactions')
          .select('''
            id,
            actor_id,
            action_type,
            created_at,
            actor_profile:profiles!actor_id(
              id, first_name, university, major, date_of_birth, primary_intent, bio, interests, photo_urls, vibe_prompt, vibe_answer
            )
          ''')
          .eq('target_id', user.id)
          .neq('action_type', 'PASS')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;

      // Query already swiped IDs by current user
      final mySwipes = await _client
          .from('interactions')
          .select('target_id')
          .eq('actor_id', user.id);
      final swipedTargetIds = (mySwipes as List<dynamic>)
          .map((item) => item['target_id'] as String)
          .toSet();

      // Query already matched IDs
      final myMatches = await _client
          .from('matches')
          .select('user1_id, user2_id')
          .or('user1_id.eq.${user.id},user2_id.eq.${user.id}');
      final matchedUserIds = (myMatches as List<dynamic>).map((m) {
        return m['user1_id'] == user.id ? m['user2_id'] as String : m['user1_id'] as String;
      }).toSet();

      List<IncomingSignal> signals = [];
      for (final row in data) {
        final actorId = row['actor_id'] as String;
        if (swipedTargetIds.contains(actorId) || matchedUserIds.contains(actorId)) {
          continue;
        }

        final profileData = row['actor_profile'];
        if (profileData == null) continue;

        final interestsRaw = profileData['interests'] as List<dynamic>? ?? [];
        final photosRaw = profileData['photo_urls'] as List<dynamic>? ?? [];

        final profile = ProfileCardModel(
          id: profileData['id'] as String,
          name: profileData['first_name'] as String? ?? 'Campus Peer',
          age: _calculateAge(profileData['date_of_birth'] as String?),
          university: profileData['university'] as String? ?? '',
          major: profileData['major'] as String? ?? '',
          primaryIntent: profileData['primary_intent'] as String? ?? 'friendship',
          bio: profileData['bio'] as String? ?? '',
          vibePrompt: profileData['vibe_prompt'] as String? ?? '',
          vibeAnswer: profileData['vibe_answer'] as String? ?? '',
          interests: interestsRaw.map((e) => e.toString()).toList(),
          photoUrls: photosRaw.map((e) => e.toString()).toList(),
          currentBlurLevel: AppTheme.getRevealBlurLevel(0.0),
        );

        signals.add(
          IncomingSignal(
            interactionId: row['id'] as String,
            senderId: actorId,
            createdAt: DateTime.parse(row['created_at'] as String),
            profile: profile,
            hiddenIntent: row['action_type'] as String,
          ),
        );
      }

      return signals;
    } catch (e) {
      debugPrint('Error getting incoming signals: $e');
      return [];
    }
  }

  /// Respond to a signal with current user's intent. Only matches if intents are identical!
  Future<bool> respondToSignal({
    required IncomingSignal signal,
    required String myIntent, // 'ROMANTIC', 'FRIENDSHIP', 'COLLABORATE', 'PASS'
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    // 1. Record interaction in local queue + Supabase
    await SwipeQueueService.enqueueSwipe(
      actorId: user.id,
      targetId: signal.senderId,
      actionType: myIntent,
    );
    SwipeQueueService.processQueue().then((_) {}).catchError((_) {});

    // 2. Check if blind intents matched!
    final bool isMatch = myIntent != 'PASS' && signal.matchesIntent(myIntent);

    if (isMatch) {
      try {
        await _client.from('matches').insert({
          'user1_id': user.id,
          'user2_id': signal.senderId,
          'intent_type': myIntent,
          'unblur_progress': 0.0,
        });
      } catch (e) {
        debugPrint('Note on match insert: $e');
      }
    }

    return isMatch;
  }
}

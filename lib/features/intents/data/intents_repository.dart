import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/features/intents/domain/intent_model.dart';
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
          currentBlurLevel: 0.15, // Matched, so 15% softness default
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
}

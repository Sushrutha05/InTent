import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';

part 'discovery_provider.g.dart';

@riverpod
class DiscoveryNotifier extends _$DiscoveryNotifier {
  @override
  Future<List<ProfileCardModel>> build() async {
    // We listen to the auth state. If it changes, this provider rebuilds.
    ref.watch(authProvider);

    return _loadProfilesFromSupabase();
  }

  Future<List<ProfileCardModel>> _loadProfilesFromSupabase() async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      debugPrint('Warning: No authenticated user found for discovery feed.');
      return [];
    }

    try {
      // 1. Fetch IDs of users the current user has already interacted with
      final interactionsResponse = await supabase
          .from('interactions')
          .select('target_id')
          .eq('actor_id', currentUser.id);

      final List<dynamic> interactedIdsData = interactionsResponse;
      final List<String> interactedIds =
          interactedIdsData.map((e) => e['target_id'] as String).toList();

      // 2. Fetch users that are NOT the current user AND not already interacted with
      var query = supabase.from('profiles').select().neq('id', currentUser.id);

      if (interactedIds.isNotEmpty) {
        query = query.not('id', 'in', interactedIds);
      }

      final response = await query.limit(20);

      // 2. Map JSON response to ProfileCardModel
      final profiles =
          (response as List<dynamic>).map((data) {
            // Handle potentially null arrays from DB gracefully
            final interestsRaw = data['interests'] as List<dynamic>? ?? [];
            final photosRaw = data['photo_urls'] as List<dynamic>? ?? [];

            return ProfileCardModel(
              id: data['id'] as String,
              name: data['first_name'] as String? ?? 'Unknown',
              age: _calculateAge(data['date_of_birth'] as String?),
              university: data['university'] as String? ?? '',
              major: data['major'] as String? ?? '',
              primaryIntent: data['primary_intent'] as String? ?? 'friendship',
              bio: data['bio'] as String? ?? '',
              vibePrompt: data['vibe_prompt'] as String? ?? '',
              vibeAnswer: data['vibe_answer'] as String? ?? '',
              interests: interestsRaw.map((e) => e.toString()).toList(),
              photoUrls: photosRaw.map((e) => e.toString()).toList(),
              currentBlurLevel: 0.9, // Everyone starts heavily blurred!
            );
          }).toList();

      return profiles;
    } catch (e) {
      debugPrint('Error fetching profiles from Supabase: $e');
      // For demonstration robustness, if DB fails/is empty, return nothing rather than crashing
      return [];
    }
  }

  int _calculateAge(String? dobString) {
    if (dobString == null) return 18; // Default fallback
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

  Future<void> handleRomantic(ProfileCardModel profile) async {
    await _recordInteraction(profile.id, 'ROMANTIC');
  }

  Future<void> handlePass(ProfileCardModel profile) async {
    await _recordInteraction(profile.id, 'PASS');
  }

  Future<void> handleFriendship(ProfileCardModel profile) async {
    await _recordInteraction(profile.id, 'FRIENDSHIP');
  }

  Future<void> handleCollaborate(ProfileCardModel profile) async {
    await _recordInteraction(profile.id, 'COLLABORATE');
  }

  Future<void> _recordInteraction(String targetId, String actionType) async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await supabase.from('interactions').insert({
        'actor_id': currentUser.id,
        'target_id': targetId,
        'action_type': actionType,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Recorded $actionType for $targetId in Supabase');

      // Remove the swiped profile from the local state so it disappears from the feed
      if (state.hasValue && state.value != null) {
        final currentProfiles = state.value!;
        final updatedProfiles =
            currentProfiles.where((p) => p.id != targetId).toList();
        state = AsyncValue.data(updatedProfiles);
      }
    } catch (e) {
      debugPrint('Error recording $actionType: $e');
    }
  }

  // Used if we want to manually refresh the feed
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadProfilesFromSupabase());
  }
}

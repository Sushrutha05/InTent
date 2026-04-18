import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/discovery/domain/services/discovery_weighting_service.dart';
import 'package:student_dating_app/features/discovery/domain/services/exposure_balancer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';

part 'discovery_provider.g.dart';

enum InstitutionFilter { myInstitution, all }

final discoveryFilterProvider = StateProvider<InstitutionFilter>((ref) => InstitutionFilter.myInstitution);

@riverpod
class DiscoveryNotifier extends _$DiscoveryNotifier {
  @override
  Future<List<ProfileCardModel>> build() async {
    // We listen to the auth state. If it changes, this provider rebuilds.
    ref.watch(authProvider);
    final filter = ref.watch(discoveryFilterProvider);

    return _loadProfilesFromSupabase(filter);
  }

  Future<List<ProfileCardModel>> _loadProfilesFromSupabase(InstitutionFilter filter) async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      debugPrint('Warning: No authenticated user found for discovery feed.');
      return [];
    }

    // FIX: Update last_active on every discovery load so the recency score
    // (+10 in Edge Function) and DB ordering (ORDER BY last_active DESC)
    // stay accurate for browsing users. Fire-and-forget — never block the feed.
    supabase.rpc('update_last_active').then((_) {}).catchError((_) {});

    try {
      // 1. Invoke the Edge Function 'recommend-users'
      // Handles all DB querying, candidate selection, exclusion (interactions/blocks),
      // scoring, ranking, and exploration mix on the server.
      final response = await supabase.functions.invoke(
        'recommend-users',
        body: {
          'user_id': currentUser.id,
          'same_college_only': filter == InstitutionFilter.myInstitution,
        },
      );

      final List<dynamic> data = (response.data as List<dynamic>?) ?? [];

      // 2. Map JSON response to ProfileCardModel
      final profiles = data.map((userData) {
        final interestsRaw = userData['interests'] as List<dynamic>? ?? [];
        final photosRaw = userData['photo_urls'] as List<dynamic>? ?? [];

        return ProfileCardModel(
          id: userData['id'] as String,
          name: userData['first_name'] as String? ?? 'Unknown',
          age: _calculateAge(userData['date_of_birth'] as String?),
          // Favor DB's true college_name, fallback to direct text university
          university: (userData['college_name'] ?? userData['university'] ?? '') as String,
          major: userData['major'] as String? ?? '',
          primaryIntent: userData['primary_intent'] as String? ?? 'friendship',
          bio: userData['bio'] as String? ?? '',
          vibePrompt: userData['vibe_prompt'] as String? ?? '',
          vibeAnswer: userData['vibe_answer'] as String? ?? '',
          interests: interestsRaw.map((e) => e.toString()).toList(),
          photoUrls: photosRaw.map((e) => e.toString()).toList(),
          currentBlurLevel: AppTheme.getRevealBlurLevel(0.0),
          // FIX: Populate globalIntentPreference from server so the local
          // weighting service can correctly boost intent-matched profiles.
          globalIntentPreference: userData['primary_intent'] as String? ?? 'friendship',
        );
      }).toList();

      // FIX: Apply local re-ranking using DiscoveryWeightingService.
      // This secondary pass boosts profiles whose intent matches the user's
      // own intent and boosts low-exposure profiles so they get a fair chance
      // of being seen. It adds a small random noise to keep the feed organic.
      final weightingService = ref.read(discoveryWeightingServiceProvider.notifier);
      final myIntent = await _fetchMyIntent(supabase, currentUser.id);
      final sortedProfiles = weightingService.sortProfiles(profiles, myIntent);

      // FIX: Record exposure for all returned profiles (fire-and-forget).
      // This feeds the exposure_count column so that low-exposure users get
      // boosted in future sessions via the DiscoveryWeightingService.
      ref.read(exposureBalancerProvider.notifier).recordExposure(sortedProfiles);

      return sortedProfiles;
    } on FunctionException catch (e) {
      debugPrint('\n=== EDGE FUNCTION ERROR ===');
      debugPrint('Status Code: ${e.status}');
      debugPrint('Response: ${e.details}');
      debugPrint('Reason: ${e.reasonPhrase}');
      debugPrint('===========================\n');
      return [];
    } catch (e, stacktrace) {
      debugPrint('\n=== DISCOVERY FEED ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stacktrace: $stacktrace');
      debugPrint('============================\n');
      return [];
    }
  }

  /// Fetches the current user's primary_intent from the DB.
  /// Used by the local weighting service to boost intent-matched candidates.
  Future<String> _fetchMyIntent(SupabaseClient supabase, String userId) async {
    try {
      final result = await supabase
          .from('profiles')
          .select('primary_intent')
          .eq('id', userId)
          .single();
      return result['primary_intent'] as String? ?? 'friendship';
    } catch (_) {
      return 'friendship'; // Safe fallback
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

      // Record the interaction in DB. We don't remove it from local state immediately
      // to avoid 'skipping' cards in the Swiper. The DB will filter these out on next fetch.
    } catch (e) {
      debugPrint('Error recording $actionType: $e');
    }
  }

  Future<void> blockUser(String targetId, {String? reason}) async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await supabase.from('blocks').insert({
        'blocker_id': currentUser.id,
        'blocked_id': targetId,
        'reason': reason,
      });

      debugPrint('Blocked user $targetId');

      // Record the block in DB. We don't remove it from local state immediately
      // to avoid 'skipping' cards in the Swiper.
    } catch (e) {
      debugPrint('Error blocking user: $e');
      rethrow;
    }
  }

  // Used if we want to manually refresh the feed
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final filter = ref.read(discoveryFilterProvider);
    state = await AsyncValue.guard(() => _loadProfilesFromSupabase(filter));
  }
}

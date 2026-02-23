import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/core/constants/behavior_constants.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'dart:math';

part 'discovery_weighting_service.g.dart';

@riverpod
class DiscoveryWeightingService extends _$DiscoveryWeightingService {
  @override
  void build() {}

  /// Sorts profiles using weighted randomness instead of hard filtering
  /// based on global intent and exposure count.
  List<ProfileCardModel> sortProfiles(
    List<ProfileCardModel> profiles,
    String myGlobalIntent,
  ) {
    if (profiles.isEmpty) return profiles;

    // Create a scoring map
    final Map<String, double> scores = {};
    final rng = Random();

    for (var profile in profiles) {
      double score = 1.0; // Base score

      // 1. Target Intent Weighting (Hidden Signal)
      if (profile.globalIntentPreference.toLowerCase() ==
          myGlobalIntent.toLowerCase()) {
        score *= BehaviorConstants.targetIntentWeightFactor;
      }

      // 2. Exposure Balancing (Boost low exposure cards so they get seen)
      if (profile.exposureCount < 50) {
        score *= BehaviorConstants.lowExposureBoostFactor;
      } else if (profile.exposureCount > 500) {
        // Slightly deprecate highly exposed users
        score *= 0.8;
      }

      // 3. Random noise to prevent exact determinism (makes feed feel organic)
      score *= (0.8 + rng.nextDouble() * 0.4);

      scores[profile.id] = score;
    }

    // Sort descending by score
    final sortedProfiles = List<ProfileCardModel>.from(profiles);
    sortedProfiles.sort(
      (a, b) => (scores[b.id] ?? 0).compareTo(scores[a.id] ?? 0),
    );

    return sortedProfiles;
  }
}

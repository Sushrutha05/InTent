import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'exposure_balancer.g.dart';

@riverpod
class ExposureBalancer extends _$ExposureBalancer {
  @override
  void build() {}

  /// Records that these profiles have been shown to a user
  Future<void> recordExposure(List<ProfileCardModel> profiles) async {
    if (profiles.isEmpty) return;

    final supabase = Supabase.instance.client;

    // In a real app, we would batch update the exposure_count and last_shown_timestamp
    // For this demonstration, we map out the IDs
    final profileIds = profiles.map((p) => p.id).toList();

    try {
      // Note: Supabase RPC is usually better for batch updates, but we'll use a loop or logic here
      for (final id in profileIds) {
        // Increment exposure count - optimistic background task
        supabase
            .rpc('increment_exposure', params: {'profile_id': id})
            .onError((error, stackTrace) => null);
      }
    } catch (_) {
      // Silently fail, analytics/exposure tracking shouldn't break the app
    }
  }
}

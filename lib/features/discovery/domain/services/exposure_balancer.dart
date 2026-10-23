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
      // 1. Try single batch RPC call
      try {
        await supabase.rpc(
          'batch_increment_exposure',
          params: {'profile_ids': profileIds},
        );
        return;
      } catch (_) {
        // Fall back to chunked calls if batch RPC is not available yet
      }

      // 2. Concurrency-bounded chunked execution (5 at a time) to prevent socket pool exhaustion
      for (int i = 0; i < profileIds.length; i += 5) {
        final chunk = profileIds.skip(i).take(5);
        await Future.wait(
          chunk.map((id) => supabase
              .rpc('increment_exposure', params: {'profile_id': id})
              .onError((_, __) => null)),
        );
      }
    } catch (_) {
      // Silently fail, analytics/exposure tracking shouldn't break the app
    }
  }
}

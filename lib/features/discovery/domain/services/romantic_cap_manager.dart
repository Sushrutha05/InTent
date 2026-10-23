import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/core/constants/behavior_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'romantic_cap_manager.g.dart';

@riverpod
class RomanticCapManager extends _$RomanticCapManager {
  @override
  Future<bool> build() async {
    return _checkCapStatus();
  }

  Future<bool> _checkCapStatus() async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return false; // Fail safe

    try {
      // Find all matches where current user is involved and intent is romantic
      // Assuming a 'matches' table exists that holds the resolved match states
      final response = await supabase
          .from('matches')
          .select('id, intent_type, last_message_at')
          .or('user1_id.eq.${currentUser.id},user2_id.eq.${currentUser.id}')
          .inFilter('intent_type', ['ROMANTIC', 'Romantic']);

      final activeMatches =
          (response as List<dynamic>).where((match) {
            // Expiration Logic: if romanticExpiryHours passed with no message
            final lastMessageAtStr = match['last_message_at'] as String?;
            if (lastMessageAtStr == null) {
              return true; // Just matched, no message yet, still active
            }

            final lastMessageAt = DateTime.parse(lastMessageAtStr);
            final hoursSince = DateTime.now().difference(lastMessageAt).inHours;

            return hoursSince < BehaviorConstants.romanticExpiryHours;
          }).length;

      return activeMatches >= BehaviorConstants.maxActiveRomanticMatches;
    } catch (e) {
      debugPrint('Error checking romantic cap: $e');
      return false; // Don't block if we can't verify
    }
  }

  Future<void> refreshCapStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _checkCapStatus());
  }
}

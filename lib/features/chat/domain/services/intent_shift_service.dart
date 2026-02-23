import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/features/discovery/domain/services/romantic_cap_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'intent_shift_service.g.dart';

@riverpod
class IntentShiftService extends _$IntentShiftService {
  @override
  void build() {}

  /// Propose an intent shift inside a chat channel
  Future<bool> proposeIntentShift({
    required String channelId,
    required String targetUserId,
    required String newIntentType,
  }) async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return false;

    // Check romantic cap if shifting to romantic
    if (newIntentType == 'ROMANTIC') {
      final isCapped =
          await ref.read(romanticCapManagerProvider.notifier).build();
      if (isCapped) {
        debugPrint('Blocked intent shift to Romantic due to Cap Limit.');
        return false; // UI should show error indicating Cap reached
      }
    }

    try {
      // 1. Insert a shift proposal to 'intent_shift_requests' table (mocked concept)
      // For this implementation, we just insert a system message simulating the request
      await supabase.from('messages').insert({
        'channel_id': channelId,
        'sender_id': currentUser.id,
        'content': 'System: Requesting shift to $newIntentType',
        'is_system_message': true,
        'intent_shift_request_type': newIntentType,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error proposing shift: $e');
      return false;
    }
  }

  /// Accept an intent shift
  Future<bool> acceptIntentShift({
    required String channelId,
    required String newIntentType,
  }) async {
    final supabase = Supabase.instance.client;
    try {
      // 1. Update the actual match intent in the DB
      await supabase
          .from('matches')
          .update({'intent_type': newIntentType})
          .eq('channel_id', channelId);

      return true;
    } catch (e) {
      debugPrint('Error accepting shift: $e');
      return false;
    }
  }
}

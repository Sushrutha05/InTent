import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingService {
  static const String _prefix = 'is_onboarded_';

  /// Check whether the user has completed onboarding.
  /// 1. Fast local cache check for instant navigation.
  /// 2. Remote Supabase check verifying `is_onboarded` flag or complete profile fields.
  static Future<bool> isOnboarded(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('$_prefix$userId') == true) {
        return true;
      }

      final supabase = Supabase.instance.client;
      final profile = await supabase
          .from('profiles')
          .select('is_onboarded, first_name, photo_urls')
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        final bool isFlagOnboarded = profile['is_onboarded'] as bool? ?? false;
        final bool hasName = (profile['first_name'] as String?)?.trim().isNotEmpty ?? false;
        final bool hasPhotos = (profile['photo_urls'] as List?)?.isNotEmpty ?? false;

        final bool complete = isFlagOnboarded || (hasName && hasPhotos);
        if (complete) {
          await prefs.setBool('$_prefix$userId', true);
          // Sync DB flag if it was false/null
          if (!isFlagOnboarded) {
            await supabase
                .from('profiles')
                .update({'is_onboarded': true})
                .eq('id', userId);
          }
        }
        return complete;
      }
      return false;
    } catch (e) {
      debugPrint('OnboardingService error checking status: $e');
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_prefix$userId') ?? false;
    }
  }

  /// Mark the user as having completed onboarding locally
  static Future<void> markOnboarded(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_prefix$userId', true);
    } catch (e) {
      debugPrint('Error writing onboarding status to SharedPreferences: $e');
    }
  }

  /// Clear the local onboarding cache for this user
  static Future<void> clearOnboarding(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$userId');
    } catch (e) {
      debugPrint('Error clearing onboarding status from SharedPreferences: $e');
    }
  }
}

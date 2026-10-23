import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/core/services/onboarding_service.dart';
import 'package:student_dating_app/features/onboarding/domain/onboarding_state.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<void> saveOnboardingProfile(OnboardingState state) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user found.');

    // 1. Upload Photos to Storage Bucket in Parallel
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uploadFutures = state.localPhotoPaths.asMap().entries.map((entry) async {
      final i = entry.key;
      final path = entry.value;
      final file = File(path);
      if (await file.exists()) {
        final extension = path.split('.').last;
        final fileName = '${user.id}/${timestamp}_$i.$extension';

        debugPrint('Uploading to profile_photos: $fileName');
        await _client.storage.from('profile_photos').upload(fileName, file);
        debugPrint('Upload successful for $fileName');

        return _client.storage.from('profile_photos').getPublicUrl(fileName);
      }
      return null;
    });

    final results = await Future.wait(uploadFutures);
    final List<String> uploadedPhotoUrls = results.whereType<String>().toList();

    // 2. Insert into Profiles Table
    debugPrint('Inserting profile data: ${user.id}');
    final profileData = {
      'id': user.id,
      'email': user.email,
      'first_name': state.name,
      'university': state.university,
      'major': state.major,
      'date_of_birth': state.dateOfBirth?.toIso8601String(),
      'primary_intent': state.primaryIntent?.name,
      'interests': state.interests,
      'photo_urls': uploadedPhotoUrls,
      'is_onboarded': true,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client.from('profiles').upsert(profileData);
    await OnboardingService.markOnboarded(user.id);
    debugPrint('Successfully saved profile data!');
  }
}

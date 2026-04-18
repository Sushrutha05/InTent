import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

    List<String> uploadedPhotoUrls = [];

    // 1. Upload Photos to Storage Bucket
    for (int i = 0; i < state.localPhotoPaths.length; i++) {
      final path = state.localPhotoPaths[i];
      // In a real app with image_picker, path would be a valid file path.
      // We simulate success here if it's a mock path.
      if (!path.startsWith('mock_photo')) {
        final file = File(path);
        final extension = path.split('.').last;
        final fileName =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$i.$extension';

        debugPrint('Uploading to profile_photos: $fileName');
        await _client.storage.from('profile_photos').upload(fileName, file);
        debugPrint('Upload successful for $fileName');

        final publicUrl = _client.storage
            .from('profile_photos')
            .getPublicUrl(fileName);
        uploadedPhotoUrls.add(publicUrl);
      } else {
        uploadedPhotoUrls.add('https://mock-image-url.com/${user.id}/$i.jpg');
      }
    }

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
    debugPrint('Successfully saved profile data!');
  }
}

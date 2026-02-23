import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(Supabase.instance.client);
});

class UserProfileRepository {
  final SupabaseClient _client;

  UserProfileRepository(this._client);

  Future<ProfileCardModel> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user found.');

    final response =
        await _client.from('profiles').select().eq('id', user.id).single();

    return ProfileCardModel(
      id: response['id'] as String,
      name: response['first_name'] as String? ?? 'User',
      age:
          response['date_of_birth'] != null
              ? DateTime.now().year -
                  DateTime.parse(response['date_of_birth'] as String).year
              : 20,
      university: response['university'] as String? ?? '',
      major: response['major'] as String? ?? '',
      primaryIntent: response['primary_intent'] as String? ?? 'friendship',
      bio: response['bio'] as String? ?? '',
      interests:
          (response['interests'] as List? ?? [])
              .map((e) => e.toString())
              .toList(),
      photoUrls:
          (response['photo_urls'] as List? ?? [])
              .map((e) => e.toString())
              .toList(),
      vibePrompt: response['vibe_prompt'] as String? ?? '',
      vibeAnswer: response['vibe_answer'] as String? ?? '',
    );
  }

  Future<void> updateBio(String bio) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user found.');

    await _client.from('profiles').update({'bio': bio}).eq('id', user.id);
  }

  Future<String> uploadPhoto(File file) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user found.');

    final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _client.storage.from('profile_photos').upload(fileName, file);

    return _client.storage.from('profile_photos').getPublicUrl(fileName);
  }

  Future<void> updatePhotoUrls(List<String> photoUrls) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user found.');

    await _client
        .from('profiles')
        .update({'photo_urls': photoUrls})
        .eq('id', user.id);
  }
}

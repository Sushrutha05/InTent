import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/profile/data/user_profile_repository.dart';

part 'user_profile_provider.g.dart';

@riverpod
class UserProfile extends _$UserProfile {
  @override
  FutureOr<ProfileCardModel> build() async {
    return ref.read(userProfileRepositoryProvider).getCurrentUserProfile();
  }

  Future<void> updateBio(String bio) async {
    // Optimistic update
    final previousState = state;
    state = AsyncValue.data(state.value!.copyWith(bio: bio));

    try {
      await ref.read(userProfileRepositoryProvider).updateBio(bio);
    } catch (e, st) {
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPhoto(File file) async {
    final currentProfile = state.value;
    if (currentProfile == null || currentProfile.photoUrls.length >= 6) return;

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(userProfileRepositoryProvider);
      final newUrl = await repository.uploadPhoto(file);

      final updatedUrls = [...currentProfile.photoUrls, newUrl];
      await repository.updatePhotoUrls(updatedUrls);

      state = AsyncValue.data(currentProfile.copyWith(photoUrls: updatedUrls));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removePhoto(int index) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedUrls = List<String>.from(currentProfile.photoUrls);
    updatedUrls.removeAt(index);

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.updatePhotoUrls(updatedUrls);

      state = AsyncValue.data(currentProfile.copyWith(photoUrls: updatedUrls));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setPrimaryPhoto(int index) async {
    final currentProfile = state.value;
    if (currentProfile == null || index == 0) return;

    final updatedUrls = List<String>.from(currentProfile.photoUrls);
    final photo = updatedUrls.removeAt(index);
    updatedUrls.insert(0, photo);

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.updatePhotoUrls(updatedUrls);

      state = AsyncValue.data(currentProfile.copyWith(photoUrls: updatedUrls));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

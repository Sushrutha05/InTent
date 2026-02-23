import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/features/onboarding/domain/onboarding_state.dart';
import 'package:student_dating_app/features/onboarding/data/profile_repository.dart';

part 'onboarding_provider.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setIntent(UserIntent intent) {
    state = state.copyWith(primaryIntent: intent);
  }

  void updateBasicInfo({
    required String name,
    required DateTime dateOfBirth,
    required String university,
    required String major,
  }) {
    state = state.copyWith(
      name: name,
      dateOfBirth: dateOfBirth,
      university: university,
      major: major,
    );
  }

  void toggleInterest(String interest) {
    final currentInterests = List<String>.from(state.interests);
    if (currentInterests.contains(interest)) {
      currentInterests.remove(interest);
    } else {
      if (currentInterests.length < 5) {
        currentInterests.add(interest);
      }
    }
    state = state.copyWith(interests: currentInterests);
  }

  void addPhoto(String path) {
    if (state.localPhotoPaths.length < 6) {
      state = state.copyWith(localPhotoPaths: [...state.localPhotoPaths, path]);
    }
  }

  void removePhoto(int index) {
    final photos = List<String>.from(state.localPhotoPaths);
    photos.removeAt(index);
    state = state.copyWith(localPhotoPaths: photos);
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    final photos = List<String>.from(state.localPhotoPaths);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = photos.removeAt(oldIndex);
    photos.insert(newIndex, item);
    state = state.copyWith(localPhotoPaths: photos);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      // Actually save the profile to Supabase
      await ref.read(profileRepositoryProvider).saveOnboardingProfile(state);

      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow; // Rethrow so UI catches it instead of silently failing
    }
  }
}

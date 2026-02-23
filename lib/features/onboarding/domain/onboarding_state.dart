import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';
part 'onboarding_state.g.dart';

enum UserIntent { romance, friendship, collaboration }

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentStep,
    UserIntent? primaryIntent,
    String? name,
    DateTime? dateOfBirth,
    String? university,
    String? major,
    @Default([]) List<String> interests,
    @Default([]) List<String> localPhotoPaths,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _OnboardingState;

  factory OnboardingState.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStateFromJson(json);
}

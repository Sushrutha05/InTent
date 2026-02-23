// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OnboardingStateImpl _$$OnboardingStateImplFromJson(
  Map<String, dynamic> json,
) => _$OnboardingStateImpl(
  currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
  primaryIntent: $enumDecodeNullable(
    _$UserIntentEnumMap,
    json['primaryIntent'],
  ),
  name: json['name'] as String?,
  dateOfBirth:
      json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
  university: json['university'] as String?,
  major: json['major'] as String?,
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  localPhotoPaths:
      (json['localPhotoPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isSubmitting: json['isSubmitting'] as bool? ?? false,
  error: json['error'] as String?,
);

Map<String, dynamic> _$$OnboardingStateImplToJson(
  _$OnboardingStateImpl instance,
) => <String, dynamic>{
  'currentStep': instance.currentStep,
  'primaryIntent': _$UserIntentEnumMap[instance.primaryIntent],
  'name': instance.name,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'university': instance.university,
  'major': instance.major,
  'interests': instance.interests,
  'localPhotoPaths': instance.localPhotoPaths,
  'isSubmitting': instance.isSubmitting,
  'error': instance.error,
};

const _$UserIntentEnumMap = {
  UserIntent.romance: 'romance',
  UserIntent.friendship: 'friendship',
  UserIntent.collaboration: 'collaboration',
};

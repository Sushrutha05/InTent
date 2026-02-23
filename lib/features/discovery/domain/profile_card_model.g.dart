// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileCardModelImpl _$$ProfileCardModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileCardModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  university: json['university'] as String,
  major: json['major'] as String,
  primaryIntent: json['primaryIntent'] as String,
  bio: json['bio'] as String? ?? '',
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  currentBlurLevel: (json['currentBlurLevel'] as num?)?.toDouble() ?? 0.0,
  vibePrompt: json['vibePrompt'] as String? ?? '',
  vibeAnswer: json['vibeAnswer'] as String? ?? '',
  globalIntentPreference:
      json['globalIntentPreference'] as String? ?? 'friendship',
  exposureCount: (json['exposureCount'] as num?)?.toInt() ?? 0,
  lastShownTimestamp:
      json['lastShownTimestamp'] == null
          ? null
          : DateTime.parse(json['lastShownTimestamp'] as String),
);

Map<String, dynamic> _$$ProfileCardModelImplToJson(
  _$ProfileCardModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'age': instance.age,
  'university': instance.university,
  'major': instance.major,
  'primaryIntent': instance.primaryIntent,
  'bio': instance.bio,
  'interests': instance.interests,
  'photoUrls': instance.photoUrls,
  'currentBlurLevel': instance.currentBlurLevel,
  'vibePrompt': instance.vibePrompt,
  'vibeAnswer': instance.vibeAnswer,
  'globalIntentPreference': instance.globalIntentPreference,
  'exposureCount': instance.exposureCount,
  'lastShownTimestamp': instance.lastShownTimestamp?.toIso8601String(),
};

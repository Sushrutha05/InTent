// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IntentModelImpl _$$IntentModelImplFromJson(Map<String, dynamic> json) =>
    _$IntentModelImpl(
      id: json['id'] as String,
      actorId: json['actorId'] as String,
      targetId: json['targetId'] as String,
      actionType: json['actionType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetProfile: ProfileCardModel.fromJson(
        json['targetProfile'] as Map<String, dynamic>,
      ),
      swipeReason: json['swipeReason'] as String?,
    );

Map<String, dynamic> _$$IntentModelImplToJson(_$IntentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actorId': instance.actorId,
      'targetId': instance.targetId,
      'actionType': instance.actionType,
      'createdAt': instance.createdAt.toIso8601String(),
      'targetProfile': instance.targetProfile,
      'swipeReason': instance.swipeReason,
    };

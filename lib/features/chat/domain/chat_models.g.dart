// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
    };

_$ChatChannelImpl _$$ChatChannelImplFromJson(Map<String, dynamic> json) =>
    _$ChatChannelImpl(
      id: json['id'] as String,
      matchedUser: ProfileCardModel.fromJson(
        json['matchedUser'] as Map<String, dynamic>,
      ),
      messages:
          (json['messages'] as List<dynamic>)
              .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList(),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      unblurProgress: (json['unblurProgress'] as num?)?.toDouble() ?? 0.0,
      isGalleryUnlocked: json['isGalleryUnlocked'] as bool? ?? false,
    );

Map<String, dynamic> _$$ChatChannelImplToJson(_$ChatChannelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matchedUser': instance.matchedUser,
      'messages': instance.messages,
      'lastActivityAt': instance.lastActivityAt.toIso8601String(),
      'unblurProgress': instance.unblurProgress,
      'isGalleryUnlocked': instance.isGalleryUnlocked,
    };

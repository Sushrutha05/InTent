import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    required String content,
    required DateTime createdAt,
    @Default(false) bool isRead,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class ChatChannel with _$ChatChannel {
  const factory ChatChannel({
    required String id,
    required ProfileCardModel matchedUser, // The other person in the chat
    required List<ChatMessage> messages,
    required DateTime lastActivityAt,
    @Default(0.0)
    double unblurProgress, // How unblurred the other person is (0.0 to 1.0)
    @Default(false) bool isGalleryUnlocked,
  }) = _ChatChannel;

  factory ChatChannel.fromJson(Map<String, dynamic> json) =>
      _$ChatChannelFromJson(json);
}

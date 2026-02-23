// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String senderId,
    String content,
    DateTime createdAt,
    bool isRead,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? isRead = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            senderId:
                null == senderId
                    ? _value.senderId
                    : senderId // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            isRead:
                null == isRead
                    ? _value.isRead
                    : isRead // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String senderId,
    String content,
    DateTime createdAt,
    bool isRead,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? isRead = null,
  }) {
    return _then(
      _$ChatMessageImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        senderId:
            null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        isRead:
            null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isRead;

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderId: $senderId, content: $content, createdAt: $createdAt, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, senderId, content, createdAt, isRead);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String senderId,
    required final String content,
    required final DateTime createdAt,
    final bool isRead,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get senderId;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  bool get isRead;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatChannel _$ChatChannelFromJson(Map<String, dynamic> json) {
  return _ChatChannel.fromJson(json);
}

/// @nodoc
mixin _$ChatChannel {
  String get id => throw _privateConstructorUsedError;
  ProfileCardModel get matchedUser =>
      throw _privateConstructorUsedError; // The other person in the chat
  List<ChatMessage> get messages => throw _privateConstructorUsedError;
  DateTime get lastActivityAt => throw _privateConstructorUsedError;
  double get unblurProgress =>
      throw _privateConstructorUsedError; // How unblurred the other person is (0.0 to 1.0)
  bool get isGalleryUnlocked => throw _privateConstructorUsedError;

  /// Serializes this ChatChannel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatChannelCopyWith<ChatChannel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatChannelCopyWith<$Res> {
  factory $ChatChannelCopyWith(
    ChatChannel value,
    $Res Function(ChatChannel) then,
  ) = _$ChatChannelCopyWithImpl<$Res, ChatChannel>;
  @useResult
  $Res call({
    String id,
    ProfileCardModel matchedUser,
    List<ChatMessage> messages,
    DateTime lastActivityAt,
    double unblurProgress,
    bool isGalleryUnlocked,
  });

  $ProfileCardModelCopyWith<$Res> get matchedUser;
}

/// @nodoc
class _$ChatChannelCopyWithImpl<$Res, $Val extends ChatChannel>
    implements $ChatChannelCopyWith<$Res> {
  _$ChatChannelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchedUser = null,
    Object? messages = null,
    Object? lastActivityAt = null,
    Object? unblurProgress = null,
    Object? isGalleryUnlocked = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            matchedUser:
                null == matchedUser
                    ? _value.matchedUser
                    : matchedUser // ignore: cast_nullable_to_non_nullable
                        as ProfileCardModel,
            messages:
                null == messages
                    ? _value.messages
                    : messages // ignore: cast_nullable_to_non_nullable
                        as List<ChatMessage>,
            lastActivityAt:
                null == lastActivityAt
                    ? _value.lastActivityAt
                    : lastActivityAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            unblurProgress:
                null == unblurProgress
                    ? _value.unblurProgress
                    : unblurProgress // ignore: cast_nullable_to_non_nullable
                        as double,
            isGalleryUnlocked:
                null == isGalleryUnlocked
                    ? _value.isGalleryUnlocked
                    : isGalleryUnlocked // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileCardModelCopyWith<$Res> get matchedUser {
    return $ProfileCardModelCopyWith<$Res>(_value.matchedUser, (value) {
      return _then(_value.copyWith(matchedUser: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatChannelImplCopyWith<$Res>
    implements $ChatChannelCopyWith<$Res> {
  factory _$$ChatChannelImplCopyWith(
    _$ChatChannelImpl value,
    $Res Function(_$ChatChannelImpl) then,
  ) = __$$ChatChannelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    ProfileCardModel matchedUser,
    List<ChatMessage> messages,
    DateTime lastActivityAt,
    double unblurProgress,
    bool isGalleryUnlocked,
  });

  @override
  $ProfileCardModelCopyWith<$Res> get matchedUser;
}

/// @nodoc
class __$$ChatChannelImplCopyWithImpl<$Res>
    extends _$ChatChannelCopyWithImpl<$Res, _$ChatChannelImpl>
    implements _$$ChatChannelImplCopyWith<$Res> {
  __$$ChatChannelImplCopyWithImpl(
    _$ChatChannelImpl _value,
    $Res Function(_$ChatChannelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchedUser = null,
    Object? messages = null,
    Object? lastActivityAt = null,
    Object? unblurProgress = null,
    Object? isGalleryUnlocked = null,
  }) {
    return _then(
      _$ChatChannelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        matchedUser:
            null == matchedUser
                ? _value.matchedUser
                : matchedUser // ignore: cast_nullable_to_non_nullable
                    as ProfileCardModel,
        messages:
            null == messages
                ? _value._messages
                : messages // ignore: cast_nullable_to_non_nullable
                    as List<ChatMessage>,
        lastActivityAt:
            null == lastActivityAt
                ? _value.lastActivityAt
                : lastActivityAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        unblurProgress:
            null == unblurProgress
                ? _value.unblurProgress
                : unblurProgress // ignore: cast_nullable_to_non_nullable
                    as double,
        isGalleryUnlocked:
            null == isGalleryUnlocked
                ? _value.isGalleryUnlocked
                : isGalleryUnlocked // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatChannelImpl implements _ChatChannel {
  const _$ChatChannelImpl({
    required this.id,
    required this.matchedUser,
    required final List<ChatMessage> messages,
    required this.lastActivityAt,
    this.unblurProgress = 0.0,
    this.isGalleryUnlocked = false,
  }) : _messages = messages;

  factory _$ChatChannelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatChannelImplFromJson(json);

  @override
  final String id;
  @override
  final ProfileCardModel matchedUser;
  // The other person in the chat
  final List<ChatMessage> _messages;
  // The other person in the chat
  @override
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final DateTime lastActivityAt;
  @override
  @JsonKey()
  final double unblurProgress;
  // How unblurred the other person is (0.0 to 1.0)
  @override
  @JsonKey()
  final bool isGalleryUnlocked;

  @override
  String toString() {
    return 'ChatChannel(id: $id, matchedUser: $matchedUser, messages: $messages, lastActivityAt: $lastActivityAt, unblurProgress: $unblurProgress, isGalleryUnlocked: $isGalleryUnlocked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatChannelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matchedUser, matchedUser) ||
                other.matchedUser == matchedUser) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt) &&
            (identical(other.unblurProgress, unblurProgress) ||
                other.unblurProgress == unblurProgress) &&
            (identical(other.isGalleryUnlocked, isGalleryUnlocked) ||
                other.isGalleryUnlocked == isGalleryUnlocked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    matchedUser,
    const DeepCollectionEquality().hash(_messages),
    lastActivityAt,
    unblurProgress,
    isGalleryUnlocked,
  );

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatChannelImplCopyWith<_$ChatChannelImpl> get copyWith =>
      __$$ChatChannelImplCopyWithImpl<_$ChatChannelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatChannelImplToJson(this);
  }
}

abstract class _ChatChannel implements ChatChannel {
  const factory _ChatChannel({
    required final String id,
    required final ProfileCardModel matchedUser,
    required final List<ChatMessage> messages,
    required final DateTime lastActivityAt,
    final double unblurProgress,
    final bool isGalleryUnlocked,
  }) = _$ChatChannelImpl;

  factory _ChatChannel.fromJson(Map<String, dynamic> json) =
      _$ChatChannelImpl.fromJson;

  @override
  String get id;
  @override
  ProfileCardModel get matchedUser; // The other person in the chat
  @override
  List<ChatMessage> get messages;
  @override
  DateTime get lastActivityAt;
  @override
  double get unblurProgress; // How unblurred the other person is (0.0 to 1.0)
  @override
  bool get isGalleryUnlocked;

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatChannelImplCopyWith<_$ChatChannelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

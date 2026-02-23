// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'intent_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

IntentModel _$IntentModelFromJson(Map<String, dynamic> json) {
  return _IntentModel.fromJson(json);
}

/// @nodoc
mixin _$IntentModel {
  String get id => throw _privateConstructorUsedError;
  String get actorId => throw _privateConstructorUsedError;
  String get targetId => throw _privateConstructorUsedError;
  String get actionType => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  ProfileCardModel get targetProfile => throw _privateConstructorUsedError;
  String? get swipeReason => throw _privateConstructorUsedError;

  /// Serializes this IntentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IntentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IntentModelCopyWith<IntentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IntentModelCopyWith<$Res> {
  factory $IntentModelCopyWith(
    IntentModel value,
    $Res Function(IntentModel) then,
  ) = _$IntentModelCopyWithImpl<$Res, IntentModel>;
  @useResult
  $Res call({
    String id,
    String actorId,
    String targetId,
    String actionType,
    DateTime createdAt,
    ProfileCardModel targetProfile,
    String? swipeReason,
  });

  $ProfileCardModelCopyWith<$Res> get targetProfile;
}

/// @nodoc
class _$IntentModelCopyWithImpl<$Res, $Val extends IntentModel>
    implements $IntentModelCopyWith<$Res> {
  _$IntentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IntentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actorId = null,
    Object? targetId = null,
    Object? actionType = null,
    Object? createdAt = null,
    Object? targetProfile = null,
    Object? swipeReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            actorId:
                null == actorId
                    ? _value.actorId
                    : actorId // ignore: cast_nullable_to_non_nullable
                        as String,
            targetId:
                null == targetId
                    ? _value.targetId
                    : targetId // ignore: cast_nullable_to_non_nullable
                        as String,
            actionType:
                null == actionType
                    ? _value.actionType
                    : actionType // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            targetProfile:
                null == targetProfile
                    ? _value.targetProfile
                    : targetProfile // ignore: cast_nullable_to_non_nullable
                        as ProfileCardModel,
            swipeReason:
                freezed == swipeReason
                    ? _value.swipeReason
                    : swipeReason // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of IntentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileCardModelCopyWith<$Res> get targetProfile {
    return $ProfileCardModelCopyWith<$Res>(_value.targetProfile, (value) {
      return _then(_value.copyWith(targetProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$IntentModelImplCopyWith<$Res>
    implements $IntentModelCopyWith<$Res> {
  factory _$$IntentModelImplCopyWith(
    _$IntentModelImpl value,
    $Res Function(_$IntentModelImpl) then,
  ) = __$$IntentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String actorId,
    String targetId,
    String actionType,
    DateTime createdAt,
    ProfileCardModel targetProfile,
    String? swipeReason,
  });

  @override
  $ProfileCardModelCopyWith<$Res> get targetProfile;
}

/// @nodoc
class __$$IntentModelImplCopyWithImpl<$Res>
    extends _$IntentModelCopyWithImpl<$Res, _$IntentModelImpl>
    implements _$$IntentModelImplCopyWith<$Res> {
  __$$IntentModelImplCopyWithImpl(
    _$IntentModelImpl _value,
    $Res Function(_$IntentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IntentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actorId = null,
    Object? targetId = null,
    Object? actionType = null,
    Object? createdAt = null,
    Object? targetProfile = null,
    Object? swipeReason = freezed,
  }) {
    return _then(
      _$IntentModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        actorId:
            null == actorId
                ? _value.actorId
                : actorId // ignore: cast_nullable_to_non_nullable
                    as String,
        targetId:
            null == targetId
                ? _value.targetId
                : targetId // ignore: cast_nullable_to_non_nullable
                    as String,
        actionType:
            null == actionType
                ? _value.actionType
                : actionType // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        targetProfile:
            null == targetProfile
                ? _value.targetProfile
                : targetProfile // ignore: cast_nullable_to_non_nullable
                    as ProfileCardModel,
        swipeReason:
            freezed == swipeReason
                ? _value.swipeReason
                : swipeReason // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IntentModelImpl implements _IntentModel {
  const _$IntentModelImpl({
    required this.id,
    required this.actorId,
    required this.targetId,
    required this.actionType,
    required this.createdAt,
    required this.targetProfile,
    this.swipeReason,
  });

  factory _$IntentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$IntentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String actorId;
  @override
  final String targetId;
  @override
  final String actionType;
  @override
  final DateTime createdAt;
  @override
  final ProfileCardModel targetProfile;
  @override
  final String? swipeReason;

  @override
  String toString() {
    return 'IntentModel(id: $id, actorId: $actorId, targetId: $targetId, actionType: $actionType, createdAt: $createdAt, targetProfile: $targetProfile, swipeReason: $swipeReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IntentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.actorId, actorId) || other.actorId == actorId) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.targetProfile, targetProfile) ||
                other.targetProfile == targetProfile) &&
            (identical(other.swipeReason, swipeReason) ||
                other.swipeReason == swipeReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    actorId,
    targetId,
    actionType,
    createdAt,
    targetProfile,
    swipeReason,
  );

  /// Create a copy of IntentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IntentModelImplCopyWith<_$IntentModelImpl> get copyWith =>
      __$$IntentModelImplCopyWithImpl<_$IntentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IntentModelImplToJson(this);
  }
}

abstract class _IntentModel implements IntentModel {
  const factory _IntentModel({
    required final String id,
    required final String actorId,
    required final String targetId,
    required final String actionType,
    required final DateTime createdAt,
    required final ProfileCardModel targetProfile,
    final String? swipeReason,
  }) = _$IntentModelImpl;

  factory _IntentModel.fromJson(Map<String, dynamic> json) =
      _$IntentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get actorId;
  @override
  String get targetId;
  @override
  String get actionType;
  @override
  DateTime get createdAt;
  @override
  ProfileCardModel get targetProfile;
  @override
  String? get swipeReason;

  /// Create a copy of IntentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IntentModelImplCopyWith<_$IntentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProfileCardModel _$ProfileCardModelFromJson(Map<String, dynamic> json) {
  return _ProfileCardModel.fromJson(json);
}

/// @nodoc
mixin _$ProfileCardModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String get university => throw _privateConstructorUsedError;
  String get major => throw _privateConstructorUsedError;
  String get primaryIntent =>
      throw _privateConstructorUsedError; // e.g., 'romance', 'friendship'
  String get bio => throw _privateConstructorUsedError;
  List<String> get interests => throw _privateConstructorUsedError;
  List<String> get photoUrls => throw _privateConstructorUsedError;
  double get currentBlurLevel =>
      throw _privateConstructorUsedError; // 0.0 (clear) to 1.0 (max blur)
  String get vibePrompt => throw _privateConstructorUsedError;
  String get vibeAnswer => throw _privateConstructorUsedError;
  String get globalIntentPreference => throw _privateConstructorUsedError;
  int get exposureCount => throw _privateConstructorUsedError;
  DateTime? get lastShownTimestamp => throw _privateConstructorUsedError;

  /// Serializes this ProfileCardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileCardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileCardModelCopyWith<ProfileCardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCardModelCopyWith<$Res> {
  factory $ProfileCardModelCopyWith(
    ProfileCardModel value,
    $Res Function(ProfileCardModel) then,
  ) = _$ProfileCardModelCopyWithImpl<$Res, ProfileCardModel>;
  @useResult
  $Res call({
    String id,
    String name,
    int age,
    String university,
    String major,
    String primaryIntent,
    String bio,
    List<String> interests,
    List<String> photoUrls,
    double currentBlurLevel,
    String vibePrompt,
    String vibeAnswer,
    String globalIntentPreference,
    int exposureCount,
    DateTime? lastShownTimestamp,
  });
}

/// @nodoc
class _$ProfileCardModelCopyWithImpl<$Res, $Val extends ProfileCardModel>
    implements $ProfileCardModelCopyWith<$Res> {
  _$ProfileCardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileCardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? age = null,
    Object? university = null,
    Object? major = null,
    Object? primaryIntent = null,
    Object? bio = null,
    Object? interests = null,
    Object? photoUrls = null,
    Object? currentBlurLevel = null,
    Object? vibePrompt = null,
    Object? vibeAnswer = null,
    Object? globalIntentPreference = null,
    Object? exposureCount = null,
    Object? lastShownTimestamp = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            age:
                null == age
                    ? _value.age
                    : age // ignore: cast_nullable_to_non_nullable
                        as int,
            university:
                null == university
                    ? _value.university
                    : university // ignore: cast_nullable_to_non_nullable
                        as String,
            major:
                null == major
                    ? _value.major
                    : major // ignore: cast_nullable_to_non_nullable
                        as String,
            primaryIntent:
                null == primaryIntent
                    ? _value.primaryIntent
                    : primaryIntent // ignore: cast_nullable_to_non_nullable
                        as String,
            bio:
                null == bio
                    ? _value.bio
                    : bio // ignore: cast_nullable_to_non_nullable
                        as String,
            interests:
                null == interests
                    ? _value.interests
                    : interests // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            photoUrls:
                null == photoUrls
                    ? _value.photoUrls
                    : photoUrls // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            currentBlurLevel:
                null == currentBlurLevel
                    ? _value.currentBlurLevel
                    : currentBlurLevel // ignore: cast_nullable_to_non_nullable
                        as double,
            vibePrompt:
                null == vibePrompt
                    ? _value.vibePrompt
                    : vibePrompt // ignore: cast_nullable_to_non_nullable
                        as String,
            vibeAnswer:
                null == vibeAnswer
                    ? _value.vibeAnswer
                    : vibeAnswer // ignore: cast_nullable_to_non_nullable
                        as String,
            globalIntentPreference:
                null == globalIntentPreference
                    ? _value.globalIntentPreference
                    : globalIntentPreference // ignore: cast_nullable_to_non_nullable
                        as String,
            exposureCount:
                null == exposureCount
                    ? _value.exposureCount
                    : exposureCount // ignore: cast_nullable_to_non_nullable
                        as int,
            lastShownTimestamp:
                freezed == lastShownTimestamp
                    ? _value.lastShownTimestamp
                    : lastShownTimestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileCardModelImplCopyWith<$Res>
    implements $ProfileCardModelCopyWith<$Res> {
  factory _$$ProfileCardModelImplCopyWith(
    _$ProfileCardModelImpl value,
    $Res Function(_$ProfileCardModelImpl) then,
  ) = __$$ProfileCardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int age,
    String university,
    String major,
    String primaryIntent,
    String bio,
    List<String> interests,
    List<String> photoUrls,
    double currentBlurLevel,
    String vibePrompt,
    String vibeAnswer,
    String globalIntentPreference,
    int exposureCount,
    DateTime? lastShownTimestamp,
  });
}

/// @nodoc
class __$$ProfileCardModelImplCopyWithImpl<$Res>
    extends _$ProfileCardModelCopyWithImpl<$Res, _$ProfileCardModelImpl>
    implements _$$ProfileCardModelImplCopyWith<$Res> {
  __$$ProfileCardModelImplCopyWithImpl(
    _$ProfileCardModelImpl _value,
    $Res Function(_$ProfileCardModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileCardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? age = null,
    Object? university = null,
    Object? major = null,
    Object? primaryIntent = null,
    Object? bio = null,
    Object? interests = null,
    Object? photoUrls = null,
    Object? currentBlurLevel = null,
    Object? vibePrompt = null,
    Object? vibeAnswer = null,
    Object? globalIntentPreference = null,
    Object? exposureCount = null,
    Object? lastShownTimestamp = freezed,
  }) {
    return _then(
      _$ProfileCardModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        age:
            null == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                    as int,
        university:
            null == university
                ? _value.university
                : university // ignore: cast_nullable_to_non_nullable
                    as String,
        major:
            null == major
                ? _value.major
                : major // ignore: cast_nullable_to_non_nullable
                    as String,
        primaryIntent:
            null == primaryIntent
                ? _value.primaryIntent
                : primaryIntent // ignore: cast_nullable_to_non_nullable
                    as String,
        bio:
            null == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                    as String,
        interests:
            null == interests
                ? _value._interests
                : interests // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        photoUrls:
            null == photoUrls
                ? _value._photoUrls
                : photoUrls // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        currentBlurLevel:
            null == currentBlurLevel
                ? _value.currentBlurLevel
                : currentBlurLevel // ignore: cast_nullable_to_non_nullable
                    as double,
        vibePrompt:
            null == vibePrompt
                ? _value.vibePrompt
                : vibePrompt // ignore: cast_nullable_to_non_nullable
                    as String,
        vibeAnswer:
            null == vibeAnswer
                ? _value.vibeAnswer
                : vibeAnswer // ignore: cast_nullable_to_non_nullable
                    as String,
        globalIntentPreference:
            null == globalIntentPreference
                ? _value.globalIntentPreference
                : globalIntentPreference // ignore: cast_nullable_to_non_nullable
                    as String,
        exposureCount:
            null == exposureCount
                ? _value.exposureCount
                : exposureCount // ignore: cast_nullable_to_non_nullable
                    as int,
        lastShownTimestamp:
            freezed == lastShownTimestamp
                ? _value.lastShownTimestamp
                : lastShownTimestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileCardModelImpl implements _ProfileCardModel {
  const _$ProfileCardModelImpl({
    required this.id,
    required this.name,
    required this.age,
    required this.university,
    required this.major,
    required this.primaryIntent,
    this.bio = '',
    final List<String> interests = const [],
    final List<String> photoUrls = const [],
    this.currentBlurLevel = 0.0,
    this.vibePrompt = '',
    this.vibeAnswer = '',
    this.globalIntentPreference = 'friendship',
    this.exposureCount = 0,
    this.lastShownTimestamp,
  }) : _interests = interests,
       _photoUrls = photoUrls;

  factory _$ProfileCardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileCardModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int age;
  @override
  final String university;
  @override
  final String major;
  @override
  final String primaryIntent;
  // e.g., 'romance', 'friendship'
  @override
  @JsonKey()
  final String bio;
  final List<String> _interests;
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  final List<String> _photoUrls;
  @override
  @JsonKey()
  List<String> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

  @override
  @JsonKey()
  final double currentBlurLevel;
  // 0.0 (clear) to 1.0 (max blur)
  @override
  @JsonKey()
  final String vibePrompt;
  @override
  @JsonKey()
  final String vibeAnswer;
  @override
  @JsonKey()
  final String globalIntentPreference;
  @override
  @JsonKey()
  final int exposureCount;
  @override
  final DateTime? lastShownTimestamp;

  @override
  String toString() {
    return 'ProfileCardModel(id: $id, name: $name, age: $age, university: $university, major: $major, primaryIntent: $primaryIntent, bio: $bio, interests: $interests, photoUrls: $photoUrls, currentBlurLevel: $currentBlurLevel, vibePrompt: $vibePrompt, vibeAnswer: $vibeAnswer, globalIntentPreference: $globalIntentPreference, exposureCount: $exposureCount, lastShownTimestamp: $lastShownTimestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileCardModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.university, university) ||
                other.university == university) &&
            (identical(other.major, major) || other.major == major) &&
            (identical(other.primaryIntent, primaryIntent) ||
                other.primaryIntent == primaryIntent) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality().equals(
              other._interests,
              _interests,
            ) &&
            const DeepCollectionEquality().equals(
              other._photoUrls,
              _photoUrls,
            ) &&
            (identical(other.currentBlurLevel, currentBlurLevel) ||
                other.currentBlurLevel == currentBlurLevel) &&
            (identical(other.vibePrompt, vibePrompt) ||
                other.vibePrompt == vibePrompt) &&
            (identical(other.vibeAnswer, vibeAnswer) ||
                other.vibeAnswer == vibeAnswer) &&
            (identical(other.globalIntentPreference, globalIntentPreference) ||
                other.globalIntentPreference == globalIntentPreference) &&
            (identical(other.exposureCount, exposureCount) ||
                other.exposureCount == exposureCount) &&
            (identical(other.lastShownTimestamp, lastShownTimestamp) ||
                other.lastShownTimestamp == lastShownTimestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    age,
    university,
    major,
    primaryIntent,
    bio,
    const DeepCollectionEquality().hash(_interests),
    const DeepCollectionEquality().hash(_photoUrls),
    currentBlurLevel,
    vibePrompt,
    vibeAnswer,
    globalIntentPreference,
    exposureCount,
    lastShownTimestamp,
  );

  /// Create a copy of ProfileCardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileCardModelImplCopyWith<_$ProfileCardModelImpl> get copyWith =>
      __$$ProfileCardModelImplCopyWithImpl<_$ProfileCardModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileCardModelImplToJson(this);
  }
}

abstract class _ProfileCardModel implements ProfileCardModel {
  const factory _ProfileCardModel({
    required final String id,
    required final String name,
    required final int age,
    required final String university,
    required final String major,
    required final String primaryIntent,
    final String bio,
    final List<String> interests,
    final List<String> photoUrls,
    final double currentBlurLevel,
    final String vibePrompt,
    final String vibeAnswer,
    final String globalIntentPreference,
    final int exposureCount,
    final DateTime? lastShownTimestamp,
  }) = _$ProfileCardModelImpl;

  factory _ProfileCardModel.fromJson(Map<String, dynamic> json) =
      _$ProfileCardModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get age;
  @override
  String get university;
  @override
  String get major;
  @override
  String get primaryIntent; // e.g., 'romance', 'friendship'
  @override
  String get bio;
  @override
  List<String> get interests;
  @override
  List<String> get photoUrls;
  @override
  double get currentBlurLevel; // 0.0 (clear) to 1.0 (max blur)
  @override
  String get vibePrompt;
  @override
  String get vibeAnswer;
  @override
  String get globalIntentPreference;
  @override
  int get exposureCount;
  @override
  DateTime? get lastShownTimestamp;

  /// Create a copy of ProfileCardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileCardModelImplCopyWith<_$ProfileCardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

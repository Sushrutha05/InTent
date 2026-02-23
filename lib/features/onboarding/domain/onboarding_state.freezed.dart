// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OnboardingState _$OnboardingStateFromJson(Map<String, dynamic> json) {
  return _OnboardingState.fromJson(json);
}

/// @nodoc
mixin _$OnboardingState {
  int get currentStep => throw _privateConstructorUsedError;
  UserIntent? get primaryIntent => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String? get university => throw _privateConstructorUsedError;
  String? get major => throw _privateConstructorUsedError;
  List<String> get interests => throw _privateConstructorUsedError;
  List<String> get localPhotoPaths => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this OnboardingState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingStateCopyWith<OnboardingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
    OnboardingState value,
    $Res Function(OnboardingState) then,
  ) = _$OnboardingStateCopyWithImpl<$Res, OnboardingState>;
  @useResult
  $Res call({
    int currentStep,
    UserIntent? primaryIntent,
    String? name,
    DateTime? dateOfBirth,
    String? university,
    String? major,
    List<String> interests,
    List<String> localPhotoPaths,
    bool isSubmitting,
    String? error,
  });
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res, $Val extends OnboardingState>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? primaryIntent = freezed,
    Object? name = freezed,
    Object? dateOfBirth = freezed,
    Object? university = freezed,
    Object? major = freezed,
    Object? interests = null,
    Object? localPhotoPaths = null,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentStep:
                null == currentStep
                    ? _value.currentStep
                    : currentStep // ignore: cast_nullable_to_non_nullable
                        as int,
            primaryIntent:
                freezed == primaryIntent
                    ? _value.primaryIntent
                    : primaryIntent // ignore: cast_nullable_to_non_nullable
                        as UserIntent?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            dateOfBirth:
                freezed == dateOfBirth
                    ? _value.dateOfBirth
                    : dateOfBirth // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            university:
                freezed == university
                    ? _value.university
                    : university // ignore: cast_nullable_to_non_nullable
                        as String?,
            major:
                freezed == major
                    ? _value.major
                    : major // ignore: cast_nullable_to_non_nullable
                        as String?,
            interests:
                null == interests
                    ? _value.interests
                    : interests // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            localPhotoPaths:
                null == localPhotoPaths
                    ? _value.localPhotoPaths
                    : localPhotoPaths // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            isSubmitting:
                null == isSubmitting
                    ? _value.isSubmitting
                    : isSubmitting // ignore: cast_nullable_to_non_nullable
                        as bool,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnboardingStateImplCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory _$$OnboardingStateImplCopyWith(
    _$OnboardingStateImpl value,
    $Res Function(_$OnboardingStateImpl) then,
  ) = __$$OnboardingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentStep,
    UserIntent? primaryIntent,
    String? name,
    DateTime? dateOfBirth,
    String? university,
    String? major,
    List<String> interests,
    List<String> localPhotoPaths,
    bool isSubmitting,
    String? error,
  });
}

/// @nodoc
class __$$OnboardingStateImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingStateImpl>
    implements _$$OnboardingStateImplCopyWith<$Res> {
  __$$OnboardingStateImplCopyWithImpl(
    _$OnboardingStateImpl _value,
    $Res Function(_$OnboardingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? primaryIntent = freezed,
    Object? name = freezed,
    Object? dateOfBirth = freezed,
    Object? university = freezed,
    Object? major = freezed,
    Object? interests = null,
    Object? localPhotoPaths = null,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(
      _$OnboardingStateImpl(
        currentStep:
            null == currentStep
                ? _value.currentStep
                : currentStep // ignore: cast_nullable_to_non_nullable
                    as int,
        primaryIntent:
            freezed == primaryIntent
                ? _value.primaryIntent
                : primaryIntent // ignore: cast_nullable_to_non_nullable
                    as UserIntent?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        dateOfBirth:
            freezed == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        university:
            freezed == university
                ? _value.university
                : university // ignore: cast_nullable_to_non_nullable
                    as String?,
        major:
            freezed == major
                ? _value.major
                : major // ignore: cast_nullable_to_non_nullable
                    as String?,
        interests:
            null == interests
                ? _value._interests
                : interests // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        localPhotoPaths:
            null == localPhotoPaths
                ? _value._localPhotoPaths
                : localPhotoPaths // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        isSubmitting:
            null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                    as bool,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OnboardingStateImpl implements _OnboardingState {
  const _$OnboardingStateImpl({
    this.currentStep = 0,
    this.primaryIntent,
    this.name,
    this.dateOfBirth,
    this.university,
    this.major,
    final List<String> interests = const [],
    final List<String> localPhotoPaths = const [],
    this.isSubmitting = false,
    this.error,
  }) : _interests = interests,
       _localPhotoPaths = localPhotoPaths;

  factory _$OnboardingStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnboardingStateImplFromJson(json);

  @override
  @JsonKey()
  final int currentStep;
  @override
  final UserIntent? primaryIntent;
  @override
  final String? name;
  @override
  final DateTime? dateOfBirth;
  @override
  final String? university;
  @override
  final String? major;
  final List<String> _interests;
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  final List<String> _localPhotoPaths;
  @override
  @JsonKey()
  List<String> get localPhotoPaths {
    if (_localPhotoPaths is EqualUnmodifiableListView) return _localPhotoPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localPhotoPaths);
  }

  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? error;

  @override
  String toString() {
    return 'OnboardingState(currentStep: $currentStep, primaryIntent: $primaryIntent, name: $name, dateOfBirth: $dateOfBirth, university: $university, major: $major, interests: $interests, localPhotoPaths: $localPhotoPaths, isSubmitting: $isSubmitting, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.primaryIntent, primaryIntent) ||
                other.primaryIntent == primaryIntent) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.university, university) ||
                other.university == university) &&
            (identical(other.major, major) || other.major == major) &&
            const DeepCollectionEquality().equals(
              other._interests,
              _interests,
            ) &&
            const DeepCollectionEquality().equals(
              other._localPhotoPaths,
              _localPhotoPaths,
            ) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentStep,
    primaryIntent,
    name,
    dateOfBirth,
    university,
    major,
    const DeepCollectionEquality().hash(_interests),
    const DeepCollectionEquality().hash(_localPhotoPaths),
    isSubmitting,
    error,
  );

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      __$$OnboardingStateImplCopyWithImpl<_$OnboardingStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OnboardingStateImplToJson(this);
  }
}

abstract class _OnboardingState implements OnboardingState {
  const factory _OnboardingState({
    final int currentStep,
    final UserIntent? primaryIntent,
    final String? name,
    final DateTime? dateOfBirth,
    final String? university,
    final String? major,
    final List<String> interests,
    final List<String> localPhotoPaths,
    final bool isSubmitting,
    final String? error,
  }) = _$OnboardingStateImpl;

  factory _OnboardingState.fromJson(Map<String, dynamic> json) =
      _$OnboardingStateImpl.fromJson;

  @override
  int get currentStep;
  @override
  UserIntent? get primaryIntent;
  @override
  String? get name;
  @override
  DateTime? get dateOfBirth;
  @override
  String? get university;
  @override
  String? get major;
  @override
  List<String> get interests;
  @override
  List<String> get localPhotoPaths;
  @override
  bool get isSubmitting;
  @override
  String? get error;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

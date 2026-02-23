import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_card_model.freezed.dart';
part 'profile_card_model.g.dart';

@freezed
class ProfileCardModel with _$ProfileCardModel {
  const factory ProfileCardModel({
    required String id,
    required String name,
    required int age,
    required String university,
    required String major,
    required String primaryIntent, // e.g., 'romance', 'friendship'
    @Default('') String bio,
    @Default([]) List<String> interests,
    @Default([]) List<String> photoUrls,
    @Default(0.0) double currentBlurLevel, // 0.0 (clear) to 1.0 (max blur)
    @Default('') String vibePrompt,
    @Default('') String vibeAnswer,
    @Default('friendship') String globalIntentPreference,
    @Default(0) int exposureCount,
    DateTime? lastShownTimestamp,
  }) = _ProfileCardModel;

  factory ProfileCardModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileCardModelFromJson(json);
}

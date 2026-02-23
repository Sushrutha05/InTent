import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';

part 'intent_model.freezed.dart';
part 'intent_model.g.dart';

@freezed
class IntentModel with _$IntentModel {
  const factory IntentModel({
    required String id,
    required String actorId,
    required String targetId,
    required String actionType,
    required DateTime createdAt,
    required ProfileCardModel targetProfile,
    String? swipeReason,
  }) = _IntentModel;

  factory IntentModel.fromJson(Map<String, dynamic> json) =>
      _$IntentModelFromJson(json);
}

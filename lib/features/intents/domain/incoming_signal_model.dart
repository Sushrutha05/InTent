import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';

class IncomingSignal {
  final String interactionId;
  final String senderId;
  final DateTime createdAt;
  final ProfileCardModel profile;
  final String hiddenIntent; // 'ROMANTIC', 'FRIENDSHIP', or 'COLLABORATE'

  const IncomingSignal({
    required this.interactionId,
    required this.senderId,
    required this.createdAt,
    required this.profile,
    required this.hiddenIntent,
  });

  bool matchesIntent(String myIntent) {
    return hiddenIntent.toUpperCase() == myIntent.toUpperCase();
  }
}

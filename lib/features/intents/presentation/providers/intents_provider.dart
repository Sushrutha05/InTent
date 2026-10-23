import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/features/intents/data/intents_repository.dart';
import 'package:student_dating_app/features/intents/domain/intent_model.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';

import 'package:student_dating_app/features/intents/domain/incoming_signal_model.dart';

part 'intents_provider.g.dart';

final incomingSignalsProvider = FutureProvider<List<IncomingSignal>>((ref) async {
  ref.watch(authProvider);
  return ref.read(intentsRepositoryProvider).getIncomingSignals();
});

@riverpod
class IntentsNotifier extends _$IntentsNotifier {
  @override
  Future<List<IntentModel>> build() async {
    ref.watch(authProvider);

    return ref.read(intentsRepositoryProvider).getSentIntents();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(intentsRepositoryProvider).getSentIntents(),
    );
  }

  Future<bool> respondToSignal(IncomingSignal signal, String myIntent) async {
    final isMatch = await ref.read(intentsRepositoryProvider).respondToSignal(
      signal: signal,
      myIntent: myIntent,
    );
    ref.invalidate(incomingSignalsProvider);
    refresh();
    return isMatch;
  }

  List<IntentModel> get romanticProfiles {
    if (state.value == null) return [];
    return state.value!
        .where((intent) => intent.actionType == 'ROMANTIC')
        .toList();
  }

  List<IntentModel> get friendshipProfiles {
    if (state.value == null) return [];
    return state.value!
        .where((intent) => intent.actionType == 'FRIENDSHIP')
        .toList();
  }

  List<IntentModel> get collaborateProfiles {
    if (state.value == null) return [];
    return state.value!
        .where((intent) => intent.actionType == 'COLLABORATE')
        .toList();
  }
}

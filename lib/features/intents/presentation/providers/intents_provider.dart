import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/features/intents/data/intents_repository.dart';
import 'package:student_dating_app/features/intents/domain/intent_model.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';

part 'intents_provider.g.dart';

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

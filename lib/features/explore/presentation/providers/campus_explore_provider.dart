import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_dating_app/features/explore/data/campus_explore_repository.dart';
import 'package:student_dating_app/features/explore/domain/campus_spot_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final campusExploreRepositoryProvider = Provider<CampusExploreRepository>((ref) {
  return CampusExploreRepository();
});

final campusSpotsProvider = FutureProvider<List<CampusSpot>>((ref) async {
  final repo = ref.watch(campusExploreRepositoryProvider);
  return repo.getSpots();
});

final currentUserCheckInProvider = FutureProvider<SpotCheckIn?>((ref) async {
  final repo = ref.watch(campusExploreRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  return repo.getCurrentUserCheckIn(userId);
});

final spotCheckInsProvider = FutureProvider.family<List<SpotCheckIn>, String>((ref, spotId) async {
  final repo = ref.watch(campusExploreRepositoryProvider);
  return repo.getCheckInsForSpot(spotId);
});

class CampusExploreController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  CampusExploreController(this._ref) : super(const AsyncValue.data(null));

  Future<void> checkIn({
    required String spotId,
    required String vibeStatus,
    int durationHours = 2,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(campusExploreRepositoryProvider);
      await repo.checkIn(
        spotId: spotId,
        vibeStatus: vibeStatus,
        durationHours: durationHours,
      );
      _ref.invalidate(campusSpotsProvider);
      _ref.invalidate(currentUserCheckInProvider);
      _ref.invalidate(spotCheckInsProvider(spotId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> checkOut() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(campusExploreRepositoryProvider);
      await repo.checkOut();
      _ref.invalidate(campusSpotsProvider);
      _ref.invalidate(currentUserCheckInProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void refresh() {
    _ref.invalidate(campusSpotsProvider);
    _ref.invalidate(currentUserCheckInProvider);
  }
}

final campusExploreControllerProvider =
    StateNotifierProvider<CampusExploreController, AsyncValue<void>>((ref) {
  return CampusExploreController(ref);
});

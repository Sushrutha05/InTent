import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_dating_app/features/explore/domain/campus_spot_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CampusExploreRepository {
  static const String _checkInsKey = 'campus_explore_checkins_v1';

  final List<CampusSpot> _defaultSpots = const [
    CampusSpot(
      id: 'spot_library',
      name: 'Main Campus Library',
      building: 'William T. Young Library',
      description: 'Silent floors, late night coffee bar, and study pods.',
      category: SpotCategory.study,
      icon: Icons.local_library_rounded,
      themeColor: Color(0xFF3B82F6),
    ),
    CampusSpot(
      id: 'spot_union',
      name: 'Student Union & Commons',
      building: 'Gatton Student Center',
      description: 'Food court, campus radio lounge, game tables, and social hubs.',
      category: SpotCategory.social,
      icon: Icons.groups_rounded,
      themeColor: Color(0xFFEC4899),
    ),
    CampusSpot(
      id: 'spot_quad',
      name: 'Central Lawn & Quad',
      building: 'North Campus Greens',
      description: 'Hammocks, outdoor study circles, frisbee, and sunshine.',
      category: SpotCategory.outdoor,
      icon: Icons.park_rounded,
      themeColor: Color(0xFF10B981),
    ),
    CampusSpot(
      id: 'spot_gym',
      name: 'Campus Rec & Fitness Center',
      building: 'Alumni Recreation Center',
      description: 'Weight rooms, indoor track, bouldering wall, and courts.',
      category: SpotCategory.fitness,
      icon: Icons.fitness_center_rounded,
      themeColor: Color(0xFFF59E0B),
    ),
    CampusSpot(
      id: 'spot_cafe',
      name: 'Common Grounds Cafe',
      building: 'Student Arts Annex',
      description: 'Artisan matcha, cold brew, cozy armchairs, and acoustic playlists.',
      category: SpotCategory.lounge,
      icon: Icons.coffee_rounded,
      themeColor: Color(0xFF8B5CF6),
    ),
    CampusSpot(
      id: 'spot_stem',
      name: 'Engineering & Innovation Labs',
      building: 'Marksbury STEM Complex',
      description: 'Makerspaces, 3D printers, coding pods, and high-energy hack vibes.',
      category: SpotCategory.study,
      icon: Icons.biotech_rounded,
      themeColor: Color(0xFF06B6D4),
    ),
  ];

  Future<List<CampusSpot>> getSpots() async {
    final checkIns = await _getAllValidCheckIns();
    return _defaultSpots.map((spot) {
      final count = checkIns.where((c) => c.spotId == spot.id).length;
      return spot.copyWith(activeCheckIns: count);
    }).toList();
  }

  Future<List<SpotCheckIn>> getCheckInsForSpot(String spotId) async {
    final checkIns = await _getAllValidCheckIns();
    return checkIns.where((c) => c.spotId == spotId).toList();
  }

  Future<SpotCheckIn?> getCurrentUserCheckIn(String userId) async {
    final checkIns = await _getAllValidCheckIns();
    try {
      return checkIns.firstWhere((c) => c.userId == userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> checkIn({
    required String spotId,
    required String vibeStatus,
    int durationHours = 2,
  }) async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    // Fetch user profile info
    String userName = 'Student';
    String userUniversity = 'Campus';
    String userMajor = 'Undeclared';
    String? userPhoto;
    String userIntent = 'friendship';

    try {
      final profile = await supabase
          .from('profiles')
          .select('first_name, university, major, photo_urls, primary_intent')
          .eq('id', currentUser.id)
          .maybeSingle();

      if (profile != null) {
        userName = profile['first_name'] as String? ?? 'Student';
        userUniversity = profile['university'] as String? ?? 'Campus';
        userMajor = profile['major'] as String? ?? '';
        final photos = profile['photo_urls'] as List<dynamic>?;
        if (photos != null && photos.isNotEmpty) {
          userPhoto = photos.first.toString();
        }
        userIntent = profile['primary_intent'] as String? ?? 'friendship';
      }
    } catch (_) {}

    final now = DateTime.now();
    final checkIn = SpotCheckIn(
      id: 'checkin_${currentUser.id}_${now.millisecondsSinceEpoch}',
      spotId: spotId,
      userId: currentUser.id,
      userName: userName,
      userUniversity: userUniversity,
      userMajor: userMajor,
      userPhotoUrl: userPhoto,
      userIntent: userIntent,
      vibeStatus: vibeStatus,
      checkedInAt: now,
      expiresAt: now.add(Duration(hours: durationHours)),
    );

    final checkIns = await _getAllValidCheckIns();
    // Remove any existing check-in for this user
    checkIns.removeWhere((c) => c.userId == currentUser.id);
    checkIns.add(checkIn);

    await _saveCheckIns(checkIns);
  }

  Future<void> checkOut() async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    final checkIns = await _getAllValidCheckIns();
    checkIns.removeWhere((c) => c.userId == currentUser.id);
    await _saveCheckIns(checkIns);
  }

  Future<List<SpotCheckIn>> _getAllValidCheckIns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_checkInsKey) ?? [];
      final now = DateTime.now();

      final List<SpotCheckIn> valid = [];
      for (final jsonStr in raw) {
        try {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          final checkIn = SpotCheckIn.fromMap(map);
          if (now.isBefore(checkIn.expiresAt)) {
            valid.add(checkIn);
          }
        } catch (_) {}
      }

      return valid;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveCheckIns(List<SpotCheckIn> checkIns) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = checkIns.map((c) => jsonEncode(c.toMap())).toList();
      await prefs.setStringList(_checkInsKey, list);
    } catch (e) {
      debugPrint('Error saving check-ins: $e');
    }
  }
}

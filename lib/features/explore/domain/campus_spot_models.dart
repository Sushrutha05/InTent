import 'package:flutter/material.dart';

enum SpotCategory {
  study,
  social,
  fitness,
  lounge,
  outdoor,
}

class CampusSpot {
  final String id;
  final String name;
  final String building;
  final String description;
  final SpotCategory category;
  final IconData icon;
  final Color themeColor;
  final int activeCheckIns;

  const CampusSpot({
    required this.id,
    required this.name,
    required this.building,
    required this.description,
    required this.category,
    required this.icon,
    required this.themeColor,
    this.activeCheckIns = 0,
  });

  CampusSpot copyWith({int? activeCheckIns}) {
    return CampusSpot(
      id: id,
      name: name,
      building: building,
      description: description,
      category: category,
      icon: icon,
      themeColor: themeColor,
      activeCheckIns: activeCheckIns ?? this.activeCheckIns,
    );
  }
}

class SpotCheckIn {
  final String id;
  final String spotId;
  final String userId;
  final String userName;
  final String userUniversity;
  final String userMajor;
  final String? userPhotoUrl;
  final String userIntent;
  final String vibeStatus;
  final DateTime checkedInAt;
  final DateTime expiresAt;

  const SpotCheckIn({
    required this.id,
    required this.spotId,
    required this.userId,
    required this.userName,
    required this.userUniversity,
    required this.userMajor,
    this.userPhotoUrl,
    required this.userIntent,
    required this.vibeStatus,
    required this.checkedInAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'spot_id': spotId,
      'user_id': userId,
      'user_name': userName,
      'user_university': userUniversity,
      'user_major': userMajor,
      'user_photo_url': userPhotoUrl,
      'user_intent': userIntent,
      'vibe_status': vibeStatus,
      'checked_in_at': checkedInAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  factory SpotCheckIn.fromMap(Map<String, dynamic> map) {
    return SpotCheckIn(
      id: map['id'] as String? ?? '',
      spotId: map['spot_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      userName: map['user_name'] as String? ?? 'Student',
      userUniversity: map['user_university'] as String? ?? '',
      userMajor: map['user_major'] as String? ?? '',
      userPhotoUrl: map['user_photo_url'] as String?,
      userIntent: map['user_intent'] as String? ?? 'friendship',
      vibeStatus: map['vibe_status'] as String? ?? 'Hanging out',
      checkedInAt: DateTime.parse(map['checked_in_at'] as String),
      expiresAt: DateTime.parse(map['expires_at'] as String),
    );
  }
}

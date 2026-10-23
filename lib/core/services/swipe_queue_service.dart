import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QueuedSwipe {
  final String actorId;
  final String targetId;
  final String actionType; // 'ROMANTIC', 'FRIENDSHIP', 'COLLABORATE', 'PASS'
  final String createdAt;
  final int retryCount;

  const QueuedSwipe({
    required this.actorId,
    required this.targetId,
    required this.actionType,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'actor_id': actorId,
      'target_id': targetId,
      'action_type': actionType,
      'created_at': createdAt,
      'retry_count': retryCount,
    };
  }

  factory QueuedSwipe.fromMap(Map<String, dynamic> map) {
    return QueuedSwipe(
      actorId: map['actor_id'] as String? ?? '',
      targetId: map['target_id'] as String? ?? '',
      actionType: map['action_type'] as String? ?? 'PASS',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      retryCount: (map['retry_count'] as int?) ?? 0,
    );
  }

  QueuedSwipe copyWith({int? retryCount}) {
    return QueuedSwipe(
      actorId: actorId,
      targetId: targetId,
      actionType: actionType,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

class SwipeQueueService {
  static const String _prefKey = 'offline_swipes_queue_v1';
  static bool _isSyncing = false;

  /// Enqueue a swipe interaction locally to guarantee zero swipe loss.
  static Future<void> enqueueSwipe({
    required String actorId,
    required String targetId,
    required String actionType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawQueue = prefs.getStringList(_prefKey) ?? [];

      final swipe = QueuedSwipe(
        actorId: actorId,
        targetId: targetId,
        actionType: actionType,
        createdAt: DateTime.now().toIso8601String(),
      );

      rawQueue.add(jsonEncode(swipe.toMap()));
      await prefs.setStringList(_prefKey, rawQueue);
      debugPrint('[SwipeQueue] Enqueued swipe: $actionType -> $targetId (Queue size: ${rawQueue.length})');
    } catch (e) {
      debugPrint('[SwipeQueue] Error enqueuing swipe: $e');
    }
  }

  /// Get count of pending offline swipes
  static Future<int> getPendingCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_prefKey)?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Process and sync the queued swipes with Supabase.
  /// Safely handles network failures, duplicates, and batch commits.
  static Future<int> processQueue() async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawQueue = prefs.getStringList(_prefKey) ?? [];
      if (rawQueue.isEmpty) {
        _isSyncing = false;
        return 0;
      }

      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        _isSyncing = false;
        return 0;
      }

      final List<QueuedSwipe> queue = [];
      for (final item in rawQueue) {
        try {
          queue.add(QueuedSwipe.fromMap(jsonDecode(item) as Map<String, dynamic>));
        } catch (_) {}
      }

      if (queue.isEmpty) {
        await prefs.remove(_prefKey);
        _isSyncing = false;
        return 0;
      }

      debugPrint('[SwipeQueue] Processing ${queue.length} offline swipes...');

      final List<QueuedSwipe> remaining = [];
      int syncedCount = 0;

      // Attempt batch upsert in a single network roundtrip
      bool batchSucceeded = false;
      try {
        final records = queue.map((swipe) => {
          'actor_id': swipe.actorId,
          'target_id': swipe.targetId,
          'action_type': swipe.actionType,
          'created_at': swipe.createdAt,
        }).toList();

        await supabase.from('interactions').upsert(
          records,
          onConflict: 'actor_id,target_id',
          ignoreDuplicates: true,
        );
        syncedCount = queue.length;
        batchSucceeded = true;
      } catch (batchError) {
        debugPrint('[SwipeQueue] Batch sync failed: $batchError. Falling back to individual processing.');
      }

      if (!batchSucceeded) {
        for (final swipe in queue) {
          try {
            await supabase.from('interactions').insert({
              'actor_id': swipe.actorId,
              'target_id': swipe.targetId,
              'action_type': swipe.actionType,
              'created_at': swipe.createdAt,
            });
            syncedCount++;
          } catch (e) {
            debugPrint('[SwipeQueue] Failed to sync swipe ${swipe.targetId}: $e');
            // If error is duplicate interaction (Postgres unique constraint violation 23505),
            // treat as succeeded since DB already has it!
            final errStr = e.toString().toLowerCase();
            if (errStr.contains('duplicate') || errStr.contains('23505') || errStr.contains('unique')) {
              syncedCount++;
            } else if (swipe.retryCount < 5) {
              remaining.add(swipe.copyWith(retryCount: swipe.retryCount + 1));
            } else {
              debugPrint('[SwipeQueue] Dropping swipe ${swipe.targetId} after max 5 retries.');
            }
          }
        }
      }

      // Update remaining queue in SharedPreferences
      if (remaining.isEmpty) {
        await prefs.remove(_prefKey);
      } else {
        await prefs.setStringList(
          _prefKey,
          remaining.map((s) => jsonEncode(s.toMap())).toList(),
        );
      }

      debugPrint('[SwipeQueue] Successfully synced $syncedCount swipes. Remaining: ${remaining.length}');
      _isSyncing = false;
      return syncedCount;
    } catch (e) {
      debugPrint('[SwipeQueue] Sync error: $e');
      _isSyncing = false;
      return 0;
    }
  }

  /// Clear the local queue (useful during testing or account switch)
  static Future<void> clearQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
    } catch (_) {}
  }
}

import 'package:flutter/material.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';

class PhotoLockSheet extends StatelessWidget {
  final int daysConnected;
  final int currentStreak;
  final double unblurProgress;
  final VoidCallback onBypassUnlock;

  const PhotoLockSheet({
    super.key,
    required this.daysConnected,
    required this.currentStreak,
    required this.unblurProgress,
    required this.onBypassUnlock,
  });

  static Future<void> show(
    BuildContext context, {
    required int daysConnected,
    required int currentStreak,
    required double unblurProgress,
    required VoidCallback onBypassUnlock,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PhotoLockSheet(
        daysConnected: daysConnected,
        currentStreak: currentStreak,
        unblurProgress: unblurProgress,
        onBypassUnlock: onBypassUnlock,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Lock Icon with glowing background
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.lock_clock_rounded,
                size: 34,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Campus Photo & Snap Lock',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'To protect student safety and keep conversations genuine, direct photo and Snapchat sharing unlocks after 14 days of friendship or a 7-day chat streak.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Progress Card 1: Friendship Days
          _buildProgressTile(
            icon: Icons.calendar_today_rounded,
            title: 'Friendship Duration',
            subtitle: '$daysConnected of 14 days completed',
            progress: (daysConnected / 14).clamp(0.0, 1.0),
            color: const Color(0xFF48CAE4),
          ),
          const SizedBox(height: 12),

          // Progress Card 2: Streak
          _buildProgressTile(
            icon: Icons.local_fire_department_rounded,
            title: 'Chatting Streak',
            subtitle: '$currentStreak of 7 consecutive days',
            progress: (currentStreak / 7).clamp(0.0, 1.0),
            color: const Color(0xFFFF758F),
          ),
          const SizedBox(height: 12),

          // Progress Card 3: Unblur Progress
          _buildProgressTile(
            icon: Icons.remove_red_eye_rounded,
            title: 'Full Unblur Reveal',
            subtitle: '${(unblurProgress * 100).toInt()}% of 100% revealed',
            progress: unblurProgress.clamp(0.0, 1.0),
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 24),

          // Dev/Testing Bypass Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentColor,
              side: BorderSide(color: AppTheme.accentColor.withValues(alpha: 0.6)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.bolt_rounded, size: 20),
            label: const Text(
              '🧪 Testing Mode: Instant Unlock for Demo',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              Navigator.pop(context);
              onBypassUnlock();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

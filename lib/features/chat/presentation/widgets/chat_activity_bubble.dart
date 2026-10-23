import 'package:flutter/material.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/chat/domain/chat_activity_model.dart';

class ChatActivityBubble extends StatelessWidget {
  final ChatActivity activity;
  final String messageId;
  final String matchId;
  final String currentUserId;
  final void Function(int selectedIndex)? onGuessLie;
  final void Function(String choice)? onVoteWouldYouRather;

  const ChatActivityBubble({
    super.key,
    required this.activity,
    required this.messageId,
    required this.matchId,
    required this.currentUserId,
    this.onGuessLie,
    this.onVoteWouldYouRather,
  });

  bool get isCreator => activity.creatorId == currentUserId;

  @override
  Widget build(BuildContext context) {
    switch (activity.type) {
      case ActivityType.twoTruthsAndLie:
        return _buildTwoTruthsCard(context);
      case ActivityType.wouldYouRather:
        return _buildWouldYouRatherCard(context);
      case ActivityType.icebreaker:
        return _buildIcebreakerCard(context);
    }
  }

  Widget _buildTwoTruthsCard(BuildContext context) {
    final guessedIndex = activity.responses['guessedIndex'] as int?;
    final isCorrect = guessedIndex != null && guessedIndex == activity.correctIndex;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activity.isCompleted
              ? AppTheme.primaryColor.withValues(alpha: 0.5)
              : AppTheme.dividerColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      isCreator ? 'You challenged your match' : 'Spot the LIE to accelerate blur!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF6366F1)),
                    SizedBox(width: 2),
                    Text(
                      '+25% Unblur',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Options / Statements
          ...List.generate(activity.options.length, (index) {
            final statement = activity.options[index];
            final bool isLie = activity.correctIndex == index;
            final bool wasGuessed = guessedIndex == index;

            Color tileColor = AppTheme.backgroundColor;
            BorderSide border = BorderSide(color: AppTheme.dividerColor.withValues(alpha: 0.6));
            Widget? trailingIcon;

            if (activity.isCompleted) {
              if (isLie) {
                tileColor = const Color(0xFFFEF2F2);
                border = const BorderSide(color: Color(0xFFEF4444), width: 1.5);
                trailingIcon = const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18);
              } else if (wasGuessed && !isLie) {
                tileColor = const Color(0xFFFEF3C7);
                border = const BorderSide(color: Color(0xFFF59E0B), width: 1.5);
                trailingIcon = const Icon(Icons.help_outline_rounded, color: Color(0xFFF59E0B), size: 18);
              } else {
                tileColor = const Color(0xFFF0FDF4);
                trailingIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 18);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Material(
                color: tileColor,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: (!activity.isCompleted && !isCreator && onGuessLie != null)
                      ? () => onGuessLie!(index)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.fromBorderSide(border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            statement,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // Footer status
          const SizedBox(height: 6),
          if (!activity.isCompleted)
            isCreator
                ? const Text(
                    '⏳ Waiting for your match to guess which one is the lie...',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
                  )
                : const Text(
                    '👉 Tap the statement you think is the LIE!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.celebration_rounded : Icons.sentiment_dissatisfied_rounded,
                    size: 16,
                    color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isCorrect
                          ? '🎉 Lie spotted correctly! +25% Unblur Boost Applied!'
                          : '😈 Fooled! The lie was revealed! +25% Unblur Boost Applied!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWouldYouRatherCard(BuildContext context) {
    final myChoice = activity.responses[currentUserId] as String?;
    final otherChoice = activity.responses.entries
        .firstWhere((e) => e.key != currentUserId, orElse: () => const MapEntry('', null))
        .value as String?;

    final bool isBothVoted = activity.responses.length >= 2 || activity.isCompleted;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.balance_rounded, color: Color(0xFFF59E0B), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Campus Would You Rather?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '+15% Unblur',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activity.prompt ?? 'Which would you choose?',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),

          // Options A and B
          if (activity.options.length >= 2) ...[
            _buildWyrOptionTile(
              label: 'A',
              text: activity.options[0],
              isSelected: myChoice == 'A',
              showOtherVote: isBothVoted && otherChoice == 'A',
              onTap: myChoice == null && onVoteWouldYouRather != null ? () => onVoteWouldYouRather!('A') : null,
            ),
            const SizedBox(height: 8),
            _buildWyrOptionTile(
              label: 'B',
              text: activity.options[1],
              isSelected: myChoice == 'B',
              showOtherVote: isBothVoted && otherChoice == 'B',
              onTap: myChoice == null && onVoteWouldYouRather != null ? () => onVoteWouldYouRather!('B') : null,
            ),
          ],

          const SizedBox(height: 8),
          if (!isBothVoted && myChoice != null)
            const Text(
              '⏳ Voted! Waiting for your match to vote to reveal answers...',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
            )
          else if (isBothVoted)
            Text(
              myChoice == otherChoice ? '✨ You both chose the same! True resonance!' : '😄 Different vibes! Great convo starter!',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
        ],
      ),
    );
  }

  Widget _buildWyrOptionTile({
    required String label,
    required String text,
    required bool isSelected,
    required bool showOtherVote,
    VoidCallback? onTap,
  }) {
    return Material(
      color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                '$label: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 18),
              if (showOtherVote)
                const Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(Icons.favorite_rounded, color: Colors.pinkAccent, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcebreakerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: Color(0xFF7C3AED), size: 20),
              SizedBox(width: 8),
              Text(
                'Icebreaker Spark',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activity.prompt ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

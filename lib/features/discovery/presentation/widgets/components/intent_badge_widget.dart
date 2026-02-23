import 'package:flutter/material.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';

class IntentBadgeWidget extends StatelessWidget {
  final String intent;

  const IntentBadgeWidget({super.key, required this.intent});

  @override
  Widget build(BuildContext context) {
    Color badgeColor = AppTheme.primaryColor.withValues(alpha: 0.15);
    Color textColor = AppTheme.primaryColor;

    final lowerIntent = intent.toLowerCase();
    if (lowerIntent == 'romantic') {
      badgeColor = Colors.pink.withValues(alpha: 0.15);
      textColor = Colors.pink;
    } else if (lowerIntent == 'collaborate') {
      badgeColor = Colors.blue.withValues(alpha: 0.15);
      textColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        intent.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

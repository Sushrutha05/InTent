import 'package:flutter/material.dart';

class PersonalityHookWidget extends StatelessWidget {
  final String prompt;
  final String answer;

  const PersonalityHookWidget({
    super.key,
    required this.prompt,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    if (prompt.isEmpty && answer.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prompt.isNotEmpty)
          Text(
            prompt,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (prompt.isNotEmpty && answer.isNotEmpty) const SizedBox(height: 6),
        if (answer.isNotEmpty)
          Text(
            '"$answer"',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
      ],
    );
  }
}

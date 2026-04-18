import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/onboarding/domain/onboarding_state.dart';
import 'package:student_dating_app/features/onboarding/presentation/providers/onboarding_provider.dart';

class IntentSelectionScreen extends ConsumerWidget {
  const IntentSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            index <= 0
                                ? AppTheme.primaryColor
                                : AppTheme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'What brings you here?',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 36, height: 1.2),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose your primary intent. This won\'t be visible as a badge on your profile and won\'t strictly limit who you can discover.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Intent Cards
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _IntentCard(
                      title: 'Romance',
                      description:
                          'Looking for a date, a partner, or to see where things go.',
                      icon: Icons.favorite_rounded,
                      color: AppTheme.primaryColor,
                      isSelected: state.primaryIntent == UserIntent.romance,
                      onTap: () => notifier.setIntent(UserIntent.romance),
                    ),
                    const SizedBox(height: 16),
                    _IntentCard(
                      title: 'Friendship',
                      description:
                          'Looking to meet new people and expand my social circle.',
                      icon: Icons.people_alt_rounded,
                      color: AppTheme.secondaryColor,
                      isSelected: state.primaryIntent == UserIntent.friendship,
                      onTap: () => notifier.setIntent(UserIntent.friendship),
                    ),
                    const SizedBox(height: 16),
                    _IntentCard(
                      title: 'Collaboration',
                      description:
                          'Looking for study buddies, project partners, or networking.',
                      icon: Icons.lightbulb_rounded,
                      color: AppTheme.accentColor,
                      isSelected:
                          state.primaryIntent == UserIntent.collaboration,
                      onTap: () => notifier.setIntent(UserIntent.collaboration),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    state.primaryIntent == null
                        ? null
                        : () {
                          notifier.nextStep();
                          context.push('/onboarding/info');
                        },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntentCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntentCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.15)
                  : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? color.withValues(alpha: 0.2)
                        : AppTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? color : AppTheme.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isSelected ? color : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

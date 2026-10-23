import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_dating_app/features/onboarding/domain/onboarding_state.dart';
import 'package:student_dating_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:student_dating_app/core/widgets/bouncy_button.dart';
import 'package:google_fonts/google_fonts.dart';

class IntentSelectionScreen extends ConsumerWidget {
  const IntentSelectionScreen({super.key});

  Future<void> _handleBack(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).logout();
    } catch (e) {
      debugPrint('Error logging out during onboarding back: $e');
    }
    ref.invalidate(onboardingNotifierProvider);
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => _handleBack(context, ref),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleBack(context, ref);
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
                const SizedBox(height: 24),

              Text(
                'What brings you here?',
                style: GoogleFonts.outfit(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  height: 1.2,
                  color: AppTheme.textPrimary,
                ),
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
                      color: AppTheme.intentRomantic,
                      isSelected: state.primaryIntent == UserIntent.romance,
                      onTap: () => notifier.setIntent(UserIntent.romance),
                    ),
                    const SizedBox(height: 16),
                    _IntentCard(
                      title: 'Friendship',
                      description:
                          'Looking to meet new people and expand my social circle.',
                      icon: Icons.people_alt_rounded,
                      color: AppTheme.intentFriendship,
                      isSelected: state.primaryIntent == UserIntent.friendship,
                      onTap: () => notifier.setIntent(UserIntent.friendship),
                    ),
                    const SizedBox(height: 16),
                    _IntentCard(
                      title: 'Collaboration',
                      description:
                          'Looking for study buddies, project partners, or networking.',
                      icon: Icons.bolt_rounded,
                      color: AppTheme.intentCollaborate,
                      isSelected:
                          state.primaryIntent == UserIntent.collaboration,
                      onTap: () => notifier.setIntent(UserIntent.collaboration),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              BouncyButton(
                onPressed: state.primaryIntent == null
                    ? () {} // Disabled state visually handled below
                    : () {
                        notifier.nextStep();
                        context.push('/onboarding/info');
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: state.primaryIntent == null
                        ? AppTheme.dividerColor
                        : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: state.primaryIntent == null
                        ? []
                        : [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: state.primaryIntent == null
                            ? AppTheme.textSecondary
                            : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    return BouncyButton(
      onPressed: onTap,
      scaleFactor: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.08)
                  : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : AppTheme.dividerColor.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                      color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
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

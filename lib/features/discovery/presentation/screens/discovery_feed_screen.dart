import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/discovery/presentation/providers/discovery_provider.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/interactive_swipe_card.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/empty_discovery_state.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:student_dating_app/core/widgets/shimmer_loading.dart';
import 'package:student_dating_app/features/intents/presentation/providers/intents_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoveryFeedScreen extends ConsumerStatefulWidget {
  const DiscoveryFeedScreen({super.key});

  @override
  ConsumerState<DiscoveryFeedScreen> createState() =>
      _DiscoveryFeedScreenState();
}

class _DiscoveryFeedScreenState extends ConsumerState<DiscoveryFeedScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(discoveryNotifierProvider);
    final currentFilter = ref.watch(discoveryFilterProvider);
    final incomingSignals = ref.watch(incomingSignalsProvider).value ?? [];
    final incomingSenderIds = incomingSignals.map((s) => s.senderId).toSet();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'InTent',
          style: GoogleFonts.outfit(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false, // Align branding to the left for a modern social media header
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/explore'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.explore_rounded, color: AppTheme.primaryColor, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Radar',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.dividerColor, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Container(
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSolid,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left:
                          currentFilter == InstitutionFilter.myInstitution
                              ? 0
                              : 100,
                      top: 0,
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap:
                                () =>
                                    ref
                                        .read(discoveryFilterProvider.notifier)
                                        .state = InstitutionFilter
                                            .myInstitution,
                            child: Center(
                                child: Text(
                                  'My Uni',
                                  style: TextStyle(
                                    color:
                                        currentFilter ==
                                                InstitutionFilter.myInstitution
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                    fontWeight:
                                        currentFilter ==
                                                InstitutionFilter.myInstitution
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap:
                                () =>
                                    ref
                                        .read(discoveryFilterProvider.notifier)
                                        .state = InstitutionFilter.all,
                            child: Center(
                              child: Text(
                                'All',
                                style: TextStyle(
                                  color:
                                      currentFilter == InstitutionFilter.all
                                          ? AppTheme.textPrimary
                                          : AppTheme.textSecondary,
                                  fontWeight:
                                      currentFilter == InstitutionFilter.all
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: discoveryState.when(
                loading: () => const DiscoverySkeleton(),
                error:
                    (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed:
                                () =>
                                    ref
                                        .read(
                                          discoveryNotifierProvider.notifier,
                                        )
                                        .refresh(),
                            child: const Text(
                              'Try Again',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                data: (swipeItems) {
                  if (swipeItems.isEmpty) {
                    return EmptyDiscoveryState(
                      onRefresh: () => ref.read(discoveryNotifierProvider.notifier).refresh(),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: CardSwiper(
                            controller: _swiperController,
                            cardsCount: swipeItems.length,
                            numberOfCardsDisplayed:
                                swipeItems.length > 1 ? 2 : 1,
                            scale: 0.95,
                            backCardOffset: const Offset(0, 15),
                            onEnd: () {
                              ref.read(discoveryNotifierProvider.notifier).refresh();
                            },
                            onSwipe: (previousIndex, currentIndex, direction) async {
                              if (previousIndex < 0 ||
                                  previousIndex >= swipeItems.length) {
                                return false;
                              }
                              final profile = swipeItems[previousIndex];
                              final notifier = ref.read(
                                discoveryNotifierProvider.notifier,
                              );

                              if (direction == CardSwiperDirection.right) {
                                // Reflective Romantic Swipe - wait for user to pick a reason
                                final reason = await _showReflectiveBottomSheet(profile);
                                if (reason != null && context.mounted) {
                                  HapticFeedback.heavyImpact();
                                  final isMatch = await notifier.handleRomantic(profile);
                                  if (isMatch && context.mounted) {
                                    context.push('/match', extra: profile);
                                  }
                                  return true; // Swipe succeeds
                                } else {
                                  // Cancelled, prevent the swipe
                                  return false;
                                }
                              } else if (direction == CardSwiperDirection.left) {
                                await notifier.handlePass(profile);
                              } else if (direction == CardSwiperDirection.top) {
                                final isMatch = await notifier.handleCollaborate(profile);
                                if (isMatch && context.mounted) {
                                  HapticFeedback.heavyImpact();
                                  context.push('/match', extra: profile);
                                }
                              } else if (direction == CardSwiperDirection.bottom) {
                                final isMatch = await notifier.handleFriendship(profile);
                                if (isMatch && context.mounted) {
                                  HapticFeedback.heavyImpact();
                                  context.push('/match', extra: profile);
                                }
                              }
                              return true;
                            },
                            cardBuilder: (
                              context,
                              index,
                              percentThresholdX,
                              percentThresholdY,
                            ) {
                              if (index < 0 || index >= swipeItems.length) {
                                return const SizedBox.shrink();
                              }
                              final profile = swipeItems[index];
                              final hasSignal = incomingSenderIds.contains(profile.id);

                              return InteractiveSwipeCard(
                                key: ValueKey(profile.id),
                                profile: profile,
                                dx: percentThresholdX,
                                dy: percentThresholdY,
                                hasIncomingSignal: hasSignal,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.close_rounded,
                              color: AppTheme.intentPass,
                              onPressed: () {
                                if (swipeItems.isNotEmpty) {
                                  _swiperController.swipe(
                                    CardSwiperDirection.left,
                                  );
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.handshake_rounded,
                              color: AppTheme.intentFriendship,
                              onPressed: () {
                                if (swipeItems.isNotEmpty) {
                                  _swiperController.swipe(
                                    CardSwiperDirection.bottom,
                                  );
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.bolt_rounded,
                              color: AppTheme.intentCollaborate,
                              onPressed: () {
                                if (swipeItems.isNotEmpty) {
                                  _swiperController.swipe(
                                    CardSwiperDirection.top,
                                  );
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.favorite_rounded,
                              color: AppTheme.intentRomantic,
                              onPressed: () {
                                if (swipeItems.isNotEmpty) {
                                  _swiperController.swipe(
                                    CardSwiperDirection.right,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return _AnimatedActionButton(
      icon: icon,
      color: color,
      onPressed: onPressed,
    );
  }

  Future<String?> _showReflectiveBottomSheet(ProfileCardModel profile) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What caught your attention?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Be intentional. Select what resonates before matching.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildReasonButton(context, 'Shared goals'),
              _buildReasonButton(context, 'Personality'),
              _buildReasonButton(context, 'Energy'),
              _buildReasonButton(context, 'Physical attraction'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReasonButton(BuildContext context, String reason) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(reason),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.dividerColor),
            backgroundColor: AppTheme.surfaceColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(AppTheme.primaryColor.withValues(alpha: 0.05)),
          ),
          child: Text(
            reason,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _isPressed
                        ? widget.color.withValues(alpha: 0.08)
                        : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: _isPressed ? widget.color : AppTheme.textSecondary,
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}

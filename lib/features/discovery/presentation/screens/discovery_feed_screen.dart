import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/discovery/presentation/providers/discovery_provider.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/interactive_swipe_card.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:student_dating_app/features/profile/presentation/screens/user_profile_screen.dart';

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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.dividerColor, height: 1.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite_outline_rounded,
              color: AppTheme.textSecondary,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.black12,
            onPressed: () => context.push('/intents'),
          ),
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppTheme.textSecondary,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.black12,
            onPressed: () => context.push('/chats'),
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline_rounded,
              color: AppTheme.textSecondary,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.black12,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserProfileScreen(),
                ),
              );
            },
          ),
        ],
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
                          color: AppTheme.primaryColor.withValues(
                            alpha: 0.08,
                          ),
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
                                () => ref.read(discoveryFilterProvider.notifier).state = InstitutionFilter.myInstitution,
                            child: Center(
                              child: Text(
                                'My Uni',
                                style: TextStyle(
                                  color:
                                      currentFilter ==
                                              InstitutionFilter
                                                  .myInstitution
                                          ? AppTheme.textPrimary
                                          : AppTheme.textSecondary,
                                  fontWeight:
                                      currentFilter ==
                                              InstitutionFilter
                                                  .myInstitution
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
                                () => ref.read(discoveryFilterProvider.notifier).state = InstitutionFilter.all,
                            child: Center(
                              child: Text(
                                'All',
                                style: TextStyle(
                                  color:
                                      currentFilter ==
                                              InstitutionFilter.all
                                          ? AppTheme.textPrimary
                                          : AppTheme.textSecondary,
                                  fontWeight:
                                      currentFilter ==
                                              InstitutionFilter.all
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
          loading:
              () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
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
                                  .read(discoveryNotifierProvider.notifier)
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sentiment_dissatisfied,
                      color: AppTheme.textSecondary,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No more profiles.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your filters.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed:
                          () =>
                              ref
                                  .read(discoveryNotifierProvider.notifier)
                                  .refresh(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceColor,
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
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
                      numberOfCardsDisplayed: swipeItems.length > 1 ? 2 : 1,
                      scale: 0.95,
                      backCardOffset: const Offset(0, 15),
                      onSwipe: (previousIndex, currentIndex, direction) {
                        if (previousIndex < 0 ||
                            previousIndex >= swipeItems.length) {
                          return false;
                        }
                        final profile = swipeItems[previousIndex];
                        final notifier = ref.read(
                          discoveryNotifierProvider.notifier,
                        );

                        if (direction == CardSwiperDirection.right) {
                          // Reflective Romantic Swipe - process async
                          WidgetsBinding.instance.addPostFrameCallback((
                            _,
                          ) async {
                            final reason = await _showReflectiveBottomSheet(
                              profile,
                            );
                            if (reason != null && mounted) {
                              // Successfully answered, record it
                              // You could also pass `reason` to notifier.handleRomantic if the notifier is updated,
                              // for now we'll just log or trigger it.
                              notifier.handleRomantic(profile);
                            } else {
                              // Cancelled, undo the swipe visually so it's back in the stack
                              if (mounted) {
                                _swiperController.undo();
                              }
                            }
                          });
                        } else if (direction == CardSwiperDirection.left) {
                          notifier.handlePass(profile);
                        } else if (direction == CardSwiperDirection.top) {
                          notifier.handleCollaborate(profile);
                        } else if (direction == CardSwiperDirection.bottom) {
                          notifier.handleFriendship(profile);
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

                        return InteractiveSwipeCard(
                          key: ValueKey(profile.id),
                          profile: profile,
                          dx: percentThresholdX,
                          dy: percentThresholdY,
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
                            _swiperController.swipe(CardSwiperDirection.left);
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.handshake_rounded,
                        color: AppTheme.intentFriendship,
                        onPressed: () {
                          if (swipeItems.isNotEmpty) {
                            _swiperController.swipe(CardSwiperDirection.bottom);
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.bolt_rounded,
                        color: AppTheme.intentCollaborate,
                        onPressed: () {
                          if (swipeItems.isNotEmpty) {
                            _swiperController.swipe(CardSwiperDirection.top);
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.favorite_rounded,
                        color: AppTheme.intentRomantic,
                        onPressed: () {
                          if (swipeItems.isNotEmpty) {
                            _swiperController.swipe(CardSwiperDirection.right);
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What caught your attention?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Be intentional. Select what resonates before matching.',
                style: TextStyle(color: Colors.white70),
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
            side: const BorderSide(color: AppTheme.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            reason,
            style: const TextStyle(
              color: AppTheme.primaryColor,
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

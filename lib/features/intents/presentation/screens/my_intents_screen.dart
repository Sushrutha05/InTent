import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/components/primary_photo_widget.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/profile_detail_bottom_sheet.dart';
import 'package:student_dating_app/features/intents/presentation/providers/intents_provider.dart';
import 'package:student_dating_app/features/intents/presentation/widgets/empty_intent_state.dart';

class MyIntentsScreen extends ConsumerStatefulWidget {
  const MyIntentsScreen({super.key});

  @override
  ConsumerState<MyIntentsScreen> createState() => _MyIntentsScreenState();
}

class _MyIntentsScreenState extends ConsumerState<MyIntentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intentsState = ref.watch(intentsNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Intents'),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kTextTabBarHeight),
          child: AnimatedBuilder(
            animation: _tabController.animation!,
            builder: (context, child) {
              final value = _tabController.animation!.value;
              Color activeColor;
              if (value < 1.0) {
                activeColor =
                    Color.lerp(
                      AppTheme.intentRomantic,
                      AppTheme.intentFriendship,
                      value,
                    ) ??
                    AppTheme.intentRomantic;
              } else {
                activeColor =
                    Color.lerp(
                      AppTheme.intentFriendship,
                      AppTheme.intentCollaborate,
                      value - 1.0,
                    ) ??
                    AppTheme.intentFriendship;
              }

              return TabBar(
                controller: _tabController,
                indicatorWeight: 2.0, // Thinner, more subtle underline
                indicatorColor: activeColor,
                labelColor: activeColor,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelColor: AppTheme.textMuted,
                tabs: const [
                  Tab(text: 'Romantic'),
                  Tab(text: 'Friendship'),
                  Tab(text: 'Collaborate'),
                ],
              );
            },
          ),
        ),
      ),
      body: intentsState.when(
        data: (intents) {
          final romanticProfiles =
              ref.read(intentsNotifierProvider.notifier).romanticProfiles;
          final friendshipProfiles =
              ref.read(intentsNotifierProvider.notifier).friendshipProfiles;
          final collaborateProfiles =
              ref.read(intentsNotifierProvider.notifier).collaborateProfiles;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildIntentsList(romanticProfiles, 0),
              _buildIntentsList(friendshipProfiles, 1),
              _buildIntentsList(collaborateProfiles, 2),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load intents'),
                  TextButton(
                    onPressed:
                        () =>
                            ref
                                .read(intentsNotifierProvider.notifier)
                                .refresh(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildIntentsList(List intents, int tabIndex) {
    if (intents.isEmpty) {
      String title;
      String subtitle;
      IconData icon;
      Color color;

      if (tabIndex == 0) {
        title = "No romantic interests yet";
        subtitle = "Express romantic intent to connect and build meaningful relationships.";
        icon = Icons.favorite_rounded;
        color = AppTheme.intentRomantic;
      } else if (tabIndex == 1) {
        title = "No friendship signals yet";
        subtitle = "Swipe down to build your circle and meet like-minded peers.";
        icon = Icons.people_rounded;
        color = AppTheme.intentFriendship;
      } else {
        title = "No collaborators yet";
        subtitle = "Swipe up to find your next project partner or study buddy.";
        icon = Icons.bolt_rounded;
        color = AppTheme.intentCollaborate;
      }

      return EmptyIntentState(
        title: title,
        subtitle: subtitle,
        icon: icon,
        color: color,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(intentsNotifierProvider.notifier).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: intents.length,
        itemBuilder: (context, index) {
          final intent = intents[index];
          final profile = intent.targetProfile;

          return GestureDetector(
            onTap: () {
              ProfileDetailBottomSheet.show(context, profile);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Blurred Background Image
                PrimaryPhotoWidget(
                  imageUrl:
                      profile.photoUrls.isNotEmpty
                          ? profile.photoUrls.first
                          : AppTheme.defaultUserImage,
                  blurLevel: profile.currentBlurLevel > 0 
                      ? profile.currentBlurLevel 
                      : AppTheme.getRevealBlurLevel(0.0), // Default strong blur
                  onTap: () {
                    // Handled by the GestureDetector wrapping the Stack
                  },
                ),
                // 2. Profile Details Overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.name}, ${profile.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        profile.university,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

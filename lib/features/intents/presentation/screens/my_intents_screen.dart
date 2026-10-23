import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/components/primary_photo_widget.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/profile_detail_bottom_sheet.dart';
import 'package:student_dating_app/features/intents/domain/incoming_signal_model.dart';
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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intentsState = ref.watch(intentsNotifierProvider);
    final signalsState = ref.watch(incomingSignalsProvider);

    final int signalsCount = signalsState.value?.length ?? 0;

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
                activeColor = Color.lerp(
                      const Color(0xFFF59E0B),
                      AppTheme.intentRomantic,
                      value,
                    ) ??
                    const Color(0xFFF59E0B);
              } else if (value < 2.0) {
                activeColor = Color.lerp(
                      AppTheme.intentRomantic,
                      AppTheme.intentFriendship,
                      value - 1.0,
                    ) ??
                    AppTheme.intentRomantic;
              } else {
                activeColor = Color.lerp(
                      AppTheme.intentFriendship,
                      AppTheme.intentCollaborate,
                      value - 2.0,
                    ) ??
                    AppTheme.intentFriendship;
              }

              return TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorWeight: 2.0,
                indicatorColor: activeColor,
                labelColor: activeColor,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelColor: AppTheme.textMuted,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_rounded, size: 14),
                        const SizedBox(width: 4),
                        const Text('Signals'),
                        if (signalsCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$signalsCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: 'Romantic'),
                  const Tab(text: 'Friendship'),
                  const Tab(text: 'Collaborate'),
                ],
              );
            },
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Secret Incoming Signals (Blind Matching)
          _buildSignalsTab(signalsState),

          // 2. Romantic Matches
          _buildIntentsList(
            ref.read(intentsNotifierProvider.notifier).romanticProfiles,
            0,
            intentsState,
          ),

          // 3. Friendship Matches
          _buildIntentsList(
            ref.read(intentsNotifierProvider.notifier).friendshipProfiles,
            1,
            intentsState,
          ),

          // 4. Collaborate Matches
          _buildIntentsList(
            ref.read(intentsNotifierProvider.notifier).collaborateProfiles,
            2,
            intentsState,
          ),
        ],
      ),
    );
  }

  Widget _buildSignalsTab(AsyncValue<List<IncomingSignal>> signalsState) {
    return signalsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading signals: $e')),
      data: (signals) {
        if (signals.isEmpty) {
          return const EmptyIntentState(
            title: "No secret signals yet",
            subtitle: "When someone swipes on you, they'll appear here with their intent hidden! Keep exploring to spark connections.",
            icon: Icons.lock_outline_rounded,
            color: Color(0xFFF59E0B),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(incomingSignalsProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: signals.length + 1, // +1 for banner
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildBlindMatchingBanner();
              }
              final signal = signals[index - 1];
              return _buildSignalCard(signal);
            },
          ),
        );
      },
    );
  }

  Widget _buildBlindMatchingBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.12),
            AppTheme.primaryColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.vpn_key_rounded, color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blind Intent Matching 🔒',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'These students swiped on you, but their intent is hidden! Pick your genuine intent — if both align, you match. If not, choices stay 100% private.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalCard(IncomingSignal signal) {
    final profile = signal.profile;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile header tap to inspect
          GestureDetector(
            onTap: () => ProfileDetailBottomSheet.show(context, profile),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: PrimaryPhotoWidget(
                      imageUrl: profile.photoUrls.isNotEmpty
                          ? profile.photoUrls.first
                          : AppTheme.defaultUserImage,
                      blurLevel: AppTheme.getRevealBlurLevel(0.0),
                      onTap: () => ProfileDetailBottomSheet.show(context, profile),
                    ),
                  ),
                ),
                // Gradient Scrim
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Top secret badge
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, size: 14, color: Color(0xFFF59E0B)),
                        SizedBox(width: 4),
                        Text(
                          'Intent Hidden 🔒',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Profile details bottom
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.name}, ${profile.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${profile.major} @ ${profile.university}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'What is your genuine intent with ${profile.name}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Romantic
                    Expanded(
                      child: _buildIntentChoiceButton(
                        label: 'Romantic',
                        icon: Icons.favorite_rounded,
                        color: AppTheme.intentRomantic,
                        onTap: () => _handleSignalResponse(signal, 'ROMANTIC'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Friendship
                    Expanded(
                      child: _buildIntentChoiceButton(
                        label: 'Friendship',
                        icon: Icons.handshake_rounded,
                        color: AppTheme.intentFriendship,
                        onTap: () => _handleSignalResponse(signal, 'FRIENDSHIP'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Collaborate
                    Expanded(
                      child: _buildIntentChoiceButton(
                        label: 'Collaborate',
                        icon: Icons.bolt_rounded,
                        color: AppTheme.intentCollaborate,
                        onTap: () => _handleSignalResponse(signal, 'COLLABORATE'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Pass
                    Material(
                      color: AppTheme.surfaceSolid.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _handleSignalResponse(signal, 'PASS'),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntentChoiceButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignalResponse(IncomingSignal signal, String myIntent) async {
    final notifier = ref.read(intentsNotifierProvider.notifier);
    final isMatch = await notifier.respondToSignal(signal, myIntent);

    if (!mounted) return;

    if (isMatch) {
      HapticFeedback.heavyImpact();
      context.push('/match', extra: signal.profile);
    } else {
      if (myIntent != 'PASS') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Intents didn't align this time! Both choices remain 100% private. 🔒"),
            duration: Duration(seconds: 3),
            backgroundColor: Color(0xFF374151),
          ),
        );
      }
    }
  }

  Widget _buildIntentsList(List intents, int tabIndex, AsyncValue intentsState) {
    return intentsState.when(
      data: (_) {
        if (intents.isEmpty) {
          String title;
          String subtitle;
          IconData icon;
          Color color;

          if (tabIndex == 0) {
            title = "No romantic matches yet";
            subtitle = "When you and another student both express romantic intent, they will appear here!";
            icon = Icons.favorite_rounded;
            color = AppTheme.intentRomantic;
          } else if (tabIndex == 1) {
            title = "No friendship matches yet";
            subtitle = "Mutual friendship intents will connect here so you can start chatting.";
            icon = Icons.people_rounded;
            color = AppTheme.intentFriendship;
          } else {
            title = "No collaborators yet";
            subtitle = "Find study buddies and project partners who share your collaborative drive.";
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
                    PrimaryPhotoWidget(
                      imageUrl: profile.photoUrls.isNotEmpty
                          ? profile.photoUrls.first
                          : AppTheme.defaultUserImage,
                      blurLevel: profile.currentBlurLevel > 0
                          ? profile.currentBlurLevel
                          : AppTheme.getRevealBlurLevel(0.0),
                      onTap: () {
                        ProfileDetailBottomSheet.show(context, profile);
                      },
                    ),
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load intents'),
            TextButton(
              onPressed: () => ref.read(intentsNotifierProvider.notifier).refresh(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

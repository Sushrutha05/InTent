import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/presentation/screens/discovery_feed_screen.dart';
import 'package:student_dating_app/features/intents/presentation/screens/my_intents_screen.dart';
import 'package:student_dating_app/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:student_dating_app/features/profile/presentation/screens/user_profile_screen.dart';

/// State provider for controlling the active tab index globally.
final navigationTabProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  // Keeps track of which tabs have been visited so we only build them once
  final Set<int> _loadedIndexes = {0};

  // Screens cached in IndexedStack to preserve their full visual and scroll state
  final List<Widget> _screens = const [
    DiscoveryFeedScreen(),
    MyIntentsScreen(),
    ChatListScreen(),
    UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationTabProvider);
    _loadedIndexes.add(currentIndex);

    return Scaffold(
      extendBody:
          true, // Allows content to show under the floating glass bottom bar
      body: IndexedStack(
        index: currentIndex,
        children: List.generate(_screens.length, (index) {
          // Lazy load: Only build the screen if it has been visited at least once
          if (_loadedIndexes.contains(index)) {
            return _screens[index];
          }
          return const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.explore_outlined,
                      activeIcon: Icons.explore_rounded,
                      label: 'Discover',
                      currentIndex: currentIndex,
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.favorite_outline_rounded,
                      activeIcon: Icons.favorite_rounded,
                      label: 'Intents',
                      currentIndex: currentIndex,
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                      label: 'Chats',
                      currentIndex: currentIndex,
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      currentIndex: currentIndex,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int currentIndex,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppTheme.primaryColor : AppTheme.textSecondary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isSelected) {
            HapticFeedback.lightImpact();
            ref.read(navigationTabProvider.notifier).state = index;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.15 : 1.0,
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
            // Glowing feedback dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              width: isSelected ? 4 : 0,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

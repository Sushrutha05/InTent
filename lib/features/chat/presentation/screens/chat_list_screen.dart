import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/chat/presentation/providers/chat_providers.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/progressive_blur_image.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final currentUserId = supabase.auth.currentUser?.id;

    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    final channelsAsync = ref.watch(chatChannelsStreamProvider(currentUserId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Matches & Chats',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.dividerColor, height: 1.0),
        ),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: channelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        data: (channels) {
          if (channels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No connections yet.',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Real connections begin with intent.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceColor,
                      foregroundColor: AppTheme.primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Discover Profiles'),
                  ),
                ],
              ),
            );
          }

          // Segregate into new matches (no messages) and active chats (has messages)
          final newMatches = channels.where((c) => c.messages.isEmpty).toList();
          final activeChats =
              channels.where((c) => c.messages.isNotEmpty).toList();

          return CustomScrollView(
            slivers: [
              // New Matches Section (Horizontal Scroll)
              if (newMatches.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'New Matches',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: newMatches.length,
                          itemBuilder: (context, index) {
                            final match = newMatches[index];
                            return GestureDetector(
                              onTap:
                                  () => context.push(
                                    '/chat/${match.id}',
                                    extra: match,
                                  ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: ProgressiveBlurImage(
                                          imageUrl:
                                              match
                                                      .matchedUser
                                                      .photoUrls
                                                      .isNotEmpty
                                                  ? match
                                                      .matchedUser
                                                      .photoUrls
                                                      .first
                                                  : AppTheme.defaultUserImage,
                                          blurLevel:
                                              AppTheme.getRevealBlurLevel(
                                                match.unblurProgress,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      match.matchedUser.name,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // Divider
              if (newMatches.isNotEmpty && activeChats.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Divider(color: AppTheme.dividerColor),
                  ),
                ),

              // Messages Section (Vertical Scroll)
              if (activeChats.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Messages',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (activeChats.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final chat = activeChats[index];
                    final user = chat.matchedUser;

                    // Calculate unread safely if last message is not made by ME
                    final lastMessage = chat.messages.first;
                    final isUnread =
                        lastMessage.senderId != currentUserId &&
                        !lastMessage.isRead;

                    return ListTile(
                      onTap:
                          () => context.push('/chat/${chat.id}', extra: chat),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          children: [
                            ClipOval(
                              child: ProgressiveBlurImage(
                                imageUrl:
                                    user.photoUrls.isNotEmpty
                                        ? user.photoUrls.first
                                        : AppTheme.defaultUserImage,
                                blurLevel: AppTheme.getRevealBlurLevel(
                                  chat.unblurProgress,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.backgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          lastMessage.content,
                          style: TextStyle(
                            color:
                                isUnread
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                            fontWeight:
                                isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }, childCount: activeChats.length),
                ),
            ],
          );
        },
      ),
    );
  }
}

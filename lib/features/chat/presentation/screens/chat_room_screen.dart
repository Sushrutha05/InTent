import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/chat/presentation/providers/chat_providers.dart';
import 'package:student_dating_app/features/chat/domain/services/intent_shift_service.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/progressive_blur_image.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/profile_detail_bottom_sheet.dart';
import 'package:student_dating_app/features/discovery/presentation/providers/discovery_provider.dart';

import 'package:student_dating_app/core/notifications/notification_service.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatRoomScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double _currentUnblurProgress = 0.0;
  ProfileCardModel? _matchedUser;

  @override
  void initState() {
    super.initState();
    NotificationService.currentlyOpenChatId = widget.chatId;
    _fetchInitialChannelData();
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    final supabase = Supabase.instance.client;
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId != null) {
      await ref
          .read(chatRepositoryProvider)
          .markMessagesAsRead(widget.chatId, currentUserId);
    }
  }

  Future<void> _fetchInitialChannelData() async {
    // Quick fetch to get the unblur progress and the matched user profile
    // The stream will handle the messages
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      final matchData =
          await supabase
              .from('matches')
              .select()
              .eq('id', widget.chatId)
              .single();

      final otherUserId =
          matchData['user1_id'] == currentUserId
              ? matchData['user2_id']
              : matchData['user1_id'];

      final profileResponse =
          await supabase
              .from('profiles')
              .select()
              .eq('id', otherUserId)
              .single();

      final interestsRaw = profileResponse['interests'] as List<dynamic>? ?? [];
      final photosRaw = profileResponse['photo_urls'] as List<dynamic>? ?? [];

      setState(() {
        _currentUnblurProgress =
            (matchData['unblur_progress'] as num? ?? 0.0).toDouble();
        _matchedUser = ProfileCardModel(
          id: profileResponse['id'] as String,
          name: profileResponse['first_name'] as String? ?? 'Unknown',
          age: 20,
          university: profileResponse['university'] as String? ?? '',
          major: profileResponse['major'] as String? ?? '',
          primaryIntent:
              profileResponse['primary_intent'] as String? ?? 'friendship',
          bio: profileResponse['bio'] as String? ?? '',
          vibePrompt: profileResponse['vibe_prompt'] as String? ?? '',
          vibeAnswer: profileResponse['vibe_answer'] as String? ?? '',
          interests: interestsRaw.map((e) => e.toString()).toList(),
          photoUrls: photosRaw.map((e) => e.toString()).toList(),
          currentBlurLevel: AppTheme.getRevealBlurLevel(_currentUnblurProgress),
        );
      });
    } catch (e) {
      debugPrint('Error fetching specific chat data: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final supabase = Supabase.instance.client;
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    final content = _messageController.text;
    _messageController.clear(); // Optimistic clear

    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.sendMessage(widget.chatId, currentUserId, content);

      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      debugPrint('Failed to send message: $e');
    }
  }

  @override
  void dispose() {
    NotificationService.currentlyOpenChatId = null;
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double _getUIBlurLevel(double matchProgress) {
    return AppTheme.getRevealBlurLevel(matchProgress);
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesStreamProvider(widget.chatId));
    final matchAsync = ref.watch(matchStreamProvider(widget.chatId));
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // Use progress from stream if available, and keep local state updated to prevent flicker
    final displayProgress = matchAsync.when(
      data: (data) {
        final progress = (data['unblur_progress'] as num? ?? 0.0).toDouble();
        // Update local state if it differs, allowing fallback during stream loading states
        if (progress != _currentUnblurProgress) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentUnblurProgress = progress;
              });
            }
          });
        }
        return progress;
      },
      loading:
          () =>
              _currentUnblurProgress, // Smooth fallback to last known progress
      error: (_, __) => _currentUnblurProgress,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.dividerColor, height: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
        title:
            _matchedUser == null
                ? const SizedBox()
                : Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Hero(
                        tag: 'avatar_${widget.chatId}',
                        child: ClipOval(
                          child: ProgressiveBlurImage(
                            imageUrl:
                                _matchedUser!.photoUrls.isNotEmpty
                                    ? _matchedUser!.photoUrls.first
                                    : AppTheme.defaultUserImage,
                            blurLevel: _getUIBlurLevel(displayProgress),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (_matchedUser != null) {
                            ProfileDetailBottomSheet.show(
                              context,
                              _matchedUser!,
                              unblurProgress: displayProgress,
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _matchedUser!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              _matchedUser!.university,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        actions: [
          if (_matchedUser != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
              onSelected: (value) async {
                if (value == 'shift_intent') {
                  _showIntentShiftDialog();
                } else if (value == 'block_user') {
                  _showBlockDialog();
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'shift_intent',
                      child: Text('Request Intent Shift'),
                    ),
                    const PopupMenuItem(
                      value: 'block_user',
                      child: Text(
                        'Block & Report User',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages List from Stream
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (e, s) => Center(
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Say hi!',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }

                // Auto-scroll AND mark as read on new messages
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }

                  // If any messages are unread AND were sent by the OTHER person, mark all as read.
                  final hasUnreadFromOther = messages.any(
                    (m) => !m.isRead && m.senderId != currentUserId,
                  );
                  if (hasUnreadFromOther) {
                    _markMessagesAsRead();
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                          left: 24,
                          right: 24,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isMe
                                  ? const Color(0xFFE3E8F1) // Soft blue-grey
                                  : const Color(0xFFECE8E1), // Soft warm beige
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight:
                                isMe
                                    ? const Radius.circular(4)
                                    : const Radius.circular(16),
                            bottomLeft:
                                !isMe
                                    ? const Radius.circular(4)
                                    : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message.content,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Field
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.dividerColor)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLength: 1000,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) => null, // Hide character counter for a cleaner UI
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppTheme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppTheme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showIntentShiftDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Request Intent Shift',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.pink),
                title: const Text(
                  'Romantic',
                  style: TextStyle(color: Colors.pink),
                ),
                onTap: () => Navigator.pop(context, 'ROMANTIC'),
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Colors.green),
                title: const Text(
                  'Friendship',
                  style: TextStyle(color: Colors.green),
                ),
                onTap: () => Navigator.pop(context, 'FRIENDSHIP'),
              ),
              ListTile(
                leading: const Icon(Icons.handshake, color: Colors.blue),
                title: const Text(
                  'Collaborate',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () => Navigator.pop(context, 'COLLABORATE'),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && _matchedUser != null) {
      final success = await ref
          .read(intentShiftServiceProvider.notifier)
          .proposeIntentShift(
            channelId: widget.chatId,
            targetUserId: _matchedUser!.id,
            newIntentType: result,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Shift Request Sent!' : 'Could not request shift.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _showBlockDialog() async {
    if (_matchedUser == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Block & Report'),
          content: const Text(
            'Are you sure you want to block this user? The chat will be deleted, and you will no longer see each other. This action is permanent.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Block User',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      try {
        await ref
            .read(discoveryNotifierProvider.notifier)
            .blockUser(_matchedUser!.id);

        if (mounted) {
          context.pop(); // Go back to chat list
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User blocked.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/chat/domain/chat_models.dart';
import 'package:student_dating_app/features/chat/domain/chat_activity_model.dart';
import 'package:student_dating_app/features/chat/domain/chat_message_payload.dart';
import 'package:student_dating_app/features/chat/presentation/providers/chat_providers.dart';
import 'package:student_dating_app/features/chat/domain/services/intent_shift_service.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/progressive_blur_image.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/profile_detail_bottom_sheet.dart';
import 'package:student_dating_app/features/discovery/presentation/providers/discovery_provider.dart';
import 'package:student_dating_app/features/chat/presentation/widgets/chat_activity_bubble.dart';
import 'package:student_dating_app/features/chat/presentation/widgets/chat_activities_sheet.dart';
import 'package:student_dating_app/features/chat/presentation/widgets/chat_reply_bar.dart';
import 'package:student_dating_app/features/chat/presentation/widgets/photo_lock_sheet.dart';
import 'package:student_dating_app/features/chat/presentation/widgets/chat_photo_picker_sheet.dart';
import 'package:student_dating_app/features/chat/presentation/widgets/snap_view_dialog.dart';
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
  DateTime? _matchCreatedAt;
  bool _devPhotoUnlocked = false;
  ChatMessage? _replyingToMessage;

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
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      final matchData = await supabase
          .from('matches')
          .select()
          .eq('id', widget.chatId)
          .single();

      final otherUserId = matchData['user1_id'] == currentUserId
          ? matchData['user2_id']
          : matchData['user1_id'];

      final createdAtStr = matchData['created_at'] as String?;
      final createdAt =
          createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', otherUserId)
          .single();

      final interestsRaw = profileResponse['interests'] as List<dynamic>? ?? [];
      final photosRaw = profileResponse['photo_urls'] as List<dynamic>? ?? [];

      if (mounted) {
        setState(() {
          _matchCreatedAt = createdAt;
          _currentUnblurProgress =
              (matchData['unblur_progress'] as num? ?? 0.0).toDouble();
          _matchedUser = ProfileCardModel(
            id: profileResponse['id'] as String,
            name: profileResponse['first_name'] as String? ?? 'Unknown',
            age: _calculateAge(profileResponse['date_of_birth'] as String?),
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
      }
    } catch (e) {
      debugPrint('Error fetching specific chat data: $e');
    }
  }

  int _calculateAge(String? dobString) {
    if (dobString == null) return 18;
    try {
      final dob = DateTime.parse(dobString);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 18;
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final supabase = Supabase.instance.client;
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    _messageController.clear(); // Optimistic clear

    try {
      final repo = ref.read(chatRepositoryProvider);

      String content = text;
      if (_replyingToMessage != null) {
        final isReplyingToMe = _replyingToMessage!.senderId == currentUserId;
        final senderName =
            isReplyingToMe ? 'You' : (_matchedUser?.name ?? 'Them');
        final snippet =
            ChatMessageFormatter.formatPreview(_replyingToMessage!.content);

        final replyMeta = ChatReplyMeta(
          replyToId: _replyingToMessage!.id,
          replyToSenderName: senderName,
          replyToSnippet: snippet,
          actualMessage: text,
        );
        content = replyMeta.encode();

        setState(() {
          _replyingToMessage = null;
        });
      }

      await repo.sendMessage(widget.chatId, currentUserId, content);

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void _handlePhotoAttachment(
    List<ChatMessage> messages,
    double currentProgress,
  ) {
    final unlocked = StreakHelper.isPhotoUnlocked(
      matchCreatedAt: _matchCreatedAt,
      messages: messages,
      unblurProgress: currentProgress,
      devBypass: _devPhotoUnlocked,
    );

    if (!unlocked) {
      PhotoLockSheet.show(
        context,
        daysConnected: StreakHelper.getFriendshipDays(_matchCreatedAt),
        currentStreak: StreakHelper.calculateStreak(messages),
        unblurProgress: currentProgress,
        onBypassUnlock: () {
          setState(() => _devPhotoUnlocked = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🧪 Testing Mode: Photo and Snap sharing unlocked!'),
              backgroundColor: AppTheme.accentColor,
              duration: Duration(seconds: 2),
            ),
          );
        },
      );
      return;
    }

    ChatPhotoPickerSheet.show(
      context,
      onSend: ({
        required Uint8List bytes,
        required String fileName,
        required bool isViewOnce,
        String? caption,
      }) async {
        final supabase = Supabase.instance.client;
        final currentUserId = supabase.auth.currentUser?.id;
        if (currentUserId == null) return;

        try {
          final repo = ref.read(chatRepositoryProvider);
          final imageUrl = await repo.uploadChatImage(
            widget.chatId,
            fileName,
            bytes,
          );

          final snapMeta = ChatSnapMeta(
            imageUrl: imageUrl,
            isViewOnce: isViewOnce,
            caption: caption,
          );

          await repo.sendSnap(widget.chatId, currentUserId, snapMeta);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $e'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      },
    );
  }

  void _showMessageActions(
    ChatMessage message,
    bool isMe,
    String? currentUserId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF141923),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.reply_rounded,
                color: AppTheme.primaryColor,
              ),
              title: const Text(
                'Reply to Message',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _replyingToMessage = message;
                });
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.copy_rounded,
                color: AppTheme.textSecondary,
              ),
              title: const Text(
                'Copy Text',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                final text = ChatReplyMeta.isReply(message.content)
                    ? (ChatReplyMeta.decode(message.content)?.actualMessage ??
                        message.content)
                    : message.content;
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day) {
      return 'Yesterday';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[local.month - 1]} ${local.day}';
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

    final displayProgress = matchAsync.when(
      data: (data) {
        final progress = (data['unblur_progress'] as num? ?? 0.0).toDouble();
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
      loading: () => _currentUnblurProgress,
      error: (_, __) => _currentUnblurProgress,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141923),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white10, height: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: _matchedUser == null
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
                          imageUrl: _matchedUser!.photoUrls.isNotEmpty
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
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _matchedUser!.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppTheme.accentColor,
                                size: 14,
                              ),
                            ],
                          ),
                          messagesAsync.maybeWhen(
                            data: (messages) {
                              final streak =
                                  StreakHelper.calculateStreak(messages);
                              return Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _matchedUser!.university,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (streak > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5252)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFFFF5252)
                                              .withValues(alpha: 0.3),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.local_fire_department_rounded,
                                            size: 11,
                                            color: Color(0xFFFF5252),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '$streak',
                                            style: const TextStyle(
                                              color: Color(0xFFFF5252),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                            orElse: () => Text(
                              _matchedUser!.university,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
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
              color: const Color(0xFF1E2433),
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppTheme.textSecondary,
              ),
              onSelected: (value) async {
                if (value == 'shift_intent') {
                  _showIntentShiftDialog();
                } else if (value == 'block_user') {
                  _showBlockDialog();
                } else if (value == 'view_profile') {
                  ProfileDetailBottomSheet.show(
                    context,
                    _matchedUser!,
                    unblurProgress: displayProgress,
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view_profile',
                  child: Text(
                    'View Full Profile',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
                const PopupMenuItem(
                  value: 'shift_intent',
                  child: Text(
                    'Request Intent Shift',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
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
          // Messages List
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
              error: (e, s) => Center(
                child: Text(
                  'Error loading chat: $e',
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.waving_hand_rounded,
                            size: 44,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Say hello to ${_matchedUser?.name ?? "your match"}!',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Send a message, play an icebreaker, or break the ice!',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll and mark as read
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }

                  final hasUnreadFromOther = messages.any(
                    (m) => !m.isRead && m.senderId != currentUserId,
                  );
                  if (hasUnreadFromOther) {
                    _markMessagesAsRead();
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    // Date Header pill check
                    bool showDateHeader = false;
                    if (index == 0) {
                      showDateHeader = true;
                    } else {
                      final prev = messages[index - 1].createdAt.toLocal();
                      final curr = message.createdAt.toLocal();
                      if (prev.year != curr.year ||
                          prev.month != curr.month ||
                          prev.day != curr.day) {
                        showDateHeader = true;
                      }
                    }

                    // If minigame/activity
                    if (ChatActivity.isActivity(message.content)) {
                      final activity = ChatActivity.decode(message.content);
                      if (activity != null) {
                        return Column(
                          children: [
                            if (showDateHeader)
                              _buildDatePill(_formatDateHeader(message.createdAt)),
                            ChatActivityBubble(
                              activity: activity,
                              messageId: message.id,
                              matchId: widget.chatId,
                              currentUserId: currentUserId ?? '',
                              onGuessLie: (guessedIndex) async {
                                final isLie =
                                    guessedIndex == activity.correctIndex;
                                final updated = activity.copyWith(
                                  isCompleted: true,
                                  responses: {
                                    ...activity.responses,
                                    'guessedIndex': guessedIndex,
                                    'guessedBy': currentUserId,
                                    'isCorrect': isLie,
                                  },
                                );
                                await ref
                                    .read(chatRepositoryProvider)
                                    .updateActivityResponse(
                                      widget.chatId,
                                      message.id,
                                      updated,
                                      boost: activity.blurBoost,
                                    );
                              },
                              onVoteWouldYouRather: (choice) async {
                                final updatedResponses =
                                    Map<String, dynamic>.from(
                                  activity.responses,
                                );
                                updatedResponses[currentUserId ?? ''] = choice;
                                final bool nowCompleted =
                                    updatedResponses.length >= 2;
                                final updated = activity.copyWith(
                                  responses: updatedResponses,
                                  isCompleted: nowCompleted,
                                );
                                await ref
                                    .read(chatRepositoryProvider)
                                    .updateActivityResponse(
                                      widget.chatId,
                                      message.id,
                                      updated,
                                      boost: activity.blurBoost,
                                    );
                              },
                            ),
                          ],
                        );
                      }
                    }

                    return Column(
                      children: [
                        if (showDateHeader)
                          _buildDatePill(_formatDateHeader(message.createdAt)),
                        Dismissible(
                          key: ValueKey('msg_${message.id}'),
                          direction: DismissDirection.startToEnd,
                          confirmDismiss: (dir) async {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _replyingToMessage = message;
                            });
                            return false;
                          },
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 16),
                            child: const Icon(
                              Icons.reply_rounded,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          child: GestureDetector(
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              _showMessageActions(message, isMe, currentUserId);
                            },
                            child: Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.76,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isMe
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF6C63FF),
                                            Color(0xFF4F46E5),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isMe ? null : const Color(0xFF1E2433),
                                  border: isMe
                                      ? null
                                      : Border.all(
                                          color: const Color(0xFF2B3447),
                                          width: 1,
                                        ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 18),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 1. Quoted Reply Preview (if reply)
                                    if (ChatReplyMeta.isReply(message.content))
                                      _buildQuotedReplyBox(
                                        message.content,
                                        isMe,
                                      ),

                                    // 2. Snap or Photo Content
                                    if (ChatSnapMeta.isSnap(message.content))
                                      _buildSnapOrPhotoContent(
                                        message,
                                        isMe,
                                        currentUserId,
                                      )
                                    else
                                      // 3. Normal Text Content
                                      Text(
                                        ChatReplyMeta.isReply(message.content)
                                            ? (ChatReplyMeta.decode(
                                                      message.content,
                                                    )?.actualMessage ??
                                                    message.content)
                                            : message.content,
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : AppTheme.textPrimary,
                                          fontSize: 15,
                                          height: 1.35,
                                        ),
                                      ),

                                    const SizedBox(height: 4),

                                    // 4. Timestamp & Read Receipts
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatTime(message.createdAt),
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white70
                                                : AppTheme.textMuted,
                                            fontSize: 10,
                                          ),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            message.isRead
                                                ? Icons.done_all_rounded
                                                : Icons.done_rounded,
                                            size: 13,
                                            color: message.isRead
                                                ? const Color(0xFF38BDF8)
                                                : Colors.white60,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Field & Interactive Reply Bar
          SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF141923),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Reply Bar
                  if (_replyingToMessage != null)
                    ChatReplyBar(
                      replyMessage: _replyingToMessage!,
                      senderName:
                          _replyingToMessage!.senderId == currentUserId
                              ? 'You'
                              : (_matchedUser?.name ?? 'Them'),
                      onCancel: () => setState(() => _replyingToMessage = null),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Games / Activities Button
                        IconButton(
                          icon: const Icon(
                            Icons.sports_esports_rounded,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                          tooltip: 'In-Chat Activities & Games',
                          onPressed: () {
                            if (currentUserId == null) return;
                            ChatActivitiesSheet.show(
                              context,
                              currentUserId: currentUserId,
                              onSendActivity: (activity) async {
                                await ref
                                    .read(chatRepositoryProvider)
                                    .sendActivity(
                                      widget.chatId,
                                      currentUserId,
                                      activity,
                                    );
                              },
                            );
                          },
                        ),

                        // Snapchat / Photo Button (with safety lock indicator)
                        messagesAsync.maybeWhen(
                          data: (messages) {
                            final unlocked = StreakHelper.isPhotoUnlocked(
                              matchCreatedAt: _matchCreatedAt,
                              messages: messages,
                              unblurProgress: displayProgress,
                              devBypass: _devPhotoUnlocked,
                            );

                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    unlocked
                                        ? Icons.local_fire_department_rounded
                                        : Icons.photo_camera_rounded,
                                    color: unlocked
                                        ? const Color(0xFFFF5252)
                                        : AppTheme.textMuted,
                                    size: 24,
                                  ),
                                  tooltip: unlocked
                                      ? 'Send Photo or Snap 🔥'
                                      : 'Photo lock (Tap for info)',
                                  onPressed: () => _handlePhotoAttachment(
                                    messages,
                                    displayProgress,
                                  ),
                                ),
                                if (!unlocked)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1E2433),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lock_rounded,
                                        size: 11,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                          orElse: () => IconButton(
                            icon: const Icon(
                              Icons.photo_camera_rounded,
                              color: AppTheme.textMuted,
                              size: 24,
                            ),
                            onPressed: () => _handlePhotoAttachment(
                              [],
                              displayProgress,
                            ),
                          ),
                        ),

                        // Text Field
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            maxLength: 1000,
                            maxLines: 4,
                            minLines: 1,
                            buildCounter: (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1E2433),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Send Button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6C63FF),
                                Color(0xFF4F46E5),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
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

  Widget _buildDatePill(String dateText) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2433),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        dateText,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuotedReplyBox(String rawContent, bool isMe) {
    final replyMeta = ChatReplyMeta.decode(rawContent);
    if (replyMeta == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.black.withValues(alpha: 0.18)
            : const Color(0xFF141923),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white70 : AppTheme.primaryColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            replyMeta.replyToSenderName,
            style: TextStyle(
              color: isMe ? Colors.white : AppTheme.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyMeta.replyToSnippet,
            style: TextStyle(
              color: isMe ? Colors.white70 : AppTheme.textMuted,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSnapOrPhotoContent(
    ChatMessage message,
    bool isMe,
    String? currentUserId,
  ) {
    final snap = ChatSnapMeta.decode(message.content);
    if (snap == null) return const SizedBox.shrink();

    if (snap.isViewOnce) {
      final isViewedByMe = currentUserId != null &&
          snap.viewedByUserIds.contains(currentUserId);

      return InkWell(
        onTap: () {
          SnapViewDialog.show(
            context,
            imageUrl: snap.imageUrl,
            caption: snap.caption,
            onViewed: () {
              if (currentUserId != null && !isMe) {
                ref.read(chatRepositoryProvider).markSnapViewed(
                      widget.chatId,
                      message.id,
                      snap,
                      currentUserId,
                    );
              }
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isViewedByMe
                ? Colors.black26
                : const Color(0xFFFF5252).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isViewedByMe
                  ? Colors.white12
                  : const Color(0xFFFF5252).withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isViewedByMe
                    ? Icons.local_fire_department_outlined
                    : Icons.local_fire_department_rounded,
                color: isViewedByMe ? Colors.white38 : const Color(0xFFFF5252),
                size: 24,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isViewedByMe ? 'Opened Snap' : 'View-Once Snap 🔥',
                    style: TextStyle(
                      color: isViewedByMe ? Colors.white54 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    isViewedByMe ? 'Already viewed' : 'Tap to view (10s)',
                    style: TextStyle(
                      color: isViewedByMe ? Colors.white38 : Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // Standard Chat Photo
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.push('/image', extra: {
                'imageUrl': snap.imageUrl,
                'heroTag': 'photo_${message.id}',
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: 'photo_${message.id}',
                child: CachedNetworkImage(
                  imageUrl: snap.imageUrl,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 220,
                    height: 220,
                    color: Colors.white10,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, err) => Container(
                    width: 220,
                    height: 220,
                    color: Colors.white10,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (snap.caption != null && snap.caption!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              snap.caption!,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ],
      );
    }
  }

  Future<void> _showIntentShiftDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2433),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Request Intent Shift',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.pinkAccent,
                ),
                title: const Text(
                  'Romantic',
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.pop(context, 'ROMANTIC'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.group_rounded,
                  color: Colors.greenAccent,
                ),
                title: const Text(
                  'Friendship',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.pop(context, 'FRIENDSHIP'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.handshake_rounded,
                  color: Colors.lightBlueAccent,
                ),
                title: const Text(
                  'Collaborate',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.w600,
                  ),
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
          backgroundColor: const Color(0xFF1E2433),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Block & Report',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to block this user? The chat will be deleted, and you will no longer see each other. This action is permanent.',
            style: TextStyle(color: AppTheme.textSecondary),
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
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User blocked.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

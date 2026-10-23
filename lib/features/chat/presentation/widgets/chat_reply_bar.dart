import 'package:flutter/material.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/chat/domain/chat_models.dart';
import 'package:student_dating_app/features/chat/domain/chat_message_payload.dart';

class ChatReplyBar extends StatelessWidget {
  final ChatMessage replyMessage;
  final String senderName;
  final VoidCallback onCancel;

  const ChatReplyBar({
    super.key,
    required this.replyMessage,
    required this.senderName,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final previewText = ChatMessageFormatter.formatPreview(replyMessage.content);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A202C),
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor.withValues(alpha: 0.5)),
          left: const BorderSide(color: AppTheme.primaryColor, width: 3.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.reply_rounded,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to $senderName',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  previewText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppTheme.textMuted,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: onCancel,
            tooltip: 'Cancel reply',
          ),
        ],
      ),
    );
  }
}

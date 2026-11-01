import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../model/chat_message_model.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(String)? onActionTap;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getBubbleColor(isUser),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message content
                Text(
                  message.content,
                  style: primaryTextStyle(
                    color: isUser ? white : primaryTextColor,
                    size: 15,
                  ),
                ),

                // Error indicator
                if (message.type == ChatMessageType.error)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade400,
                          size: 14,
                        ),
                        4.width,
                        Text(
                          'Error',
                          style: secondaryTextStyle(
                            color: Colors.red.shade400,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              _formatTime(message.timestamp),
              style: secondaryTextStyle(size: 11),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBubbleColor(bool isUser) {
    if (isUser) {
      return appColorPrimary;
    }

    if (message.type == ChatMessageType.error) {
      return Colors.red.shade50;
    }

    return isDarkMode.value ? cardBackgroundBlackDark : appScreenBackground;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

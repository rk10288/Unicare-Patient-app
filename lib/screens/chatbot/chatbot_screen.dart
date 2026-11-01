import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/chat_gpt_loder.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'chatbot_controller.dart';
import 'components/chat_bubble_widget.dart';
import 'components/chat_quick_actions_widget.dart';

class ChatbotScreen extends StatelessWidget {
  ChatbotScreen({super.key});

  final ChatbotController controller = Get.put(ChatbotController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.chatWithOurExperts,
      actions: [
        IconButton(
          onPressed: () => _showClearChatDialog(context),
          icon: const Icon(Icons.delete_outline, color: appColorPrimary),
          tooltip: 'Clear chat',
        ),
      ],
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.messages.length +
                    (controller.isTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show typing indicator
                  if (index == controller.messages.length &&
                      controller.isTyping.value) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: ChatGPTLoadingWidget(),
                    );
                  }

                  final message = controller.messages[index];
                  return ChatBubbleWidget(
                    message: message,
                    onActionTap: controller.handleQuickAction,
                  );
                },
              ),
            ),
          ),

          // Quick actions (show only when no messages or few messages)
          Obx(() {
            if (controller.messages.length <= 2) {
              return ChatQuickActionsWidget(
                actions: controller.quickActions,
                onActionTap: controller.handleQuickAction,
              );
            }
            return const SizedBox.shrink();
          }),

          // Input area
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode.value ? fullDarkCanvasColor : white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode.value
                      ? cardBackgroundBlackDark
                      : appScreenBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.messageController,
                  focusNode: controller.focusNode,
                  textInputAction: TextInputAction.send,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: locale.value.writeHere,
                    hintStyle: secondaryTextStyle(),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
            12.width,
            // Send button
            Obx(
              () => GestureDetector(
                onTap: controller.isTyping.value
                    ? null
                    : () => controller.sendMessage(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.isTyping.value
                        ? appColorPrimary.withValues(alpha: 0.5)
                        : appColorPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showConfirmDialogCustom(
      context,
      title: 'Clear conversation?',
      subTitle: 'This will delete all messages in this chat.',
      positiveText: 'Clear',
      negativeText: locale.value.cancel,
      primaryColor: appColorPrimary,
      onAccept: (_) {
        controller.clearChat();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/chatbot_apis.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import 'model/chat_message_model.dart';

class ChatbotController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  /// Quick action suggestions for the user
  final List<Map<String, String>> quickActions = [
    {'label': 'Book Appointment', 'action': 'book'},
    {'label': 'View Services', 'action': 'services'},
    {'label': 'Find Doctors', 'action': 'doctors'},
    {'label': 'My Appointments', 'action': 'appointments'},
    {'label': 'Help', 'action': 'help'},
  ];

  @override
  void onInit() {
    super.onInit();
    _addWelcomeMessage();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  /// Add welcome message when chat starts
  void _addWelcomeMessage() {
    final userName = loginUserData.value.userName.isNotEmpty
        ? loginUserData.value.userName
        : 'there';

    messages.add(ChatMessage.bot(
      "Hello $userName! 👋\n\nI'm your UniCare Customer Support Assistant. I can help you with:\n\n"
      "• Using the Patient App\n"
      "• Finding and booking services\n"
      "• Viewing your appointments\n"
      "• Navigating the app\n\n"
      "**Note:** I can only assist with system-related questions. For medical advice, please book an appointment with a doctor.\n\n"
      "How can I assist you today?",
    ));
  }

  /// Send a message
  Future<void> sendMessage([String? quickMessage]) async {
    final message = quickMessage ?? messageController.text.trim();
    if (message.isEmpty) return;

    // Clear input field
    if (quickMessage == null) {
      messageController.clear();
    }

    // Add user message
    messages.add(ChatMessage.user(message));
    _scrollToBottom();

    // Show typing indicator
    isTyping.value = true;

    try {
      // Get response from API
      final response = await ChatbotApis.sendMessage(
        message: message,
        history:
            messages.take(10).toList(), // Send last 10 messages for context
      );

      isTyping.value = false;

      if (response.botMessage != null) {
        messages.add(response.botMessage!);
      } else {
        messages.add(ChatMessage.bot(
          "I'm sorry, I couldn't process that request. Please try again.",
          type: ChatMessageType.error,
        ));
      }
    } catch (e) {
      isTyping.value = false;
      messages.add(ChatMessage.bot(
        "Sorry, something went wrong. Please try again later.",
        type: ChatMessageType.error,
      ));
    }

    _scrollToBottom();
  }

  /// Handle quick action tap
  void handleQuickAction(String action) {
    switch (action) {
      case 'book':
        sendMessage("How do I book an appointment?");
        break;
      case 'services':
        sendMessage("What services do you offer?");
        break;
      case 'doctors':
        sendMessage("Help me find a doctor");
        break;
      case 'appointments':
        sendMessage("How can I view my appointments?");
        break;
      case 'help':
        sendMessage("I need help using the app");
        break;
      default:
        sendMessage(action);
    }
  }

  /// Clear chat history
  void clearChat() {
    messages.clear();
    _addWelcomeMessage();
  }

  /// Scroll to bottom of chat
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

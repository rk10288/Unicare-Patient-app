import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:unicare_patient/utils/app_common.dart';
import '../main.dart';
import '../network/network_utils.dart';
import '../screens/chatbot/model/chat_message_model.dart';
import '../screens/home/model/system_service_res.dart';
import '../screens/service/model/service_list_model.dart';
import '../utils/api_end_points.dart';

class ChatbotApis {
  /// Send a message to the chatbot and get a response
  static Future<ChatbotResponse> sendMessage({
    required String message,
    List<ChatMessage>? history,
  }) async {
    try {
      final response = await buildHttpResponse(
        APIEndPoints.chatbotV2Message,
        method: HttpMethodType.POST,
        request: {
          'message': message,
          'history': history?.map((e) => e.toJson()).toList() ?? [],
        },
      );

      final jsonResponse = jsonDecode(response.body);
      return ChatbotResponse.fromJson(jsonResponse);
    } catch (e) {
      // debugPrint('ChatbotApis.sendMessage error: $e');
      // Return a fallback response for offline/error scenarios
      return ChatbotResponse(
        status: false,
        message: e.toString(),
        botMessage: ChatMessage.bot(
          _getLocalResponse(message),
          type: ChatMessageType.text,
        ),
      );
    }
  }

  /// Get local response for common queries (fallback when API is unavailable)
  static String _getLocalResponse(String message) {
    final lowerMessage = message.toLowerCase();

    // Detect persona change attempts
    if (_detectPersonaChange(lowerMessage)) {
      return _getPersonaProtectionResponse();
    }

    // Detect medical advice requests
    if (_detectMedicalAdvice(lowerMessage)) {
      return _getMedicalRefusalResponse();
    }

    // Greetings
    if (_containsAny(lowerMessage, [
      'hello',
      'hi',
      'hey',
      'good morning',
      'good afternoon',
      'good evening'
    ])) {
      return "Hello! 👋 I'm your UniCare assistant. How can I help you today? You can ask me about:\n\n• Our healthcare services\n• Booking appointments\n• Finding doctors\n• Navigating the app";
    }

    // Services
    if (_containsAny(lowerMessage,
        ['service', 'services', 'what do you offer', 'treatments'])) {
      return "We offer a wide range of healthcare services including:\n\n• Home healthcare visits\n• Nursing care\n• Physiotherapy\n• Lab tests at home\n• Doctor consultations\n\nWould you like to explore our services? Tap 'View Services' in the home screen.";
    }

    // Booking
    if (_containsAny(
        lowerMessage, ['book', 'appointment', 'schedule', 'reserve'])) {
      return "To book an appointment:\n\n1. Browse our services on the home screen\n2. Select a service you're interested in\n3. Choose a clinic and doctor\n4. Pick your preferred date and time\n5. Confirm your booking\n\nNeed help finding a specific service?";
    }

    // Doctors
    if (_containsAny(
        lowerMessage, ['doctor', 'doctors', 'physician', 'specialist'])) {
      return "We have experienced doctors across various specializations. You can:\n\n• View popular doctors on the home screen\n• Filter by specialization\n• Check their availability\n• Read patient reviews\n\nWould you like me to help you find a specific type of doctor?";
    }

    // Pricing
    if (_containsAny(
        lowerMessage, ['price', 'cost', 'fee', 'charges', 'how much'])) {
      return "Service prices vary based on the type of service and duration. You can see the exact price on each service detail page before booking.\n\nWe also offer:\n• Session packages for regular treatments\n• Advance payment options\n• Multiple payment methods";
    }

    // Help
    if (_containsAny(
        lowerMessage, ['help', 'support', 'contact', 'assistance'])) {
      return "I'm here to help! You can:\n\n• Ask me questions about our services\n• Get help navigating the app\n• Contact support via WhatsApp from any service page\n\nWhat would you like help with?";
    }

    // Navigation
    if (_containsAny(
        lowerMessage, ['where', 'how to', 'find', 'navigate', 'go to'])) {
      return "Here's how to navigate the app:\n\n• 🏠 Home - Browse services and categories\n• 📅 Appointments - View your bookings\n• 💰 Wallet - Manage payments\n• 👤 Profile - Your account settings\n\nWhat are you looking for?";
    }

    // Thanks
    if (_containsAny(lowerMessage, ['thank', 'thanks', 'appreciate'])) {
      return "You're welcome! 😊 Is there anything else I can help you with?";
    }

    // Default response
    return "I understand you're asking about \"$message\". I'm here to help you with:\n\n• Information about our services\n• Booking appointments\n• Finding doctors and clinics\n• Navigating the app\n\nCould you please provide more details about what you need?";
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// Detect persona change attempts
  static bool _detectPersonaChange(String message) {
    final personaTriggers = [
      'act as',
      'pretend',
      'you are now',
      'you\'re now',
      'behave like',
      'role play',
      'roleplay',
      'be my',
      'ignore previous',
      'forget your',
      'disregard',
      'change your tone',
      'be more casual',
      'be more formal',
      'act like a doctor',
      'act like a friend',
      'be my doctor',
      'be casual',
      'be funny',
      'tell me a joke',
    ];
    return _containsAny(message, personaTriggers);
  }

  /// Detect medical advice requests
  static bool _detectMedicalAdvice(String message) {
    final medicalTriggers = [
      'diagnose',
      'diagnosis',
      'what should i take',
      'what medicine',
      'symptom',
      'i have a',
      'i feel',
      'is it normal',
      'should i be worried',
      'headache',
      'fever',
      'pain',
      'sick',
      'ill',
      'treatment for',
      'cure for',
      'remedy for',
    ];
    return _containsAny(message, medicalTriggers);
  }

  /// Get persona protection response
  static String _getPersonaProtectionResponse() {
    final whatsappNumber = appConfigs.value.whatsappSupportNumber;
    final whatsappMessage = whatsappNumber.isNotEmpty
        ? " For other assistance, please contact our support team on WhatsApp: $whatsappNumber"
        : " For other assistance, please contact our support team.";
    return "I'm here to help with clinic support only.$whatsappMessage";
  }

  /// Get medical advice refusal response
  static String _getMedicalRefusalResponse() {
    final whatsappNumber = appConfigs.value.whatsappSupportNumber;
    final whatsappMessage = whatsappNumber.isNotEmpty
        ? "\n\nFor medical concerns, please book an appointment with a doctor or contact our support team on WhatsApp: $whatsappNumber"
        : "\n\nFor medical concerns, please book an appointment with a doctor or contact our support team.";
    return "I cannot provide medical advice or diagnosis. I can only help you with:\n\n• Booking appointments\n• Finding doctors\n• Navigating the app\n• Understanding our services$whatsappMessage";
  }

  /// Search services based on query
  static Future<List<ServiceElement>> searchServices(String query) async {
    try {
      final response = await buildHttpResponse(
        '${APIEndPoints.getServiceList}?search=$query',
        method: HttpMethodType.GET,
      );

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == true && jsonResponse['data'] is List) {
        return List<ServiceElement>.from(
          jsonResponse['data'].map((x) => ServiceElement.fromJson(x)),
        );
      }
      return [];
    } catch (e) {
      // debugPrint('ChatbotApis.searchServices error: $e');
      return [];
    }
  }

  /// Get system services for context
  static Future<List<SystemService>> getSystemServices() async {
    try {
      final response = await buildHttpResponse(
        APIEndPoints.getSystemService,
        method: HttpMethodType.GET,
      );

      final jsonResponse = jsonDecode(response.body);
      return SystemServicesRes.fromJson(jsonResponse).data;
    } catch (e) {
      // debugPrint('ChatbotApis.getSystemServices error: $e');
      return [];
    }
  }
}

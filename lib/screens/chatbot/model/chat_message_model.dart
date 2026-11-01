/// Model for a single chat message
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType type;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = ChatMessageType.text,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] is String
          ? json['id']
          : DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] is String ? json['content'] : '',
      isUser: json['is_user'] is bool ? json['is_user'] : false,
      timestamp: json['timestamp'] is String
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      type: ChatMessageType.fromString(json['type']),
      metadata:
          json['metadata'] is Map<String, dynamic> ? json['metadata'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'metadata': metadata,
    };
  }

  /// Create a user message
  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  /// Create a bot message
  factory ChatMessage.bot(String content,
      {ChatMessageType type = ChatMessageType.text,
      Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      type: type,
      metadata: metadata,
    );
  }
}

/// Types of chat messages
enum ChatMessageType {
  text,
  serviceCard,
  quickActions,
  navigation,
  error;

  static ChatMessageType fromString(dynamic value) {
    if (value is String) {
      return ChatMessageType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ChatMessageType.text,
      );
    }
    return ChatMessageType.text;
  }
}

/// Quick action for the chatbot
class ChatQuickAction {
  final String id;
  final String label;
  final String action;
  final String? route;
  final Map<String, dynamic>? params;

  ChatQuickAction({
    required this.id,
    required this.label,
    required this.action,
    this.route,
    this.params,
  });

  factory ChatQuickAction.fromJson(Map<String, dynamic> json) {
    return ChatQuickAction(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      action: json['action'] ?? '',
      route: json['route'],
      params: json['params'],
    );
  }
}

/// Response from chatbot API
class ChatbotResponse {
  final bool status;
  final String message;
  final ChatMessage? botMessage;
  final List<ChatQuickAction> quickActions;

  ChatbotResponse({
    this.status = false,
    this.message = '',
    this.botMessage,
    this.quickActions = const [],
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] is String ? json['message'] : '',
      botMessage: json['bot_message'] is Map<String, dynamic>
          ? ChatMessage.fromJson(json['bot_message'])
          : (json['response'] is String
              ? ChatMessage.bot(json['response'])
              : null),
      quickActions: json['quick_actions'] is List
          ? List<ChatQuickAction>.from(
              json['quick_actions'].map((x) => ChatQuickAction.fromJson(x)))
          : [],
    );
  }
}

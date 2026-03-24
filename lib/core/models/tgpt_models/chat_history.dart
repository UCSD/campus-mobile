import 'dart:convert';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message_persistent.dart';

/// Parse a ChatHistory from JSON string
ChatHistory chatHistoryFromJson(String str) => ChatHistory.fromJson(json.decode(str));

/// Convert a ChatHistory to JSON string
String chatHistoryToJson(ChatHistory data) => json.encode(data.toJson());

/// Model for a chat history session containing all messages.
/// 
/// Used for viewing old chats and managing conversation history.
class ChatHistory {
  /// The unique session identifier
  final String sessionId;

  /// The persona ID used for this chat
  final String? personaId;

  /// Display title for the chat (e.g., first message preview or custom title)
  final String? title;

  /// Unix timestamp (milliseconds since epoch) when chat was created
  final int createdAt;

  /// Unix timestamp (milliseconds since epoch) of last activity
  final int? lastUpdatedAt;

  /// List of messages in chronological order
  final List<ChatMessagePersistent> messages;

  ChatHistory({
    required this.sessionId,
    this.personaId,
    this.title,
    required this.createdAt,
    this.lastUpdatedAt,
    required this.messages,
  });

  factory ChatHistory.fromJson(Map<String, dynamic> json) => ChatHistory(
        sessionId: json["session_id"] ?? json["sessionId"],
        personaId: json["persona_id"] ?? json["personaId"],
        title: json["title"],
        createdAt: json["created_at"] ?? json["createdAt"],
        lastUpdatedAt: json["last_updated_at"] ?? json["lastUpdatedAt"],
        messages: json["messages"] != null
            ? List<ChatMessagePersistent>.from(
                json["messages"].map((x) => ChatMessagePersistent.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "session_id": sessionId,
        "persona_id": personaId,
        "title": title,
        "created_at": createdAt,
        "last_updated_at": lastUpdatedAt,
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
      };

  /// Creates a copy with updated fields
  ChatHistory copyWith({
    String? sessionId,
    String? personaId,
    String? title,
    int? createdAt,
    int? lastUpdatedAt,
    List<ChatMessagePersistent>? messages,
  }) {
    return ChatHistory(
      sessionId: sessionId ?? this.sessionId,
      personaId: personaId ?? this.personaId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      messages: messages ?? this.messages,
    );
  }

  /// Get the most recent message in this chat
  ChatMessagePersistent? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// Get count of messages
  int get messageCount => messages.length;
}

/// Model for a list of chat history summaries (for displaying chat list)
class ChatHistorySummary {
  final String sessionId;
  final String? title;
  final int createdAt;
  final int? lastUpdatedAt;
  final String? lastMessagePreview;
  final int messageCount;

  ChatHistorySummary({
    required this.sessionId,
    this.title,
    required this.createdAt,
    this.lastUpdatedAt,
    this.lastMessagePreview,
    required this.messageCount,
  });

  factory ChatHistorySummary.fromJson(Map<String, dynamic> json) => ChatHistorySummary(
        sessionId: json["session_id"] ?? json["sessionId"],
        title: json["title"],
        createdAt: json["created_at"] ?? json["createdAt"],
        lastUpdatedAt: json["last_updated_at"] ?? json["lastUpdatedAt"],
        lastMessagePreview: json["last_message_preview"] ?? json["lastMessagePreview"],
        messageCount: json["message_count"] ?? json["messageCount"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "session_id": sessionId,
        "title": title,
        "created_at": createdAt,
        "last_updated_at": lastUpdatedAt,
        "last_message_preview": lastMessagePreview,
        "message_count": messageCount,
      };

  /// Create a summary from a full ChatHistory
  factory ChatHistorySummary.fromChatHistory(ChatHistory history) => ChatHistorySummary(
        sessionId: history.sessionId,
        title: history.title,
        createdAt: history.createdAt,
        lastUpdatedAt: history.lastUpdatedAt,
        lastMessagePreview: history.lastMessage?.text,
        messageCount: history.messageCount,
      );
}

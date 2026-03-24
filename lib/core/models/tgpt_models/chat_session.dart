import 'dart:convert';

/// Parse a ChatSession from JSON string
ChatSession chatSessionFromJson(String str) => ChatSession.fromJson(json.decode(str));

/// Convert a ChatSession to JSON string
String chatSessionToJson(ChatSession data) => json.encode(data.toJson());

/// Request model for creating a chat session via /chat/create-chat-session
class ChatSessionRequest {
  final String personaId;

  ChatSessionRequest({
    required this.personaId,
  });

  Map<String, dynamic> toJson() => {
        "persona_id": personaId,
      };
}

/// Response model for a chat session
class ChatSession {
  final String chatSessionId;
  final String? personaId;
  final DateTime? createdAt;

  ChatSession({
    required this.chatSessionId,
    this.personaId,
    this.createdAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        chatSessionId: json["chat_session_id"],
        personaId: json["persona_id"],
        createdAt: json["created_at"] != null ? DateTime.tryParse(json["created_at"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "chat_session_id": chatSessionId,
        "persona_id": personaId,
        "created_at": createdAt?.toIso8601String(),
      };
}

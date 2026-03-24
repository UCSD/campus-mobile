import 'dart:convert';

/// Parse a ChatMessageRequest from JSON string
ChatMessageRequest chatMessageRequestFromJson(String str) =>
    ChatMessageRequest.fromJson(json.decode(str));

/// Convert a ChatMessageRequest to JSON string
String chatMessageRequestToJson(ChatMessageRequest data) => json.encode(data.toJson());

/// Parse a ChatResponse from JSON string
ChatResponse chatResponseFromJson(String str) => ChatResponse.fromJson(json.decode(str));

/// Convert a ChatResponse to JSON string
String chatResponseToJson(ChatResponse data) => json.encode(data.toJson());

/// Request model for sending a chat message via /chat/send-message
/// 
/// Note: Omit [parentMessageId] for the very first query in a session.
/// For subsequent messages, set [parentMessageId] to the [reservedAssistantMessageId]
/// from the previous response.
class ChatMessageRequest {
  final String chatSessionId;
  final String message;
  final String? promptId;
  final String? parentMessageId;

  ChatMessageRequest({
    required this.chatSessionId,
    required this.message,
    this.promptId,
    this.parentMessageId,
  });

  factory ChatMessageRequest.fromJson(Map<String, dynamic> json) => ChatMessageRequest(
        chatSessionId: json["chat_session_id"],
        message: json["message"],
        promptId: json["prompt_id"],
        parentMessageId: json["parent_message_id"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "chat_session_id": chatSessionId,
      "message": message,
    };
    if (promptId != null) {
      data["prompt_id"] = promptId;
    }
    if (parentMessageId != null) {
      data["parent_message_id"] = parentMessageId;
    }
    return data;
  }
}

/// Response model for a chat message from /chat/send-message
/// 
/// Contains the [reservedAssistantMessageId] which should be used as the
/// [parentMessageId] when sending the next message in the conversation.
class ChatResponse {
  final String reservedAssistantMessageId;
  final String? content;
  final bool? isComplete;
  final String? error;

  ChatResponse({
    required this.reservedAssistantMessageId,
    this.content,
    this.isComplete,
    this.error,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
        reservedAssistantMessageId: json["reserved_assistant_message_id"] ?? json["reservedAssistantMessageId"] ?? "",
        content: json["content"],
        isComplete: json["is_complete"] ?? json["isComplete"],
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "reserved_assistant_message_id": reservedAssistantMessageId,
        "content": content,
        "is_complete": isComplete,
        "error": error,
      };
}

/// Model for a streamed chunk of the chat response
/// 
/// The API streams JSON objects; this represents a single chunk.
class ChatStreamChunk {
  final String? content;
  final bool? isComplete;
  final String? error;

  ChatStreamChunk({
    this.content,
    this.isComplete,
    this.error,
  });

  factory ChatStreamChunk.fromJson(Map<String, dynamic> json) => ChatStreamChunk(
        content: json["content"],
        isComplete: json["is_complete"] ?? json["isComplete"],
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "content": content,
        "is_complete": isComplete,
        "error": error,
      };
}

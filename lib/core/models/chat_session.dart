import 'dart:convert';

// Model for creating a chat session request
class ChatSessionCreationRequest {
  final int personaId;
  ChatSessionCreationRequest({required this.personaId});

  Map<String, dynamic> toJson() => {
        'persona_id': personaId,
      };
}

// Model for parsing the response from session creation
class CreateChatSessionID {
  final String chatSessionId;

  CreateChatSessionID({
    required this.chatSessionId,
  });

  // Parses JSON response from backend into Dart object
  factory CreateChatSessionID.fromJson(Map<String, dynamic> json) {
    return CreateChatSessionID(
      chatSessionId: json['chat_session_id'] as String,
    );
  }

  // Serializes back to JSON if needed
  Map<String, dynamic> toJson() => {
        'chat_session_id': chatSessionId,
      };
}

/// Request model for creating a chat session (matches original cma-tgpt).
class ChatSessionCreationRequest {
  final int personaId;
  final String? description;

  ChatSessionCreationRequest({
    required this.personaId,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'persona_id': personaId,
    };

    if (description != null) json['description'] = description;

    return json;
  }
}

/// Response model for chat session creation.
class CreateChatSessionID {
  final String chatSessionId;

  CreateChatSessionID({
    required this.chatSessionId,
  });

  factory CreateChatSessionID.fromJson(Map<String, dynamic> json) {
    return CreateChatSessionID(
      chatSessionId: json['chat_session_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'chat_session_id': chatSessionId,
      };
}

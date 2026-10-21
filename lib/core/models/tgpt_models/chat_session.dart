import 'dart:convert';

/// Request model for creating a chat session (matches original cma-tgpt).
class ChatSessionCreationRequest {
  final int personaId;
  final String? description;

  ChatSessionCreationRequest({required this.personaId, this.description});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'persona_id': personaId};

    if (description != null) json['description'] = description;

    return json;
  }
}

/// Response model for chat session creation.
class CreateChatSessionID {
  final String chatSessionId;

  CreateChatSessionID({required this.chatSessionId});

  factory CreateChatSessionID.fromJson(Map<String, dynamic> json) {
    return CreateChatSessionID(chatSessionId: json['chat_session_id'] as String);
  }

  /// Defensive factory that handles both Map and JSON String responses.
  /// Use this when the response format from the API is uncertain.
  factory CreateChatSessionID.fromJsonSafe(dynamic response) {
    Map<String, dynamic> json;
    if (response is Map<String, dynamic>) {
      json = response;
    } else if (response is String) {
      // Handle case where Dio returns a JSON string instead of decoded Map
      final dynamic decoded = jsonDecode(response);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      } else {
        throw FormatException('Unexpected response format: $response');
      }
    } else {
      throw FormatException('Unexpected response type: ${response.runtimeType}');
    }
    return CreateChatSessionID.fromJson(json);
  }

  Map<String, dynamic> toJson() => {'chat_session_id': chatSessionId};
}

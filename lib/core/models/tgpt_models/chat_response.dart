/// Retrieval options for the chat message request.
class RetrievalOptions {
  final String runSearch;

  RetrievalOptions({
    this.runSearch = 'always',
  });

  Map<String, dynamic> toJson() => {
        'run_search': runSearch,
      };
}

/// Request model for sending chat messages via /chat/send-message.
///
/// Simplified for mobile app usage. Fields like prompt_id and search_doc_ids
/// are always null for this app and included only for API completeness.
class BasicCreateChatMessageRequest {
  final String message;
  final String chatSessionId;
  final String? parentMessageId;
  final RetrievalOptions retrievalOptions;
  final List<dynamic> fileDescriptors;

  BasicCreateChatMessageRequest({
    required this.message,
    required this.chatSessionId,
    this.parentMessageId,
    RetrievalOptions? retrievalOptions,
    this.fileDescriptors = const [],
  }) : retrievalOptions = retrievalOptions ?? RetrievalOptions();

  Map<String, dynamic> toJson() => {
        'message': message,
        'chat_session_id': chatSessionId,
        'parent_message_id': parentMessageId,
        'retrieval_options': retrievalOptions.toJson(),
        'file_descriptors': fileDescriptors,
        'prompt_id': null,
        'search_doc_ids': null,
      };
}

// ============================================================================
// Response Models - match actual streaming API format
// ============================================================================

/// First line of API response containing message IDs.
class ChatMessageIds {
  final int userMessageId;
  final int reservedAssistantMessageId;

  ChatMessageIds({
    required this.userMessageId,
    required this.reservedAssistantMessageId,
  });

  factory ChatMessageIds.fromJson(Map<String, dynamic> json) => ChatMessageIds(
        userMessageId: json['user_message_id'],
        reservedAssistantMessageId: json['reserved_assistant_message_id'],
      );
}

/// Citation reference from citation_delta (maps [[1]] in text to source URL).
class ChatCitation {
  final int citationNum;
  final String documentId; // This is the URL

  ChatCitation({
    required this.citationNum,
    required this.documentId,
  });

  factory ChatCitation.fromJson(Map<String, dynamic> json) => ChatCitation(
        citationNum: json['citation_num'],
        documentId: json['document_id'] ?? '',
      );
}

/// Streaming chunk from chat API (newline-delimited JSON).
///
/// For mobile app, we mainly care about:
/// - message_delta: answer text tokens
/// - citation_delta: source URLs for citations
/// - stop: end of stream
class ChatStreamChunk {
  final int ind;
  final String type;
  final String? content;
  final List<ChatCitation>? citations;

  ChatStreamChunk({
    required this.ind,
    required this.type,
    this.content,
    this.citations,
  });

  factory ChatStreamChunk.fromJson(Map<String, dynamic> json) {
    final obj = json['obj'] as Map<String, dynamic>?;
    if (obj == null) {
      return ChatStreamChunk(ind: json['ind'] ?? 0, type: '');
    }

    final type = obj['type'] as String? ?? '';

    // Parse citations from citation_delta
    List<ChatCitation>? cites;
    final rawCites = obj['citations'];
    if (rawCites is List) {
      cites = rawCites
          .whereType<Map<String, dynamic>>()
          .map((c) => ChatCitation.fromJson(c))
          .toList();
    }

    return ChatStreamChunk(
      ind: json['ind'] ?? 0,
      type: type,
      content: obj['content'],
      citations: cites,
    );
  }

  bool get isStop => type == 'stop';
  bool get isMessageDelta => type == 'message_delta';
  bool get isCitationDelta => type == 'citation_delta';
}

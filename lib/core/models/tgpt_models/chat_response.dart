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
  final int? parentMessageId;
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



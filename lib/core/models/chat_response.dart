import 'dart:convert';

/// Options controlling retrieval behavior for chat messages
class RetrievalOptions {
  final String runSearch;
  final bool realTime;
  final Filters filters;

  RetrievalOptions({
    this.runSearch = 'auto',
    this.realTime = true,
    required this.filters,
  });

  Map<String, dynamic> toJson() => {
        'run_search': runSearch,
        'real_time': realTime,
        'filters': filters.toJson(),
      };
}

/// Filters for document retrieval
class Filters {
  final String? sourceType;
  final String? documentSet;
  final DateTime? timeCutoff;
  final List<dynamic> tags;

  Filters({
    this.sourceType,
    this.documentSet,
    this.timeCutoff,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'source_type': sourceType,
        'document_set': documentSet,
        'time_cutoff': timeCutoff?.toIso8601String(),
        'tags': tags,
      };
}

/// Override settings for an LLM
/// Used to specify which LLM model to use (e.g., llama-4-scout)
class LlmOverride {
  final String modelProvider;
  final String modelVersion;

  LlmOverride({
    required this.modelProvider,
    required this.modelVersion,
  });

  Map<String, dynamic> toJson() => {
        'model_provider': modelProvider,
        'model_version': modelVersion,
      };
}

/// Request payload to create or send a chat message
class BasicCreateChatMessageRequest {
  final String message;
  final String chatSessionId;
  final int? alternateAssistantId; // Optional: switch to another assistant
  final String? parentMessageId;
  final int promptId;
  final List<String>? searchDocIds;
  final List<dynamic> fileDescriptors;
  final bool regenerate;
  final RetrievalOptions retrievalOptions;
  final dynamic promptOverride;
  final LlmOverride? llmOverride;
  final bool useAgenticSearch;

  BasicCreateChatMessageRequest({
    required this.message,
    required this.chatSessionId,
    this.alternateAssistantId,
    this.parentMessageId,
    required this.promptId,
    this.searchDocIds,
    required this.fileDescriptors,
    required this.regenerate,
    required this.retrievalOptions,
    this.promptOverride,
    this.llmOverride,
    this.useAgenticSearch = false,
  });

  // Serializes object to JSON for HTTP request body
  Map<String, dynamic> toJson() => {
        'message': message,
        'chat_session_id': chatSessionId,
        'alternate_assistant_id': alternateAssistantId,
        'prompt_id': promptId,
        'search_doc_ids': searchDocIds,
        'file_descriptors': fileDescriptors,
        'regenerate': regenerate,
        'parent_message_id': parentMessageId,
        'retrieval_options': retrievalOptions.toJson(),
        'prompt_override': promptOverride,
        'llm_override': llmOverride?.toJson(),
        'use_agentic_search': useAgenticSearch,
      };
}

/// Core response model for chat messages
class ChatBasicResponse {
  /// Message text with possible `[[n]](url)` citation markers.
  String? answer;

  /// Message text without citations.
  String? answerCitationless;

  /// Any error message.
  String? errorMsg;

  /// Unique ID of this chat message.
  int? messageId;

  /// Indices of documents selected by the LLM.
  List<int> llmSelectedDocIndices;

  /// Indices of final context documents.
  List<int> finalContextDocIndices;

  /// Map of citation numbers to URLs.
  Map<String, String> citedDocuments;

  /// Additional LLM chunk indices.
  List<int> llmChunksIndices;

  ChatBasicResponse({
    this.answer,
    this.answerCitationless,
    this.errorMsg,
    this.messageId,
    List<int>? llmSelectedDocIndices,
    List<int>? finalContextDocIndices,
    Map<String, String>? citedDocuments,
    List<int>? llmChunksIndices,
  })  : llmSelectedDocIndices = llmSelectedDocIndices ?? [],
        finalContextDocIndices = finalContextDocIndices ?? [],
        citedDocuments = citedDocuments ?? {},
        llmChunksIndices = llmChunksIndices ?? [];

  /// Converts server-provided citation markers to clickable markdown links
  void renderCitationsAsHyperlinks() {
    if (answer == null || citedDocuments.isEmpty) return;
    var processed = answer!;
    citedDocuments.forEach((key, url) {
      // match the full [[key]](anything) and replace with [key](url)
      final pattern = RegExp(
        r'\[\[' + RegExp.escape(key) + r'\]\]\([^)]+\)',
      );
      processed = processed.replaceAll(pattern, '[$key]($url)');
    });
    answer = processed;
  }

  /// Factory to parse raw JSON into [ChatBasicResponse]
  factory ChatBasicResponse.fromJson(Map<String, dynamic> json) {
    List<int> parseIntList(String key) {
      final list = json[key];
      if (list is List) return list.whereType<int>().toList();
      return [];
    }

    final cited =
        json['cited_documents'] is Map ? Map<String, String>.from(json['cited_documents']) : <String, String>{};

    return ChatBasicResponse(
      answer: json['answer'] as String?,
      answerCitationless: json['answer_citationless'] as String?,
      errorMsg: json['error_msg'] as String?,
      messageId: json['message_id'] as int?,
      llmSelectedDocIndices: parseIntList('llm_selected_doc_indices'),
      finalContextDocIndices: parseIntList('final_context_doc_indices'),
      citedDocuments: cited,
      llmChunksIndices: parseIntList('llm_chunks_indices'),
    );
  }

  /// Convert back to JSON, if needed
  Map<String, dynamic> toJson() => {
        'answer': answer,
        'answer_citationless': answerCitationless,
        'error_msg': errorMsg,
        'message_id': messageId,
        'llm_selected_doc_indices': llmSelectedDocIndices,
        'final_context_doc_indices': finalContextDocIndices,
        'cited_documents': citedDocuments,
        'llm_chunks_indices': llmChunksIndices,
      };
}

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

class LlmOverride {
  final String modelProvider;
  final String modelVersion;

  // NOTE: Dev tools (e.g., red_button_service.dart) use this via BasicCreateChatMessageRequest.llmOverride.
  LlmOverride({
    required this.modelProvider,
    required this.modelVersion,
  });

  Map<String, dynamic> toJson() => {
        'model_provider': modelProvider,
        'model_version': modelVersion,
      };
}

class BasicCreateChatMessageRequest {
  final String message;
  final String chatSessionId;
  final int? alternateAssistantId;
  final String? parentMessageId;
  final int? promptId;
  final List<String>? searchDocIds;
  final List<dynamic> fileDescriptors;
  final bool regenerate;
  final RetrievalOptions retrievalOptions;
  final dynamic promptOverride;
  // NOTE: Dev tools (e.g., red_button_service.dart) pass this for diagnostics payloads.
  final LlmOverride? llmOverride;
  final bool useAgenticSearch;

  BasicCreateChatMessageRequest({
    required this.message,
    required this.chatSessionId,
    this.alternateAssistantId,
    this.parentMessageId,
    this.promptId,
    this.searchDocIds,
    required this.fileDescriptors,
    required this.regenerate,
    required this.retrievalOptions,
    this.promptOverride,
    // NOTE: Dev tools (e.g., red_button_service.dart) provide this value when testing overrides.
    this.llmOverride,
    this.useAgenticSearch = false,
  });

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
        // NOTE: Dev tools (e.g., red_button_service.dart) expect this key in serialized payloads.
        'llm_override': llmOverride?.toJson(),
        'use_agentic_search': useAgenticSearch,
      };
}

class ChatBasicResponse {
  String? answer;

  String? answerCitationless;

  String? errorMsg;

  int? messageId;

  List<int> llmSelectedDocIndices;

  List<int> finalContextDocIndices;

  Map<String, String> citedDocuments;

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

  void renderCitationsAsHyperlinks() {
    final hasAnswer = answer != null;
    final hasCitations = citedDocuments.isNotEmpty;
    if (!hasAnswer) return;
    if (!hasCitations) return;
    var processed = answer!;
    citedDocuments.forEach((key, url) {
      final pattern = RegExp(
        r'\[\[' + RegExp.escape(key) + r'\]\]\([^)]+\)',
      );
      processed = processed.replaceAll(pattern, '[$key]($url)');
    });
    answer = processed;
  }

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

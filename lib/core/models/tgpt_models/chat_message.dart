import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message_persistent.dart';

class ChatCitationReference {
  final int number;
  final String url;

  const ChatCitationReference({
    required this.number,
    required this.url,
  });

  /// Parses a citation object from legacy `citation_delta` arrays (`citation_num`)
  /// or new `citation_info` packets (`citation_number`).
  factory ChatCitationReference.fromStreamJson(Map<String, dynamic> json) {
    final Object? rawNumber = json['citation_num'] ?? json['citation_number'];
    final int? number = rawNumber is int ? rawNumber : int.tryParse(rawNumber?.toString() ?? '');

    return ChatCitationReference(
      number: number ?? 0,
      url: json['document_id']?.toString() ?? '',
    );
  }
}

class AssistantMessageContent {
  static final RegExp _relatedQuestionPattern = RegExp(
    r'^(?:[-*]\s*)?\[rq\]\s*(.*)$',
    caseSensitive: false,
  );

  const AssistantMessageContent({
    required this.markdown,
    this.relatedQuestions = const <String>[],
  });

  final String markdown;
  final List<String> relatedQuestions;

  factory AssistantMessageContent.parse(String rawText) {
    if (rawText.isEmpty) {
      return const AssistantMessageContent(markdown: '');
    }

    final List<String> answerLines = <String>[];
    final List<String> relatedQuestions = <String>[];

    for (final String line in rawText.replaceAll('\r\n', '\n').split('\n')) {
      final String trimmedLine = line.trimLeft();
      final Match? match = _relatedQuestionPattern.firstMatch(trimmedLine);

      if (match != null) {
        final String question = match.group(1)?.trim() ?? '';
        if (question.isNotEmpty) {
          relatedQuestions.add(question);
        }
        continue;
      }

      answerLines.add(line);
    }

    final List<String> normalizedAnswerLines = _trimBlankLines(answerLines);
    if (relatedQuestions.isNotEmpty && normalizedAnswerLines.isNotEmpty) {
      final String trailingLine = normalizedAnswerLines.last.trim().toLowerCase();
      if (trailingLine == 'related questions' || trailingLine == 'related questions:') {
        normalizedAnswerLines.removeLast();
      }
    }

    return AssistantMessageContent(
      markdown: _trimBlankLines(normalizedAnswerLines).join('\n'),
      relatedQuestions: List<String>.unmodifiable(relatedQuestions),
    );
  }

  static List<String> _trimBlankLines(List<String> lines) {
    final List<String> trimmedLines = List<String>.from(lines);

    while (trimmedLines.isNotEmpty && trimmedLines.first.trim().isEmpty) {
      trimmedLines.removeAt(0);
    }
    while (trimmedLines.isNotEmpty && trimmedLines.last.trim().isEmpty) {
      trimmedLines.removeLast();
    }

    return trimmedLines;
  }
}

class AssistantChatMessage {
  final String id;
  final String text;
  final DateTime createdAt;
  final bool isFromUser;
  final bool isStreaming;
  final List<ChatCitationReference> citations;

  const AssistantChatMessage({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.isFromUser,
    this.isStreaming = false,
    this.citations = const [],
  });

  AssistantChatMessage copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    bool? isFromUser,
    bool? isStreaming,
    List<ChatCitationReference>? citations,
  }) {
    return AssistantChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isFromUser: isFromUser ?? this.isFromUser,
      isStreaming: isStreaming ?? this.isStreaming,
      citations: citations ?? this.citations,
    );
  }

  AssistantMessageContent get content => AssistantMessageContent.parse(text);

  ChatMessagePersistent toPersistent({
    required String sessionId,
    required String authorId,
    String? parentMessageId,
  }) {
    return ChatMessagePersistent(
      id: id,
      text: text,
      authorId: authorId,
      createdAt: createdAt.millisecondsSinceEpoch,
      isFromUser: isFromUser,
      sessionId: sessionId,
      parentMessageId: parentMessageId,
    );
  }

  factory AssistantChatMessage.fromPersistent(ChatMessagePersistent persistent) {
    return AssistantChatMessage(
      id: persistent.id,
      text: persistent.text,
      createdAt: DateTime.fromMillisecondsSinceEpoch(persistent.createdAt),
      isFromUser: persistent.isFromUser,
    );
  }
}

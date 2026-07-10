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
  /// Line-based `[rq] question` (mobile / legacy TGPT lines).
  static final RegExp _relatedQuestionPattern = RegExp(
    r'^(?:[-*]\s*)?\[rq\]\s*(.*)$',
    caseSensitive: false,
  );

  /// Markdown links `[label](#rq)` from web-style TGPT output.
  static final RegExp _rqMarkdownLink = RegExp(r'\[([^\]\n]+)\]\(\s*#rq\s*\)');

  /// Bullet line that is only `- [label](#rq)`.
  static final RegExp _bulletRqOnlyLine = RegExp(r'^\s*[-*+]\s*\[[^\]\n]+\]\(\s*#rq\s*\)\s*$');

  const AssistantMessageContent({
    required this.markdown,
    this.relatedQuestions = const <String>[],
  });

  final String markdown;
  final List<String> relatedQuestions;

  factory AssistantMessageContent.parse(String rawText) {
    if (rawText.isEmpty) return const AssistantMessageContent(markdown: '');

    final String normalized = rawText.replaceAll('\r\n', '\n');
    final List<String> relatedQuestions = <String>[];

    for (final Match m in _rqMarkdownLink.allMatches(normalized)) {
      _addUniqueRelatedQuestion(relatedQuestions, m.group(1) ?? '');
    }

    final List<String> answerLines = <String>[];
    for (final String line in normalized.split('\n')) {
      final String trimmedLeft = line.trimLeft();
      final Match? rqLine = _relatedQuestionPattern.firstMatch(trimmedLeft);
      if (rqLine != null) {
        _addUniqueRelatedQuestion(relatedQuestions, rqLine.group(1) ?? '');
        continue;
      }
      if (_bulletRqOnlyLine.hasMatch(line)) continue;
      if (_isRelatedQuestionsHeadingLine(line)) continue;
      // Streaming: drop incomplete `[rq] ...` lines (widget avoids showing broken markers).
      if (_isPartialLegacyRelatedQuestionLine(trimmedLeft)) continue;
      answerLines.add(line);
    }

    List<String> normalizedAnswerLines = _trimBlankLines(answerLines);
    var hasRelatedQuestions = relatedQuestions.isNotEmpty;
    var hasAnswerLines = normalizedAnswerLines.isNotEmpty;
    if (hasRelatedQuestions && hasAnswerLines) {
      final String trailingLine = normalizedAnswerLines.last.trim().toLowerCase();
      if (trailingLine == 'related questions' || trailingLine == 'related questions:')
        normalizedAnswerLines.removeLast();
    }

    String markdown = _trimBlankLines(normalizedAnswerLines).join('\n');
    markdown = markdown.replaceAllMapped(_rqMarkdownLink, (Match m) => m.group(1)!.trim());
    markdown = _collapseBlankLines(markdown).trim();
    markdown = _stripTrailingRelatedQuestionsFromMarkdown(markdown, relatedQuestions);

    return AssistantMessageContent(
      markdown: markdown,
      relatedQuestions: List<String>.unmodifiable(relatedQuestions),
    );
  }

  /// TGPT web widget strips the related-questions block from the visible transcript; keep
  /// questions only in the dedicated UI ([...](#rq) hydrated separately from markdown).
  static String _stripTrailingRelatedQuestionsFromMarkdown(
    String markdown,
    List<String> relatedQuestions,
  ) {
    if (relatedQuestions.isEmpty || markdown.trim().isEmpty) return markdown;

    final List<String> lines = markdown.split('\n');
    int end = lines.length;
    while (end > 0 && lines[end - 1].trim().isEmpty) {
      end--;
    }
    if (end == 0) return '';

    int scan = end - 1;
    for (int rqIdx = relatedQuestions.length - 1; rqIdx >= 0; rqIdx--) {
      final String expected = relatedQuestions[rqIdx].trim();
      if (expected.isEmpty) return markdown;
      while (scan >= 0 && lines[scan].trim().isEmpty) {
        scan--;
      }
      if (scan < 0 || lines[scan].trim() != expected) return markdown;
      scan--;
    }
    while (scan >= 0 && lines[scan].trim().isEmpty) {
      scan--;
    }
    if (scan >= 0) {
      final String candidate = lines[scan].trim();
      if (RegExp(r'^-{3,}\s*$').hasMatch(candidate)) {
        scan--;
        while (scan >= 0 && lines[scan].trim().isEmpty) {
          scan--;
        }
      }
    }
    if (scan < 0) return '';
    final List<String> kept = lines.sublist(0, scan + 1);
    return _collapseBlankLines(_trimBlankLines(kept).join('\n')).trim();
  }

  static void _addUniqueRelatedQuestion(List<String> list, String raw) {
    final String q = raw.trim();
    if (q.isEmpty) return;
    if (!list.contains(q)) list.add(q);
  }

  static bool _isPartialLegacyRelatedQuestionLine(String trimmedLeft) {
    if (!trimmedLeft.startsWith('[rq')) return false;
    if (_relatedQuestionPattern.hasMatch(trimmedLeft)) return false;
    return true;
  }

  static bool _isRelatedQuestionsHeadingLine(String line) {
    final String t = line.trim();
    if (t.isEmpty) return false;
    if (RegExp(r'^\*{0,2}\s*Related Questions\s*\*{0,2}\s*:?\s*$', caseSensitive: false).hasMatch(t)) return true;
    if (RegExp(r'^#+\s*Related Questions\s*:?\s*$', caseSensitive: false).hasMatch(t)) return true;
    return false;
  }

  static String _collapseBlankLines(String text) => text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

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

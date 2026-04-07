import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message_persistent.dart';

enum AssistantChatFeedback {
  upvote,
  downvote,
}

class AssistantChatCitation {
  final int number;
  final String url;

  const AssistantChatCitation({
    required this.number,
    required this.url,
  });
}

class AssistantChatMessage {
  final String id;
  final String text;
  final DateTime createdAt;
  final bool isFromUser;
  final bool isStreaming;
  final List<AssistantChatCitation> citations;
  final AssistantChatFeedback? feedback;

  const AssistantChatMessage({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.isFromUser,
    this.isStreaming = false,
    this.citations = const [],
    this.feedback,
  });

  AssistantChatMessage copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    bool? isFromUser,
    bool? isStreaming,
    List<AssistantChatCitation>? citations,
    AssistantChatFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return AssistantChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isFromUser: isFromUser ?? this.isFromUser,
      isStreaming: isStreaming ?? this.isStreaming,
      citations: citations ?? this.citations,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }

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

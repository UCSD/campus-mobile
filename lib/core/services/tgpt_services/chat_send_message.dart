import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_response.dart';

/// Shared helpers for building chat message requests.
///
/// Streaming requests are sent by [ChatMessageStreamService]. This file keeps
/// the payload builder in one place so the request shape stays consistent.
class ChatMessageService {
  const ChatMessageService._();

  /// Build the request body for sending a message.
  ///
  /// Shared logic that can be used anywhere a `/chat/send-message` payload is
  /// needed.
  static String buildRequestBody({
    required String message,
    required String chatSessionId,
    int? parentMessageId,
  }) {
    final req = BasicCreateChatMessageRequest(
      message: message,
      chatSessionId: chatSessionId,
      parentMessageId: parentMessageId,
      retrievalOptions: RetrievalOptions(runSearch: 'always'),
      fileDescriptors: const [],
    );
    return json.encode(req.toJson());
  }
}

import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_response.dart';

/// Shared helpers for building chat message requests.
///
/// Streaming requests are sent by [ChatMessageStreamService]. This file keeps
/// the payload builder in one place so the request shape stays consistent.
class ChatMessageService {
  const ChatMessageService._();

  /// Build the request body for sending a message.
  static String buildRequestBody({
    required String message,
    required String chatSessionId,
    int? parentMessageId,
    required String url,
  }) {
    final req = BasicCreateChatMessageRequest(
      message: message,
      chatSessionId: chatSessionId,
      parentMessageId: parentMessageId,
      url: url,
    );
    return json.encode(req.toJson());
  }
}

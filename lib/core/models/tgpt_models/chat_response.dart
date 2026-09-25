/// Request model for sending chat messages via the TGPT chat API.
///
/// The server rejects unknown/extra fields (`extra_forbidden`); only send
/// keys the current schema allows (aligned with the web widget payload).
class BasicCreateChatMessageRequest {
  final String message;
  final String chatSessionId;
  final int? parentMessageId;

  /// TGPT web widget sends `window.location.href`; mobile uses a stable context URL.
  final String url;

  BasicCreateChatMessageRequest({
    required this.message,
    required this.chatSessionId,
    this.parentMessageId,
    required this.url,
  });

  Map<String, dynamic> toJson() => {
    'message': message,
    'chat_session_id': chatSessionId,
    'parent_message_id': parentMessageId,
    'url': url,
  };
}

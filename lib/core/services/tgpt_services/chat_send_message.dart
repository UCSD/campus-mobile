import 'dart:convert';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';

/// Service for sending chat messages via the TGPT API.
///
/// This is a simple POST helper that sends messages and returns raw responses.
/// For real-time streaming UI, use [ChatMessageStreamService] instead.
class ChatMessageService {
  final UserDataProvider _userDataProvider;
  String? _error;
  bool _hasRetried = false;

  /// Default headers for POST requests
  final Map<String, String> headers = {
    "accept": "application/json",
    "content-type": "application/json",
  };

  ChatMessageService(this._userDataProvider);

  /// Build the request body for sending a message.
  ///
  /// Shared logic that can be used by both this service and streaming service.
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

  /// Send a message and return the raw response string.
  ///
  /// [parentMessageId] - Omit (null) for the first message in a conversation.
  /// For subsequent messages, use the `reserved_assistant_message_id` from the
  /// previous response to maintain conversation threading.
  ///
  /// Returns the raw newline-delimited JSON response for custom parsing,
  /// or null on error.
  Future<String?> sendMessage({
    required String message,
    required String chatSessionId,
    int? parentMessageId,
  }) async {
    _error = null;

    try {
      // Set auth header based on login state
      if (_userDataProvider.isLoggedIn) {
        headers['Authorization'] = 'Bearer ${_userDataProvider.authenticationModel.accessToken}';
      } else {
        headers['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
      }

      final endpoint = dotenv.env['CHAT_SEND_MESSAGE_ENDPOINT'];
      if (endpoint == null) {
        _error = 'No valid endpoint found.';
        return null;
      }

      final body = buildRequestBody(
        message: message,
        chatSessionId: chatSessionId,
        parentMessageId: parentMessageId,
      );

      final raw = await NetworkHelper.authorizedPost(endpoint, headers, body);
      return raw is String ? raw : raw.toString();
    } catch (e) {
      // Retry once on 401 with refreshed token
      if (!_hasRetried && e.toString().contains("401")) {
        _hasRetried = true;

        final bool refreshed = await NetworkHelper.getNewToken(headers);
        if (refreshed) {
          return await sendMessage(
            message: message,
            chatSessionId: chatSessionId,
            parentMessageId: parentMessageId,
          );
        } else {
          _hasRetried = false;
          return null;
        }
      }

      _error = e.toString();
      _hasRetried = false;
      return null;
    }
  }

  String? get error => _error;
}

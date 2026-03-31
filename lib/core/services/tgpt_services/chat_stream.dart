import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_send_message.dart';

/// Streaming chunk data for real-time chat display.
class StreamingChatChunk {
  final String delta; // incremental token text
  final bool done; // end-of-stream marker
  final int? messageId; // reserved_assistant_message_id for threading

  const StreamingChatChunk({
    required this.delta,
    this.done = false,
    this.messageId,
  });
}

/// Service for streaming chat messages from the TGPT API.
///
/// Uses Dio to stream responses and yields [StreamingChatChunk] objects
/// for real-time UI updates as tokens arrive.
class ChatMessageStreamService {
  final UserDataProvider _userDataProvider;
  ChatMessageStreamService(this._userDataProvider);

  /// Stream chat messages from the API.
  ///
  /// Yields [StreamingChatChunk] for each piece of the response,
  /// allowing real-time UI updates as tokens arrive.
  ///
  /// [parentMessageId] - Omit (null) for first message, use previous
  /// response's messageId for follow-ups.
  Stream<StreamingChatChunk> streamMessage({
    required String message,
    required String chatSessionId,
    int? parentMessageId,
  }) async* {
    // Prepare headers
    final headers = <String, String>{
      "accept": "application/json",
      "content-type": "application/json",
    };
    if (_userDataProvider.isLoggedIn) {
      headers['Authorization'] = 'Bearer ${_userDataProvider.authenticationModel.accessToken}';
    } else {
      headers['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
    }

    final endpoint = dotenv.env['CHAT_SEND_MESSAGE_ENDPOINT'];
    if (endpoint == null) {
      yield const StreamingChatChunk(delta: 'Error: No endpoint configured', done: true);
      return;
    }

    // Build request body using shared helper
    final body = ChatMessageService.buildRequestBody(
      message: message,
      chatSessionId: chatSessionId,
      parentMessageId: parentMessageId,
    );

    final dio = Dio();
    dio.options.responseType = ResponseType.stream;
    dio.options.headers = headers;

    try {
      final response = await dio.post<ResponseBody>(endpoint, data: body);

      if (response.data == null) {
        yield const StreamingChatChunk(delta: 'No response received.', done: true);
        return;
      }

      String buffer = '';
      bool messageIdEmitted = false;

      await for (final chunk in response.data!.stream) {
        buffer += utf8.decode(chunk);

        // Process complete lines (newline-delimited JSON)
        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          if (line.isEmpty) continue;

          try {
            final json = jsonDecode(line) as Map<String, dynamic>;

            // First line: extract message ID for threading
            // {"user_message_id": 80067, "reserved_assistant_message_id": 80068}
            if (!messageIdEmitted && json.containsKey('reserved_assistant_message_id')) {
              messageIdEmitted = true;
              yield StreamingChatChunk(
                delta: '',
                messageId: json['reserved_assistant_message_id'] as int,
              );
              continue;
            }

            // Message content: {"ind": 1, "obj": {"type": "message_delta", "content": "..."}}
            final obj = json['obj'] as Map<String, dynamic>?;
            if (obj != null) {
              final type = obj['type'] as String?;

              // Stop signal
              if (type == 'stop') {
                yield const StreamingChatChunk(delta: '', done: true);
                return;
              }

              // Token delta - the actual streaming content
              if (type == 'message_delta') {
                final content = obj['content'] as String?;
                if (content != null && content.isNotEmpty) yield StreamingChatChunk(delta: content);
              }
            }
          } catch (_) {
            // Skip malformed lines
          }
        }
      }

      yield const StreamingChatChunk(delta: '', done: true);
    } catch (e) {
      yield StreamingChatChunk(delta: 'Error: $e', done: true);
    } finally {
      dio.close();
    }
  }
}

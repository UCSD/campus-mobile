/// TGPT Streaming Chat Service
///
/// Required .env variables:
/// - CHAT_SEND_MESSAGE_ENDPOINT: URL for sending/streaming chat messages
/// - MOBILE_APP_PUBLIC_DATA_KEY: Public API key for unauthenticated users
///
/// Related .env variables (used by other TGPT services):
/// - CHAT_CREATE_SESSION_ENDPOINT: URL for creating chat sessions
/// - TGPT_PERSONA_ID: Persona ID for chat sessions (optional, defaults to 1)
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_send_message.dart';

/// A citation reference linking a citation number to a document URL.
///
/// Parsed from `citation_delta` events in the stream:
/// ```json
/// {"ind": 3, "obj": {"type": "citation_delta", "citations": [
///   {"citation_num": 1, "document_id": "https://example.com/page"}
/// ]}}
/// ```
class StreamingCitation {
  final int citationNum;
  final String documentId; // typically a URL

  const StreamingCitation({
    required this.citationNum,
    required this.documentId,
  });

  factory StreamingCitation.fromJson(Map<String, dynamic> json) {
    return StreamingCitation(
      citationNum: json['citation_num'] as int,
      documentId: json['document_id'] as String,
    );
  }
}

/// Streaming chunk data for real-time chat display.
class StreamingChatChunk {
  final String delta; // incremental token text
  final bool done; // end-of-stream marker
  final int? messageId; // reserved_assistant_message_id for threading
  final List<StreamingCitation>? citations; // citation references (at end of stream)

  const StreamingChatChunk({
    required this.delta,
    this.done = false,
    this.messageId,
    this.citations,
  });
}

/// Service for streaming chat messages from the TGPT API.
///
/// Uses Dio to stream responses and yields [StreamingChatChunk] objects
/// for real-time UI updates as tokens arrive.
///
/// Note: Streaming uses a long receiveTimeout (5 minutes) since SSE responses
/// can take time. A 401 will trigger one retry with a refreshed token.
class ChatMessageStreamService {
  final UserDataProvider _userDataProvider;
  bool _hasRetried = false;

  /// Streaming timeout configuration.
  /// connectTimeout: reasonable limit to establish connection.
  /// receiveTimeout: long/zero for open SSE streams that may take minutes.
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(minutes: 5);

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
    // Build fresh headers per request to avoid race conditions
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
    // Use long timeouts for streaming - SSE responses can take minutes
    dio.options.connectTimeout = _connectTimeout;
    dio.options.receiveTimeout = _receiveTimeout;

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

          // Strip SSE "data:" prefix if present (some proxies emit SSE framing)
          String jsonLine = line;
          if (jsonLine.startsWith('data:')) {
            jsonLine = jsonLine.substring(5).trimLeft();
            if (jsonLine.isEmpty) continue;
          }

          try {
            final json = jsonDecode(jsonLine) as Map<String, dynamic>;

            // First line: extract message ID for threading
            // {"user_message_id": 80067, "reserved_assistant_message_id": 80068}
            if (!messageIdEmitted && json.containsKey('reserved_assistant_message_id')) {
              messageIdEmitted = true;
              // Handle both int and String types for reserved_assistant_message_id
              final rawId = json['reserved_assistant_message_id'];
              final int? messageId = rawId is int ? rawId : int.tryParse(rawId.toString());
              yield StreamingChatChunk(
                delta: '',
                messageId: messageId,
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

              // Citation data - maps citation numbers to document IDs (URLs)
              if (type == 'citation_delta') {
                final citationsList = obj['citations'] as List<dynamic>?;
                if (citationsList != null && citationsList.isNotEmpty) {
                  final citations = citationsList
                      .whereType<Map<String, dynamic>>()
                      .map((c) => StreamingCitation.fromJson(c))
                      .toList();
                  yield StreamingChatChunk(delta: '', citations: citations);
                }
              }
            }
          } catch (_) {
            // Skip malformed lines
          }
        }
      }

      yield const StreamingChatChunk(delta: '', done: true);
    } on DioException catch (e) {
      // Retry once on 401 with refreshed token (align with send/session behavior)
      if (!_hasRetried && e.response?.statusCode == 401) {
        _hasRetried = true;
        dio.close();

        final bool refreshed = await NetworkHelper.getNewToken(headers);
        if (refreshed) {
          // Restart stream with refreshed token
          yield* streamMessage(
            message: message,
            chatSessionId: chatSessionId,
            parentMessageId: parentMessageId,
          );
          _hasRetried = false;
          return;
        }
      }
      _hasRetried = false;
      yield StreamingChatChunk(delta: 'Error: $e', done: true);
    } catch (e) {
      _hasRetried = false;
      yield StreamingChatChunk(delta: 'Error: $e', done: true);
    } finally {
      dio.close();
    }
  }
}

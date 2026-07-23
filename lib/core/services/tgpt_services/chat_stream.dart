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

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_send_message.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/tgpt_error_message.dart';

/// Streaming chunk data for real-time chat display.
class StreamingChatChunk {
  final String delta; // incremental token text
  final bool done; // end-of-stream marker
  final int? messageId; // reserved_assistant_message_id for threading
  final List<ChatCitationReference>? citations; // citation references (at end of stream)

  const StreamingChatChunk({
    required this.delta,
    this.done = false,
    this.messageId,
    this.citations,
  });
}

/// Merges search/retrieval documents into [documentIdToUrl] so [citation_info] can resolve URLs.
void _mergeDocumentsForUrls(Map<String, String> documentIdToUrl, dynamic raw) {
  if (raw is! List<dynamic>) return;
  for (final Object? item in raw) {
    if (item is! Map<String, dynamic>) continue;
    final Object? id = item['document_id'] ?? item['id'] ?? item['semantic_identifier'] ?? item['url'];
    if (id == null) continue;
    final String idStr = id.toString();
    final Object? urlCandidate = item['url'] ?? item['source_url'] ?? item['document_id'] ?? id;
    documentIdToUrl[idStr] = urlCandidate.toString();
  }
}

List<ChatCitationReference> _sortedCitations(Map<int, ChatCitationReference> byNumber) {
  final List<int> keys = byNumber.keys.toList()..sort();
  return keys.map((int k) => byNumber[k]!).toList();
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
  static const Duration _CONNECT_TIMEOUT = Duration(seconds: 30);
  static const Duration _RECEIVE_TIMEOUT = Duration(minutes: 5);

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
      yield const StreamingChatChunk(delta: ErrorConstants.TRITONGPT_UNAVAILABLE, done: true);
      return;
    }

    final String? rawContextUrl = dotenv.env['TGPT_CHAT_SEND_CONTEXT_URL'];
    final String sendContextUrl =
        (rawContextUrl != null && rawContextUrl.trim().isNotEmpty) ? rawContextUrl.trim() : 'https://mobile.ucsd.edu/';

    // Build request body using shared helper (includes `url` per TGPT web widget contract)
    final body = ChatMessageService.buildRequestBody(
      message: message,
      chatSessionId: chatSessionId,
      parentMessageId: parentMessageId,
      url: sendContextUrl,
    );

    final dio = Dio();
    dio.options.responseType = ResponseType.stream;
    dio.options.headers = headers;
    // Use long timeouts for streaming - SSE responses can take minutes
    dio.options.connectTimeout = _CONNECT_TIMEOUT;
    dio.options.receiveTimeout = _RECEIVE_TIMEOUT;

    try {
      final response = await dio.post<ResponseBody>(endpoint, data: body);

      if (response.data == null) {
        yield const StreamingChatChunk(delta: ErrorConstants.TRITONGPT_UNAVAILABLE, done: true);
        return;
      }

      String buffer = '';
      final Map<int, ChatCitationReference> citationByNumber = <int, ChatCitationReference>{};
      final Map<String, String> documentIdToUrl = <String, String>{};

      await for (final chunk in response.data!.stream) {
        buffer += utf8.decode(chunk);

        // Process complete lines (newline-delimited JSON)
        while (buffer.contains('\n')) {
          final int newlineIndex = buffer.indexOf('\n');
          final String line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          if (line.isEmpty) continue;

          // Strip SSE "data:" prefix if present (some proxies emit SSE framing)
          String jsonLine = line;
          if (jsonLine.startsWith('data:')) {
            jsonLine = jsonLine.substring(5).trimLeft();
            if (jsonLine.isEmpty) continue;
          }

          try {
            final Map<String, dynamic> json = jsonDecode(jsonLine) as Map<String, dynamic>;

            final Map<String, dynamic>? obj = json['obj'] as Map<String, dynamic>?;
            final Object? rawReserved = json['reserved_assistant_message_id'] ?? obj?['reserved_assistant_message_id'];
            if (rawReserved != null) {
              final int? messageId = rawReserved is int ? rawReserved : int.tryParse(rawReserved.toString());
              if (messageId != null) yield StreamingChatChunk(delta: '', messageId: messageId);
            }

            // Optional legacy root field (some streams still emit it)
            final Object? answerPiece = json['answer_piece'];
            var hasValidAnswerPiece = answerPiece is String && answerPiece.isNotEmpty;
            if (hasValidAnswerPiece) yield StreamingChatChunk(delta: answerPiece);

            _mergeDocumentsForUrls(documentIdToUrl, json['top_documents']);

            if (obj != null) {
              final String? type = obj['type'] as String?;

              if (type == 'stop') {
                yield const StreamingChatChunk(delta: '', done: true);
                return;
              }

              if (type == 'message_start') _mergeDocumentsForUrls(documentIdToUrl, obj['final_documents']);

              if (type == 'message_delta') {
                final String? content = obj['content'] as String?;
                var hasValidContent = content != null && content.isNotEmpty;
                if (hasValidContent) yield StreamingChatChunk(delta: content);
              }

              // New schema: one citation per packet
              if (type == 'citation_info') {
                final String? docId = obj['document_id']?.toString();
                final Object? rawNum = obj['citation_number'];
                final int? num = rawNum is int ? rawNum : int.tryParse(rawNum?.toString() ?? '');
                var hasDocId = docId != null && docId.isNotEmpty;
                var hasNum = num != null && num > 0;
                if (hasDocId && hasNum) {
                  final String url = documentIdToUrl[docId] ?? docId;
                  citationByNumber[num] = ChatCitationReference(number: num, url: url);
                  yield StreamingChatChunk(delta: '', citations: _sortedCitations(citationByNumber));
                }
              }

              // Legacy: batch citation list
              if (type == 'citation_delta') {
                final List<dynamic>? citationsList = obj['citations'] as List<dynamic>?;
                var hasCitationsList = citationsList != null;
                var isCitationsListNotEmpty = citationsList?.isNotEmpty ?? false;
                if (hasCitationsList && isCitationsListNotEmpty) {
                  for (final Map<String, dynamic> row in citationsList.whereType<Map<String, dynamic>>()) {
                    final ChatCitationReference ref = ChatCitationReference.fromStreamJson(row);
                    var isUrlNotEmpty = ref.url.isNotEmpty;
                    var isNumberPositive = ref.number > 0;
                    if (isUrlNotEmpty && isNumberPositive) citationByNumber[ref.number] = ref;
                  }
                  yield StreamingChatChunk(delta: '', citations: _sortedCitations(citationByNumber));
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
      var isNotRetried = !_hasRetried;
      var has401Status = e.response?.statusCode == 401;
      if (isNotRetried && has401Status) {
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
      yield StreamingChatChunk(delta: await tgptErrorMessageForDio(e), done: true);
    } catch (e) {
      _hasRetried = false;
      final String delta = e is DioException ? await tgptErrorMessageForDio(e) : tgptErrorMessageFor(e);
      yield StreamingChatChunk(delta: delta, done: true);
    } finally {
      dio.close();
    }
  }
}

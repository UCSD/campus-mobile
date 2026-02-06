import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:campus_mobile_experimental/core/providers/user.dart';

class ChatStreamChunk {
  final String delta; // incremental token text (if any)
  final bool done; // end-of-stream marker
  final String? fullMessage; // final full assistant message (if provided)
  final int? messageId; // server message_id (optional)
  const ChatStreamChunk({
    required this.delta,
    this.done = false,
    this.fullMessage,
    this.messageId,
  });
}

class ChatMessageStreamService {
  final UserDataProvider _userDataProvider;
  ChatMessageStreamService(this._userDataProvider);

  Future<({Uri uri, Map<String, String> headers})> _prepareRequest() async {
    final headers = <String, String>{
      "accept": "application/json",
      "content-type": "application/json",
    };

    if (_userDataProvider.isLoggedIn) {
      final endpoint = dotenv.env['CHAT_SEND_MESSAGE_ENDPOINT'];
      final hasProxyEndpoint = endpoint != null && endpoint.contains('tgpt-mobileproxy');
      if (hasProxyEndpoint) headers['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
      return (uri: Uri.parse(endpoint!), headers: headers);
    } else {
      final endpoint = dotenv.env['CHAT_SEND_MESSAGE_ENDPOINT'];
      headers['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
      return (uri: Uri.parse(endpoint!), headers: headers);
    }
  }

  /// Extract ONLY token deltas from payloads.
  /// IMPORTANT: Do NOT treat "message" (final full text) as a delta.
  String _extractDeltaFromPayload(String payload) {
    try {
      final j = jsonDecode(payload);

      final obj = j is Map<String, dynamic> ? j['obj'] : null;
      if (obj is Map<String, dynamic>) {
        final objType = obj['type'];
        final isDeltaType = objType == 'message_delta';
        if (isDeltaType) {
          final contentValue = obj['content'];
          if (contentValue is String) if (contentValue.isNotEmpty) return contentValue;
        }
      }

      for (final k in const ['delta', 'content', 'text', 'answer', 'answer_piece']) {
        final v = j[k];
        if (v is String) if (v.isNotEmpty) return v;
      }

      if (j['choices'] is List) {
        final choices = j['choices'] as List;
        if (choices.isNotEmpty) {
          final c0 = choices[0];
          final d = (c0['delta'] ?? c0['message'] ?? {}) as Map<String, dynamic>;
          final content = d['content'] ?? d['text'];
          if (content is String) if (content.isNotEmpty) return content;
        }
      }

      return '';
    } catch (_) {
      return payload;
    }
  }

  bool _isDone(String payload) {
    try {
      final j = jsonDecode(payload);
      if (j['done'] == true) return true;
      if (j['finish_reason'] == 'stop') return true;
      if (j['event'] == 'end') return true;
      final obj = j is Map<String, dynamic> ? j['obj'] : null;
      if (obj is Map<String, dynamic>) if (obj['type'] == 'stop') return true;
    } catch (_) {}
    return false;
  }

  int? _extractMessageIdFromPayload(Map<String, dynamic> j) {
    final candidates = [
      j['reserved_assistant_message_id'],
      j['assistant_message_id'],
      j['message_id'],
    ];
    for (final c in candidates) {
      if (c is int) return c;
      if (c is String) {
        final parsed = int.tryParse(c);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  Stream<ChatStreamChunk> streamMessage({
    required String message,
    required String chatSessionId,
    int? alternateAssistantId,
    int? promptId,
    List<dynamic>? searchDocIds,
    List<dynamic>? fileDescriptors,
    bool? regenerate,
    String? parentMessageId,
    Map<String, dynamic>? retrievalOptions,
    Map<String, dynamic>? llmOverride,
    bool? useAgenticSearch,
    String? promptOverride,
    Map<String, dynamic>? fullPayloadOverride,
  }) async* {
    final prep = await _prepareRequest();
    final uri = prep.uri;
    final headers = prep.headers;

    Map<String, dynamic> reqPayload;
    if (fullPayloadOverride != null) {
      reqPayload = fullPayloadOverride;
    } else {
      reqPayload = {
        "message": message,
        "chat_session_id": chatSessionId,
        "parent_message_id": null,
        "prompt_id": null,
        "search_doc_ids": null,
        "retrieval_options": {"run_search": "auto", "real_time": true, "filters": {}}
      };
    }

    final body = jsonEncode(reqPayload);

    final req = http.Request('POST', uri)
      ..headers.addAll(headers)
      ..body = body;

    final client = http.Client();
    http.StreamedResponse res;

    try {
      res = await client.send(req);

      final stream = res.stream.transform(utf8.decoder).transform(const LineSplitter());

      bool gotResponse = false;
      int chunkCount = 0;
      bool messageIdEmitted = false;

      await for (final rawLine in stream) {
        final line = rawLine.trim();
        if (line.isEmpty) continue;

        final payloadLine = line.startsWith('data:') ? line.substring(5).trim() : line;

        if (_isDone(payloadLine)) {
          yield const ChatStreamChunk(delta: '', done: true);
          break;
        }

        Map<String, dynamic>? j;
        final looksJson = payloadLine.startsWith('{') && payloadLine.endsWith('}');
        if (looksJson) {
          try {
            j = jsonDecode(payloadLine) as Map<String, dynamic>;
          } catch (_) {}
        }

        if (j != null) {
          if (!messageIdEmitted) {
            final msgId = _extractMessageIdFromPayload(j);
            if (msgId != null) {
              messageIdEmitted = true;
              yield ChatStreamChunk(delta: '', messageId: msgId, done: false);
            }
          }

          if (j['answer_piece'] is String) {
            final delta = j['answer_piece'] as String;
            if (delta.isNotEmpty) {
              gotResponse = true;
              chunkCount++;
              yield ChatStreamChunk(delta: delta, done: false);
            }
            continue;
          }

          if (j['message'] is String) {
            final full = j['message'] as String;
            final msgId = (j['message_id'] is int) ? j['message_id'] as int : null;
            gotResponse = true;
            yield ChatStreamChunk(delta: '', fullMessage: full, messageId: msgId, done: false);
            continue;
          }
        }

        final delta = _extractDeltaFromPayload(payloadLine);
        if (delta.isNotEmpty) {
          gotResponse = true;
          chunkCount++;
          yield ChatStreamChunk(delta: delta, done: false);
        }
      }

      if (!gotResponse) yield const ChatStreamChunk(delta: 'No response received from the assistant.', done: true);

      yield const ChatStreamChunk(delta: '', done: true);
    } catch (e) {
      yield ChatStreamChunk(delta: 'Error: $e', done: true);
    } finally {
      client.close();
    }
  }
}

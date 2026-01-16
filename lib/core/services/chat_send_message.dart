import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/chat_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart'; // ai

// Service responsible for sending chat messages to TritonGPT/dev3 backend via WSO2
class ChatMessageService {
  bool _isLoading = false;
  String? _error;
  final UserDataProvider _userDataProvider;

  ChatMessageService(this._userDataProvider);

  // Sends a chat message to the backend
  Future<ChatBasicResponse?> sendMessage({
    required String message,
    required String chatSessionId,
  }) async {
    _error = null;
    _isLoading = true;

    try {
      final Map<String, String> headers = {
        "accept": "application/json",
        "content-type": "application/json",
        'Authorization': 'Bearer ${_userDataProvider.authenticationModel.accessToken}'
      };

      // final endpoint = dotenv.get('CHAT_SEND_MESSAGE_SIMPLE_API_ENDPOINT');
      final endpoint = "https://api-qa.ucsd.edu:8243/tgpt-mobileproxy/1.0.0/chat/send-message";

      final Map<String, dynamic> payload = {
        "chat_session_id": chatSessionId,
        "message": message,
        "retrieval_options": {
          "run_search": "always",
        },
        "file_descriptors": <dynamic>[],
      };

      final body = json.encode(payload);

      final dio = Dio(BaseOptions(
        connectTimeout: NetworkHelper.DEFAULT_TIMEOUT,
        receiveTimeout: NetworkHelper.DEFAULT_TIMEOUT,
        headers: headers,
        responseType: ResponseType.plain,
      ));

      final response = await dio.post(endpoint, data: body);

      if (response.statusCode != 200 && response.statusCode != 201)
        throw Exception('Non-success status: ${response.statusCode}, body: ${response.data}');

      final raw = response.data as String;
      print('📥 raw (streaming): $raw');

      // Split into non-empty lines
      final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

      if (lines.isEmpty) throw const FormatException('Empty streaming response');

      final buffer = StringBuffer();

      for (final line in lines) {
        Map<String, dynamic> obj;
        try {
          obj = json.decode(line) as Map<String, dynamic>;
        } catch (e) {
          // If something isn't JSON, just skip it instead of crashing
          print('Skipping non-JSON line: $line');
          continue;
        }

        final ind = obj['ind'];
        final inner = obj['obj'] as Map<String, dynamic>?;

        if (ind == 1 && inner != null && inner['type'] == 'message_delta') {
          final delta = inner['content'] as String? ?? '';
          buffer.write(delta);
        }
      }

      var answer = buffer.toString().trim();
      if (answer.isEmpty)
        throw const FormatException(
          'Could not find any assistant message_delta chunks in stream',
        );

      answer = answer.replaceAll('[rq]', '');

      final respJson = <String, dynamic>{
        'answer': answer,
      };

      final resp = ChatBasicResponse.fromJson(respJson)..renderCitationsAsHyperlinks();

      return resp;
    } catch (e, st) {
      print(st);
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  String? get error => _error;
  bool get isLoading => _isLoading;
}

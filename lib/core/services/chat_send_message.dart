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

    // replace {key} with actual auth key from wso2
    try {
      final Map<String, String> headers = {
        "accept": "application/json",
        "content-type": "application/json",
        'Authorization':
            'Bearer eyJ4NXQiOiJNR1UzWVRkbU1XUmpZemxpTTJZNFpqY3hORGM1TkRNMlkyWTVNMlF5TlRZek9EZGhaV1kyTWciLCJraWQiOiJZVFZtT1RCbU1tTXpOemRtWVRBeU5UWmpNbVk1WlRReU56VXdaamN5TnpZME4yUTVPR1U1TURJNFlXWmpaamcxTnpnNE5UazVNMlF3TUdRd1ltSTNPQV9SUzI1NiIsInR5cCI6ImF0K2p3dCIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJhbncwNzUiLCJhdXQiOiJBUFBMSUNBVElPTiIsImF1ZCI6IkdtVEE4ZmhCR0o4V3hxVGNBemdMdlRYbEY1b2EiLCJuYmYiOjE3Njg1MjAzMTcsImF6cCI6IkdtVEE4ZmhCR0o4V3hxVGNBemdMdlRYbEY1b2EiLCJzY29wZSI6ImRlZmF1bHQiLCJpc3MiOiJodHRwczpcL1wvYXBpLXFhLnVjc2QuZWR1XC9vYXV0aDJcL3Rva2VuIiwicmVhbG0iOnsic2lnbmluZ190ZW5hbnQiOiJjYXJib24uc3VwZXIifSwiZXhwIjoxNzY4NTIzOTE3LCJpYXQiOjE3Njg1MjAzMTcsImp0aSI6IjM0ZTZiN2IyLTQ2MWMtNDk5OS1hMmUzLTk2ZTQ5NzQ1Y2RhZCJ9.JXgyX1Pm8H5_dkDIoySzypVB_nStfNQhzaIajSowVUXdfGwngWUdFIj71cNjgWmrUbNttAUEPC6fFXbjavhuhTgBDIUBPnqJq8V5YYFFYkxvuVVL-4b6XCnleP6zKGIiaZorvfgoFI0GAtbNzu-7bL-vqTW48VQcP6_VG_5T89XM3a_NM6hVFOUP-16D1W1PLn8gkIPTnmlPJ4lB46soOBbx8iaH_-ZoRiO6wwKuD29jsnXOz40pfhsdNMto9OSVyNLC9zrRE4wQW3OZMjvBO-Fa6YUM7XecGITDkzRc05aTjeZu5ZckE4UokRsMVy1DVYSphch-HGnM0fElvpoDBw',
      };

      // final endpoint = dotenv.get('CHAT_SEND_MESSAGE_SIMPLE_API_ENDPOINT');
      final endpoint = "https://api-qa.ucsd.edu:8243/tgpt-mobileproxy/1.0.0/chat/send-message";
      print('▶️ sendMessage → $endpoint');
      print('🔑 using token prefix: ${headers["Authorization"]!.substring(0, 10)}...');

      // Build request payload to match:
      // {
      //   "chat_session_id": "...",
      //   "message": "...",
      //   "retrieval_options": { "run_search": "always" },
      //   "file_descriptors": []
      // }
      final Map<String, dynamic> payload = {
        "chat_session_id": chatSessionId,
        "message": message,
        "retrieval_options": {
          "run_search": "always",
        },
        "file_descriptors": <dynamic>[],
      };

      final body = json.encode(payload);
      print('📤 body: $body');

      // Send POST request to WSO2, which forwards to backend
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

      // Accumulate assistant message text from message_delta chunks
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

        // We only care about the assistant message stream:
        // ind == 1 → assistant
        // type == "message_delta" → one chunk of the final answer
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
      print('❌ sendMessage error: $e');
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

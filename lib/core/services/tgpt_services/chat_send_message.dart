import 'dart:convert';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';

class ChatMessageService {
  Future<String?> sendRawMessage({
    required String message,
    required String chatSessionId,
    Map<String, dynamic>? customPayload,
  }) async {
    try {
      final Map<String, String> headers = {
        "accept": "application/json",
        "content-type": "application/json",
      };
      final String alternateAssistantIdValue = dotenv.get(
        'TGPT_ALTERNATE_ASSISTANT_ID',
        fallback: dotenv.env['TGPT_ALTERNATE_ASSISTANT_ID'] ?? '',
      );
      final int alternateAssistantId = int.tryParse(alternateAssistantIdValue) ?? 0;
      String? endpoint;
      if (_userDataProvider.isLoggedIn) {
        headers['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
        endpoint = dotenv.env['CHAT_SEND_MESSAGE_ENDPOINT'];
      } else {
        headers['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
        endpoint = dotenv.env['CHAT_SEND_MESSAGE_ENDPOINT'];
      }
      String body;
      if (customPayload != null) {
        body = json.encode(customPayload);
      } else {
        final req = BasicCreateChatMessageRequest(
          message: message,
          chatSessionId: chatSessionId,
          alternateAssistantId: (_userDataProvider.isLoggedIn ? alternateAssistantId : 0),
          parentMessageId: null,
          promptId: null,
          searchDocIds: null,
          fileDescriptors: const [],
          regenerate: false,
          retrievalOptions: RetrievalOptions(
            runSearch: 'auto',
            realTime: true,
            filters: Filters(),
          ),
          promptOverride: null,
          useAgenticSearch: false,
        );
        body = json.encode(req.toJson());
      }
      if (endpoint == null) return null;
      final raw = await NetworkHelper.authorizedPost(
        endpoint,
        headers,
        body,
      );
      return raw is String ? raw : raw.toString();
    } catch (e) {
      return null;
    }
  }

  bool _isLoading = false;
  String? _error;
  final UserDataProvider _userDataProvider;

  ChatMessageService(this._userDataProvider);

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
      };
      final String alternateAssistantIdValue = dotenv.get(
        'TGPT_ALTERNATE_ASSISTANT_ID',
        fallback: dotenv.env['TGPT_ALTERNATE_ASSISTANT_ID'] ?? '',
      );
      final int alternateAssistantId = int.tryParse(alternateAssistantIdValue) ?? 0;

      String? endpoint;
      if (_userDataProvider.isLoggedIn) {
        headers['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
        endpoint = dotenv.env['CHAT_SEND_MESSAGE_ENDPOINT'];
      } else {
        headers['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
        endpoint = dotenv.env['CHAT_SEND_MESSAGE_ENDPOINT'];
      }

      final req = BasicCreateChatMessageRequest(
        message: message,
        chatSessionId: chatSessionId,
        alternateAssistantId: (_userDataProvider.isLoggedIn ? alternateAssistantId : 0),
        parentMessageId: null,
        promptId: null,
        searchDocIds: null,
        fileDescriptors: const [],
        regenerate: false,
        retrievalOptions: RetrievalOptions(
          runSearch: 'auto',
          realTime: true,
          filters: Filters(),
        ),
        promptOverride: null,
        useAgenticSearch: false,
      );

      final body = json.encode(req.toJson());

      if (endpoint == null) {
        _error = 'No valid streaming endpoint found.';
        return null;
      }
      final raw = await NetworkHelper.authorizedPost(
        endpoint,
        headers,
        body,
      );
      String rawStr = raw is String ? raw : raw.toString();
      final lines = rawStr.split('\n');
      Map<String, dynamic>? map;
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          map = json.decode(line);
          break;
        } catch (_) {
          continue;
        }
      }
      if (map == null) {
        _error = 'No valid JSON in response';
        return null;
      }
      final resp = ChatBasicResponse.fromJson(map)..renderCitationsAsHyperlinks();

      final hasErrorMsg = resp.errorMsg != null && resp.errorMsg!.isNotEmpty;
      if (hasErrorMsg) {
        _error = 'Backend error: ${resp.errorMsg}';
        return null;
      }

      final hasAnswer = resp.answer != null && resp.answer!.isNotEmpty;
      if (!hasAnswer) {
        _error = 'Empty response from backend';
        return null;
      }

      return resp;
    } catch (e) {
      final isUnauthorized = e.toString().contains("401");
      final shouldRefresh = isUnauthorized && _userDataProvider.isLoggedIn;
      if (shouldRefresh) {
        final retryHeaders = {
          "accept": "application/json",
          "content-type": "application/json",
        };

        if (await NetworkHelper.getNewToken(retryHeaders))
          return await sendMessage(message: message, chatSessionId: chatSessionId);
      }
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  String? get error => _error;
  bool get isLoading => _isLoading;
}

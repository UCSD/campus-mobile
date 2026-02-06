import 'dart:convert';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_session.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatSessionService {
  final UserDataProvider _userDataProvider;
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  ChatSessionService(this._userDataProvider);

  Future<CreateChatSessionID?> createChatSession() async {
    _error = null;
    _isLoading = true;

    try {
      Map<String, String> requestHeaders = {
        "accept": "application/json",
        "content-type": "application/json",
      };
      String createChatSessionEndpoint;
      if (_userDataProvider.isLoggedIn) {
        createChatSessionEndpoint = dotenv.get('CHAT_CREATE_SESSION_ENDPOINT');
        String? apiKey = dotenv.env['TGPT_API_KEY'];
        final hasApiKey = apiKey != null;
        final isDirectEndpoint = createChatSessionEndpoint.contains('traip03.tgptinf.ucsd.edu');
        final useApiKey = hasApiKey && isDirectEndpoint;
        if (useApiKey) {
          requestHeaders['X-API-Key'] = apiKey;
        } else {
          requestHeaders['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
        }
      } else {
        requestHeaders['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
        createChatSessionEndpoint = dotenv.get('CHAT_CREATE_SESSION_ENDPOINT');
      }

      final int personaId = int.tryParse(
            dotenv.get('TGPT_PERSONA_ID', fallback: '1'),
          ) ??
          1;
      ChatSessionCreationRequest request = ChatSessionCreationRequest(
        personaId: personaId,
      );

      Map<String, dynamic> requestMap = request.toJson();
      requestMap.remove('description');
      String requestBody = json.encode(requestMap);

      final _response = await NetworkHelper.authorizedPost(createChatSessionEndpoint, requestHeaders, requestBody);
      CreateChatSessionID chatSessionId = CreateChatSessionID.fromJson((_response));

      return chatSessionId;
    } catch (e) {
      final isUnauthorized = e.toString().contains("401");
      final shouldRefresh = isUnauthorized && _userDataProvider.isLoggedIn;
      if (shouldRefresh) {
        Map<String, String> retryHeaders = {
          "accept": "application/json",
          "content-type": "application/json",
        };
        if (await NetworkHelper.getNewToken(retryHeaders)) {
          retryHeaders['Authorization'] = 'Bearer ${_userDataProvider.authenticationModel.accessToken}';
          return await createChatSession();
        }
      }
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  get error => _error;
  get isLoading => _isLoading;
  get lastUpdated => _lastUpdated;
}

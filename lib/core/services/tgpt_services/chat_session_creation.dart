import 'dart:convert';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_session.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for creating chat sessions via the TGPT API.
class ChatSessionService {
  final UserDataProvider _userDataProvider;
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  bool _hasRetried = false;

  /// Default headers for POST requests
  final Map<String, String> headers = {
    "accept": "application/json",
    "content-type": "application/json",
  };

  ChatSessionService(this._userDataProvider);

  /// Create a new chat session.
  ///
  /// Returns [CreateChatSessionID] with the new session ID on success,
  /// or null if the request fails.
  Future<CreateChatSessionID?> createChatSession() async {
    _error = null;
    _isLoading = true;

    try {
      // Set auth header based on login state
      if (_userDataProvider.isLoggedIn) {
        headers['Authorization'] = 'Bearer ${_userDataProvider.authenticationModel.accessToken}';
      } else {
        headers['Authorization'] = dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY');
      }

      final String createChatSessionEndpoint = dotenv.get('CHAT_CREATE_SESSION_ENDPOINT');

      // Build request payload
      final ChatSessionCreationRequest request = ChatSessionCreationRequest(personaId: 1);
      final String requestBody = json.encode(request.toJson());

      // Send POST
      final response = await NetworkHelper.authorizedPost(
        createChatSessionEndpoint,
        headers,
        requestBody,
      );

      final CreateChatSessionID chatSessionId = CreateChatSessionID.fromJson(response);
      return chatSessionId;
    } catch (e) {
      // Retry once on 401 with refreshed token
      if (!_hasRetried && e.toString().contains("401")) {
        _hasRetried = true;

        final bool refreshed = await NetworkHelper.getNewToken(headers);
        if (refreshed) {
          _lastUpdated = DateTime.now();
          return await createChatSession();
        } else {
          _hasRetried = false;
          return null;
        }
      }

      _error = e.toString();
      _hasRetried = false;
      return null;
    } finally {
      _isLoading = false;
    }
  }

  String? get error => _error;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}

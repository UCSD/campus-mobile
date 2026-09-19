/// TGPT Chat Session Creation Service
///
/// Required .env variables:
/// - CHAT_CREATE_SESSION_ENDPOINT: URL for creating chat sessions
/// - MOBILE_APP_PUBLIC_DATA_KEY: Public API key for unauthenticated users
/// - TGPT_PERSONA_ID: Persona ID for chat sessions (optional, defaults to 1)
import 'dart:convert';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_session.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/tgpt_error_message.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/tgpt_debug_log.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/tgpt_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for creating chat sessions via the TGPT API.
class ChatSessionService {
  final UserDataProvider _userDataProvider;
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  bool _hasRetried = false;

  /// Default persona ID if not configured in environment
  static const int _DEFAULT_PERSONA_ID = 1;

  ChatSessionService(this._userDataProvider);

  /// Create a new chat session.
  ///
  /// Returns [CreateChatSessionID] with the new session ID on success,
  /// or null if the request fails.
  Future<CreateChatSessionID?> createChatSession() async {
    _error = null;
    _isLoading = true;

    // MA-707 TGPT proxy auth START
    final String createChatSessionEndpoint = dotenv.get('CHAT_CREATE_SESSION_ENDPOINT');
    final String authMode = tgptAuthMode(endpoint: createChatSessionEndpoint, isLoggedIn: _userDataProvider.isLoggedIn);
    final Map<String, String> headers = tgptRequestHeaders(
      endpoint: createChatSessionEndpoint,
      isLoggedIn: _userDataProvider.isLoggedIn,
      accessToken: _userDataProvider.authenticationModel.accessToken ?? '',
    );
    // MA-707 TGPT proxy auth END

    try {
      // Read persona ID from environment, with fallback to default
      final int personaId = int.tryParse(dotenv.get('TGPT_PERSONA_ID', fallback: '')) ?? _DEFAULT_PERSONA_ID;

      // Build request payload
      final ChatSessionCreationRequest request = ChatSessionCreationRequest(personaId: personaId);
      final String requestBody = json.encode(request.toJson());

      // MA-707 session diagnostics START
      tgptDebugLog(
        'session-start',
        endpoint: createChatSessionEndpoint,
        authMode: authMode,
        detail: 'persona=$personaId',
      );
      // MA-707 session diagnostics END

      // Send POST
      final response = await NetworkHelper.authorizedPost(createChatSessionEndpoint, headers, requestBody);

      // Defensive parsing: handle both Map and String responses
      final CreateChatSessionID chatSessionId = CreateChatSessionID.fromJsonSafe(response);
      tgptDebugLog(
        'session-ok',
        endpoint: createChatSessionEndpoint,
        authMode: authMode,
        sessionId: chatSessionId.chatSessionId,
        statusCode: 200,
      );
      return chatSessionId;
    } catch (e) {
      if (e is DioException) {
        tgptDebugDio('session-failed', endpoint: createChatSessionEndpoint, authMode: authMode, error: e);
      } else {
        tgptDebugLog(
          'session-failed',
          endpoint: createChatSessionEndpoint,
          authMode: authMode,
          detail: e.runtimeType.toString(),
        );
      }
      // Retry once on 401 with refreshed token
      var isNotRetried = !_hasRetried;
      var has401Error = e.toString().contains("401");
      final bool canRefreshUserBearer = authMode == 'user-bearer';
      if (isNotRetried && has401Error && canRefreshUserBearer) {
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

      _error = e is DioException ? await tgptErrorMessageForDio(e) : tgptErrorMessageFor(e);
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

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/tgpt_debug_log.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/tgpt_request.dart';

// MA-707 TGPT feedback service START
abstract class ChatFeedbackGateway {
  Future<void> createFeedback({required int chatMessageId, required bool isPositive});

  Future<void> removeFeedback({required String chatSessionId, required int chatMessageId});
}

class ChatFeedbackService implements ChatFeedbackGateway {
  ChatFeedbackService(this._userDataProvider, {Dio? dio}) : _dio = dio ?? Dio();

  final UserDataProvider _userDataProvider;
  final Dio _dio;

  Map<String, String> _headers(String endpoint) => tgptRequestHeaders(
    endpoint: endpoint,
    isLoggedIn: _userDataProvider.isLoggedIn,
    accessToken: _userDataProvider.authenticationModel.accessToken ?? '',
  );

  Future<void> _send(
    String operation,
    String endpoint,
    Future<void> Function(Map<String, String> headers) request,
  ) async {
    final Map<String, String> headers = _headers(endpoint);
    final String authMode = tgptAuthMode(endpoint: endpoint, isLoggedIn: _userDataProvider.isLoggedIn);
    try {
      tgptDebugLog(operation, endpoint: endpoint, authMode: authMode);
      await request(headers);
      tgptDebugLog('$operation-ok', endpoint: endpoint, authMode: authMode, statusCode: 200);
    } on DioException catch (error) {
      tgptDebugDio('$operation-failed', endpoint: endpoint, authMode: authMode, error: error);
      if (authMode == 'user-bearer' && error.response?.statusCode == 401) {
        final bool refreshed = await NetworkHelper.getNewToken(headers);
        if (refreshed) {
          await request(headers);
          return;
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> createFeedback({required int chatMessageId, required bool isPositive}) async {
    final String endpoint = dotenv.get('CHAT_CREATE_FEEDBACK_ENDPOINT');
    await _send('feedback-create', endpoint, (Map<String, String> headers) async {
      await _dio.post<void>(
        endpoint,
        data: <String, dynamic>{'chat_message_id': chatMessageId, 'is_positive': isPositive},
        options: Options(headers: headers),
      );
    });
  }

  @override
  Future<void> removeFeedback({required String chatSessionId, required int chatMessageId}) async {
    final String endpoint = dotenv.get('CHAT_REMOVE_FEEDBACK_ENDPOINT');
    await _send('feedback-remove', endpoint, (Map<String, String> headers) async {
      await _dio.delete<void>(
        endpoint,
        queryParameters: <String, dynamic>{'chat_session_id': chatSessionId, 'chat_message_id': chatMessageId},
        options: Options(headers: headers),
      );
    });
  }
}

// MA-707 TGPT feedback service END

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/app_networking.dart';

class ChatFeedbackService {
  Future<bool> sendFeedback({
    required int chatMessageId,
    required bool isPositive,
    String? feedbackText,
    String? predefinedFeedback,
  }) async {
    final endpoint = dotenv.env['CHAT_CREATE_FEEDBACK_ENDPOINT'];
    final hasEndpoint = endpoint != null && endpoint.isNotEmpty;
    if (!hasEndpoint) return false;

    final headers = {
      "accept": "application/json",
      "content-type": "application/json",
      "Authorization": dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY'),
    };

    final payload = {
      "chat_message_id": chatMessageId,
      "is_positive": isPositive,
      "feedback_text": feedbackText,
      "predefined_feedback": predefinedFeedback,
    };
    try {
      final response = await NetworkHelper.authorizedPost(
        endpoint,
        headers,
        json.encode(payload),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssistantMessageContent.parse', () {
    test('strips related question markers from markdown and collects questions', () {
      const String rawText = '''
Here is the answer.

Related Questions:
[rq] What deadlines should I watch?
[rq] Who do I contact next?
''';

      final AssistantMessageContent content = AssistantMessageContent.parse(rawText);

      expect(content.markdown, 'Here is the answer.');
      expect(
        content.relatedQuestions,
        <String>[
          'What deadlines should I watch?',
          'Who do I contact next?',
        ],
      );
    });

    test('suppresses partial streaming related question lines from markdown', () {
      const String rawText = '''
Answer in progress.
[rq
''';

      final AssistantMessageContent content = AssistantMessageContent.parse(rawText);

      expect(content.markdown, 'Answer in progress.');
      expect(content.relatedQuestions, isEmpty);
    });
  });
}

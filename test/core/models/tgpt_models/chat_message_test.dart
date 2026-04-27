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

    test('TGPT web widget markdown: strips --- and #rq block from markdown, keeps card list', () {
      const String rawText = '''
Hello! How can I assist you today with UC San Diego information?

---

**Related Questions**  
[What UC San Diego resources are available for new students moving onto campus?](#rq)  
[How can I find the latest UC San Diego policy updates for staff members?](#rq)  
''';

      final AssistantMessageContent content = AssistantMessageContent.parse(rawText);

      expect(
        content.markdown,
        'Hello! How can I assist you today with UC San Diego information?',
      );
      expect(
        content.relatedQuestions,
        <String>[
          'What UC San Diego resources are available for new students moving onto campus?',
          'How can I find the latest UC San Diego policy updates for staff members?',
        ],
      );
    });
  });
}

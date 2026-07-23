import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('messages only includes currently subscribed notification types', () {
    final user = _UserDataProvider(['staffAnnouncements']);
    final provider = MessagesDataProvider()..userDataProvider = user;
    provider.updateMessages([
      _message('staff', ['staffAnnouncements']),
      _message('scan', null),
    ]);

    expect(provider.messages.map((message) => message.messageId), ['staff']);

    user.topics = ['DM'];
    expect(provider.messages.map((message) => message.messageId), ['scan']);
  });
}

MessageElement _message(String id, List<String>? topics) => MessageElement(
      sender: '',
      message: Message(message: '', title: '', data: Data()),
      messageId: id,
      audience: Audience(topics: topics),
      timestamp: 0,
    );

class _UserDataProvider extends UserDataProvider {
  _UserDataProvider(this.topics);

  List<String?> topics;

  @override
  List<String?>? get subscribedTopics => topics;
}

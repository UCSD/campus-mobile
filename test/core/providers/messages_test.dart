import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('messages only includes currently subscribed notification types', () {
    final user = _UserDataProvider(['staffAnnouncements'], isLoggedIn: false);
    final provider = MessagesDataProvider()..userDataProvider = user;
    provider.updateMessages([
      _message('staff', ['staffAnnouncements']),
      _message('scan', null),
    ]);

    expect(provider.messages.map((message) => message.messageId), ['staff']);

    user.topics = ['DM'];
    user.loggedIn = true;
    expect(provider.messages.map((message) => message.messageId), ['scan']);
  });

  test('messages includes direct notifications for logged-in users', () {
    final user = _UserDataProvider(['staffAnnouncements'], isLoggedIn: true);
    final provider = MessagesDataProvider()..userDataProvider = user;
    provider.updateMessages([
      _message('staff', ['staffAnnouncements']),
      _message('direct', null),
    ]);

    expect(provider.messages.map((message) => message.messageId), ['staff', 'direct']);
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
  _UserDataProvider(this.topics, {required bool isLoggedIn}) : loggedIn = isLoggedIn;

  List<String?> topics;
  bool loggedIn;

  @override
  bool get isLoggedIn => loggedIn;

  @override
  List<String?>? get subscribedTopics => topics;
}

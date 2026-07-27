import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/providers/notifications_freefood.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/navigator/bottom.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const messagesChannel = MethodChannel('com.llfbandit.app_links/messages');
  const eventsChannel = MethodChannel('com.llfbandit.app_links/events');

  setUp(() {
    resetNotificationsScrollOffset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(messagesChannel, (_) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(eventsChannel, (_) async => null);
  });

  testWidgets('subscription expansion keeps notification scrolling stable', (tester) async {
    final user = _UserDataProvider(['campusAnnouncements']);
    final messages = _CountingMessagesDataProvider()..userDataProvider = user;
    messages.updateMessages(List.generate(120, _message));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MessagesDataProvider>.value(value: messages),
          ChangeNotifierProvider.value(value: FreeFoodDataProvider()),
        ],
        child: MaterialApp(home: Scaffold(body: NotificationsListView())),
      ),
    );
    await tester.pump();

    messages.reads = 0;
    user.topics.add('studentAnnouncements');
    messages.notifyListeners();
    await tester.pump();

    expect(messages.reads, 1);
    expect(find.byType(ListView), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, -20000), 10000);
    await tester.pumpAndSettle();

    expect(
        messages.notificationScrollController.offset, messages.notificationScrollController.position.maxScrollExtent);
  });
}

MessageElement _message(int index) => MessageElement(
      sender: '',
      message: Message(
        message: 'Notification $index ${'content ' * (index % 4 + 1)}',
        title: 'Title $index',
        data: Data(),
      ),
      messageId: '$index',
      audience: Audience(topics: [index.isEven ? 'campusAnnouncements' : 'studentAnnouncements']),
      timestamp: index,
    );

class _CountingMessagesDataProvider extends MessagesDataProvider {
  int reads = 0;

  @override
  List<MessageElement> get messages {
    reads++;
    return super.messages;
  }
}

class _UserDataProvider extends UserDataProvider {
  _UserDataProvider(this.topics);

  final List<String?> topics;

  @override
  List<String?>? get subscribedTopics => topics;
}

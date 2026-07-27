import 'package:campus_mobile_experimental/core/providers/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('notification switches render every subscription combination', (tester) async {
    final user = _UserDataProvider(['staffAnnouncements']);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserDataProvider>.value(value: user),
          ChangeNotifierProvider<PushNotificationDataProvider>.value(value: _PushNotificationDataProvider()),
          ChangeNotifierProvider.value(value: CustomAppBar()),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: NotificationsFilterView(),
        ),
      ),
    );

    expect(_switch(tester, 'staffAnnouncements').value, isTrue);
    expect(_switch(tester, 'DM').value, isFalse);

    await tester.tap(_switchFinder('staffAnnouncements'));
    await tester.pump();
    expect(_switch(tester, 'staffAnnouncements').value, isFalse);
    expect(_switch(tester, 'DM').value, isFalse);

    await tester.tap(_switchFinder('DM'));
    await tester.pump();
    expect(_switch(tester, 'staffAnnouncements').value, isFalse);
    expect(_switch(tester, 'DM').value, isTrue);

    await tester.tap(_switchFinder('staffAnnouncements'));
    await tester.pump();
    expect(_switch(tester, 'staffAnnouncements').value, isTrue);
    expect(_switch(tester, 'DM').value, isTrue);

    await tester.tap(_switchFinder('DM'));
    await tester.tap(_switchFinder('DM'));
    await tester.pump();
    expect(_switch(tester, 'staffAnnouncements').value, isTrue);
    expect(_switch(tester, 'DM').value, isTrue);
    expect(tester.takeException(), isNull);
  });
}

Finder _switchFinder(String topic) =>
    find.descendant(of: find.byKey(Key(topic)), matching: find.byType(Switch));

Switch _switch(WidgetTester tester, String topic) => tester.widget(_switchFinder(topic));

class _UserDataProvider extends UserDataProvider {
  _UserDataProvider(this.topics);

  final List<String?> topics;

  @override
  List<String?>? get subscribedTopics => topics;

  @override
  void toggleNotifications(String topic) {
    topics.contains(topic) ? topics.remove(topic) : topics.add(topic);
    notifyListeners();
  }
}

class _PushNotificationDataProvider extends ChangeNotifier implements PushNotificationDataProvider {
  @override
  Map<String?, bool> get topicSubscriptionState => {};

  @override
  List<String?> publicTopics() => ['staffAnnouncements', 'DM'];

  @override
  List<String?> staffTopics() => [];

  @override
  List<String?> studentTopics() => [];

  @override
  String? getTopicName(String topicId) => topicId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

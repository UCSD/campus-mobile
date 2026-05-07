import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_history.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/assistant_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const String previous7DaysExpandedKey = 'tgpt_sidebar_previous_7_days_expanded';
  const String olderExpandedKey = 'tgpt_sidebar_older_expanded';
  final DateTime now = DateTime.now();
  final List<ChatSessionMeta> sessions = <ChatSessionMeta>[
    ChatSessionMeta(
      id: 'recent',
      title: 'Recent Chat',
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    ChatSessionMeta(
      id: 'older',
      title: 'Older Chat',
      createdAt: now.subtract(const Duration(days: 12)),
      updatedAt: now.subtract(const Duration(days: 12)),
    ),
  ];

  Widget buildSidebar({required bool isLoggedIn}) {
    return MaterialApp(
      home: AssistantSidebar(
        isLoggedIn: isLoggedIn,
        sessions: sessions,
        activeSessionId: 'recent',
        onNewChat: () async {},
        onSelectSession: (_) async {},
        onClose: () {},
      ),
    );
  }

  Future<void> pumpSidebar(WidgetTester tester, {required bool isLoggedIn}) async {
    await tester.pumpWidget(buildSidebar(isLoggedIn: isLoggedIn));
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('shows time buckets for signed-in users', (WidgetTester tester) async {
    await pumpSidebar(tester, isLoggedIn: true);

    expect(find.text('Previous 7 Days'), findsOneWidget);
    expect(find.text('Older'), findsOneWidget);
    expect(find.text('Recent Chat'), findsOneWidget);
    expect(find.text('Older Chat'), findsOneWidget);
  });

  testWidgets('shows a flat chat list for guests', (WidgetTester tester) async {
    await pumpSidebar(tester, isLoggedIn: false);

    expect(find.text('Previous 7 Days'), findsNothing);
    expect(find.text('Older'), findsNothing);
    expect(find.text('Recent Chat'), findsOneWidget);
    expect(find.text('Older Chat'), findsOneWidget);
  });

  testWidgets('collapses and expands previous 7 days section for signed-in users', (WidgetTester tester) async {
    await pumpSidebar(tester, isLoggedIn: true);

    await tester.tap(find.text('Previous 7 Days'));
    await tester.pumpAndSettle();

    expect(find.text('Previous 7 Days'), findsOneWidget);
    expect(find.text('Recent Chat'), findsNothing);
    expect(find.text('Older Chat'), findsOneWidget);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(previous7DaysExpandedKey), isFalse);

    await tester.tap(find.text('Previous 7 Days'));
    await tester.pumpAndSettle();

    expect(find.text('Recent Chat'), findsOneWidget);
    expect(preferences.getBool(previous7DaysExpandedKey), isTrue);
  });

  testWidgets('collapses and expands older section for signed-in users', (WidgetTester tester) async {
    await pumpSidebar(tester, isLoggedIn: true);

    await tester.tap(find.text('Older'));
    await tester.pumpAndSettle();

    expect(find.text('Older'), findsOneWidget);
    expect(find.text('Older Chat'), findsNothing);
    expect(find.text('Recent Chat'), findsOneWidget);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(olderExpandedKey), isFalse);

    await tester.tap(find.text('Older'));
    await tester.pumpAndSettle();

    expect(find.text('Older Chat'), findsOneWidget);
    expect(preferences.getBool(olderExpandedKey), isTrue);
  });

  testWidgets('loads saved section expansion preferences', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      previous7DaysExpandedKey: false,
      olderExpandedKey: true,
    });

    await pumpSidebar(tester, isLoggedIn: true);

    expect(find.text('Previous 7 Days'), findsOneWidget);
    expect(find.text('Older'), findsOneWidget);
    expect(find.text('Recent Chat'), findsNothing);
    expect(find.text('Older Chat'), findsOneWidget);

    await tester.tap(find.text('Previous 7 Days'));
    await tester.pumpAndSettle();

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(previous7DaysExpandedKey), isTrue);
    expect(find.text('Recent Chat'), findsOneWidget);
  });
}

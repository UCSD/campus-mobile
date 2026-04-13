import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_history.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/assistant_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  testWidgets('shows time buckets for signed-in users', (WidgetTester tester) async {
    await tester.pumpWidget(buildSidebar(isLoggedIn: true));

    expect(find.text('Previous 7 Days'), findsOneWidget);
    expect(find.text('Older'), findsOneWidget);
    expect(find.text('Recent Chat'), findsOneWidget);
    expect(find.text('Older Chat'), findsOneWidget);
  });

  testWidgets('shows a flat chat list for guests', (WidgetTester tester) async {
    await tester.pumpWidget(buildSidebar(isLoggedIn: false));

    expect(find.text('Previous 7 Days'), findsNothing);
    expect(find.text('Older'), findsNothing);
    expect(find.text('Recent Chat'), findsOneWidget);
    expect(find.text('Older Chat'), findsOneWidget);
  });
}

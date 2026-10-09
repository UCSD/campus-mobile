import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('per-card action padding preserves the default spacing on other cards', (tester) async {
    const contentKey = ValueKey('card-content');
    const actionKey = ValueKey('card-action');

    Future<double> actionAreaHeight(CardContainer container) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: container)),
        ),
      );
      final card = tester.widget<Card>(find.byType(Card));
      final cardBottom = tester.getRect(find.byWidget(card.child!)).bottom;
      final contentBottom = tester.getRect(find.byKey(contentKey)).bottom;
      expect(tester.getRect(find.byKey(actionKey)).height, 24);
      expect(tester.takeException(), isNull);
      return cardBottom - contentBottom;
    }

    expect(
      await actionAreaHeight(
        CardContainer(
          titleText: 'Example',
          isLoading: false,
          reload: () {},
          errorText: null,
          child: () => const SizedBox(key: contentKey, height: 40),
          active: true,
          hide: () {},
          hideMenu: true,
          actionButtons: const [SizedBox(key: actionKey, width: 40, height: 24)],
        ),
      ),
      56,
    );
    expect(
      await actionAreaHeight(
        CardContainer(
          titleText: 'Example',
          isLoading: false,
          reload: () {},
          errorText: null,
          child: () => const SizedBox(key: contentKey, height: 40),
          active: true,
          hide: () {},
          hideMenu: true,
          actionButtons: const [SizedBox(key: actionKey, width: 40, height: 24)],
          actionButtonsPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      40,
    );
  });
}

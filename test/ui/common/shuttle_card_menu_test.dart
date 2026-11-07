import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 412.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('shuttle menu labels and actions work at ${width}px with ${scale}x text', (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var reloads = 0;
        var hides = 0;
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: CardContainer(
                  titleText: 'SHUTTLE',
                  active: true,
                  isLoading: false,
                  errorText: null,
                  reload: () => reloads++,
                  hide: () => hides++,
                  child: () => const Text('Shuttle stop'),
                ),
              ),
            ),
          ),
        );

        for (final label in ['reload card', 'hide card']) {
          await tester.tap(find.byTooltip('SHUTTLE Card Menu'));
          await tester.pumpAndSettle();
          expect(find.text('reload card'), findsOneWidget);
          expect(find.text('hide card'), findsOneWidget);
          expect(tester.takeException(), isNull);

          final text = find.text(label);
          final item = find.ancestor(of: text, matching: find.byType(PopupMenuItem<String>));
          final textRect = tester.getRect(text);
          final itemRect = tester.getRect(item);
          expect(textRect.left, greaterThanOrEqualTo(itemRect.left));
          expect(textRect.right, lessThanOrEqualTo(itemRect.right));
          expect(textRect.bottom, lessThanOrEqualTo(itemRect.bottom));

          await tester.tap(text);
          await tester.pumpAndSettle();
        }
        expect(reloads, 1);
        expect(hides, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

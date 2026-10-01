import 'package:campus_mobile_experimental/core/models/cards.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/ui/common/action_button.dart';
import 'package:campus_mobile_experimental/ui/common/action_link.dart';
import 'package:campus_mobile_experimental/ui/shuttle/shuttle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Shuttle card only shows manage stops and keeps the arrival message and shape', (tester) async {
    final cards = CardsDataProvider();
    cards.availableCards['shuttle'] = CardsModel(
      cardActive: true,
      initialURL: '',
      isWebCard: false,
      requireAuth: false,
      titleText: 'SHUTTLE',
      externalLinkURL: 'https://example.com/transit',
      externalLinkText: 'View Live Transit Map',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: cards),
          ChangeNotifierProvider(create: (_) => ShuttleDataProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(body: ListView(children: [ShuttleCard()])),
        ),
      ),
    );

    expect(find.text('SHUTTLE'), findsOneWidget);
    expect(find.text('View Live Transit Map'), findsNothing);
    expect(find.byType(ActionButton), findsNothing);
    expect(find.byType(ActionLink), findsOneWidget);
    expect(find.text('MANAGE SHUTTLE STOPS'), findsOneWidget);
    expect(find.text('Add a stop to view real-time bus arrivals.'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.getSize(find.byType(Card)).height, greaterThan(200));
    expect(
      (tester.widget<Card>(find.byType(Card)).shape as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(12),
    );
    expect(tester.takeException(), isNull);

    cards.availableCards.clear();
    cards.notifyListeners();
    await tester.pump();
    expect(find.byType(ActionButton), findsNothing);
    expect(find.text('MANAGE SHUTTLE STOPS'), findsOneWidget);
    expect(find.text('Add a stop to view real-time bus arrivals.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

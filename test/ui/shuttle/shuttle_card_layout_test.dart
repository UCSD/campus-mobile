import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/ui/shuttle/shuttle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _LayoutShuttleProvider extends ShuttleDataProvider {
  _LayoutShuttleProvider() {
    arrivalsToRender[1] = [
      ArrivingShuttle(routeId: 1040, routeName: 'Inside Loop', routeColor: '#ffcd00', secondsToArrival: 420),
      ArrivingShuttle(routeId: 1041, routeName: 'SIO Shuttle', routeColor: '#8fa9d2', secondsToArrival: 540),
      ArrivingShuttle(routeId: 1041, routeName: 'SIO Shuttle', routeColor: '#8fa9d2', secondsToArrival: 1080),
    ];
    arrivalsToRender[2] = [];
  }

  @override
  List<ShuttleStopModel> get stopsToRender => [
    ShuttleStopModel(id: 1, name: 'Eighth College / Theatre District (North)', lat: 32.0, lon: -117.0),
    ShuttleStopModel(id: 2, name: 'Gilman', lat: 32.0, lon: -117.0),
  ];
}

Future<void> _pumpCard(WidgetTester tester, Size size, double textScale) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ShuttleDataProvider>(create: (_) => _LayoutShuttleProvider()),
        ChangeNotifierProvider<CardsDataProvider>(create: (_) => CardsDataProvider()),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: ShuttleCard()),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(320, 568), const Size(412, 892), const Size(600, 960), const Size(1024, 768)]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('shuttle card fits ${size.width.toInt()}px width at ${scale}x text scale', (tester) async {
        await _pumpCard(tester, size, scale);

        expect(tester.takeException(), isNull);
        final pager = find.byType(PageView);
        final page = tester.widget<PageView>(pager);
        final content = find.descendant(of: pager, matching: find.text('18 min'));
        expect(content, findsOneWidget);
        expect(tester.getRect(content).bottom, lessThanOrEqualTo(tester.getRect(pager).bottom));
        expect(page.controller!.page, 0);
      });
    }
  }

  testWidgets('swiping between stops shrinks and grows the card to fit the content', (tester) async {
    await _pumpCard(tester, const Size(412, 892), 1.5);
    final pager = find.byType(PageView);
    final controller = tester.widget<PageView>(pager).controller!;
    final populatedHeight = tester.getSize(pager).height;
    expect(populatedHeight, greaterThan(375));

    controller.animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.linear);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(pager).height, lessThan(populatedHeight));
    expect(find.descendant(of: pager, matching: find.text('No arrivals found.')), findsOneWidget);

    controller.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(pager).height, closeTo(populatedHeight, 0.01));
  });
}

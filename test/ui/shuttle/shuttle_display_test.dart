import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/ui/shuttle/shuttle_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final stop = ShuttleStopModel(id: 4006, name: 'UCSD Stop', lat: 32.0, lon: -117.0);

  testWidgets('an empty arrivals response displays the stop and no arrivals message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuttleDisplay(stop: stop, arrivingShuttles: const []),
        ),
      ),
    );

    expect(find.text('UCSD Stop'), findsOneWidget);
    expect(find.text('No arrivals found.'), findsOneWidget);
    expect(find.textContaining('temporarily unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed stop displays its name and an availability message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuttleDisplay(stop: stop, arrivingShuttles: null, arrivalError: 'OneBusAway returned invalid JSON.'),
        ),
      ),
    );

    expect(find.text('UCSD Stop'), findsOneWidget);
    expect(find.textContaining('temporarily unavailable'), findsOneWidget);
    expect(find.text('No arrivals found.'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('successful arrivals display the route and arrival time', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuttleDisplay(
            stop: stop,
            arrivingShuttles: [
              ArrivingShuttle(routeId: 1040, routeName: 'Inside Loop', routeColor: '#ffcd00', secondsToArrival: 60),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Inside Loop'), findsOneWidget);
    expect(find.text('1 minutes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

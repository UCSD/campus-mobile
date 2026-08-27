import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_detail_slide_over.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows route calculation progress', (tester) async {
    final minimized = ValueNotifier(false);
    addTearDown(minimized.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EsriMapDetailSlideOver(
            minimizedNotifier: minimized,
            availableHeight: 800,
            result: const MapSearchResult(
              name: 'Price Center',
              subtitle: 'Building',
              latitude: 32.8797,
              longitude: -117.2362,
              source: MapSearchSource.building,
            ),
            resultIcon: Icons.business,
            isRoutingMode: true,
            hasRoute: false,
            routeFailed: false,
            travelMode: 'Walking',
            routeTravelTimeMinutes: 0,
            routeManeuvers: const [],
            fromLatLng: null,
            onGetDirections: (_) {},
            onTravelModeChanged: (_) {},
            onLaunchWebsite: (_) {},
            onClose: () {},
            onClearRoute: () {},
          ),
        ),
      ),
    );

    expect(
      tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator)).semanticsLabel,
      'Calculating route',
    );
    expect(find.text('Calculating...'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
  });
}

import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_detail_slide_over.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('detail sheet expands only as far as its content requires', (tester) async {
    tester.view.physicalSize = const Size(320, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> pumpDetail(String description) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EsriMapDetailSlideOver(
              controller: DraggableScrollableController(),
              availableHeight: 500,
              result: MapSearchResult(
                name: 'Test place',
                subtitle: 'Campus place',
                latitude: 0,
                longitude: 0,
                source: MapSearchSource.poi,
                description: description,
                websiteUrl: 'https://blink.ucsd.edu/facilities/services/general/personal/dining.html',
              ),
              resultIcon: Icons.place,
              isRoutingMode: false,
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
    }

    await pumpDetail('A short description.');
    expect(tester.widget<DraggableScrollableSheet>(find.byType(DraggableScrollableSheet)).maxChildSize, lessThan(1));
    expect(find.text('Visit blink.ucsd.edu'), findsOneWidget);

    final longDescription = List.filled(
      30,
      'This longer place description remains readable when the information sheet is expanded.',
    ).join(' ');
    await pumpDetail(longDescription);

    expect(tester.widget<DraggableScrollableSheet>(find.byType(DraggableScrollableSheet)).maxChildSize, 1);
    expect(tester.widget<Text>(find.text(longDescription)).maxLines, isNull);
  });
}

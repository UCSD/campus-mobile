import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_search_category.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_suggestions_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('quick search and recent controls invoke their callbacks', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const category = EsriSearchCategory(label: 'Dining', icon: Icons.restaurant, poiClassValue: 'Dining and Beverage');
    const categories = [
      category,
      EsriSearchCategory(label: 'Library', icon: Icons.menu_book, poiClassValue: 'Library'),
      EsriSearchCategory(label: 'Parking', icon: Icons.local_parking, poiClassValue: 'Parking'),
      EsriSearchCategory(label: 'Recreation', icon: Icons.fitness_center, poiClassValue: 'Recreation Facilities'),
    ];
    const recent = MapSearchResult(
      name: 'Starbucks',
      subtitle: 'Dining and Beverage',
      latitude: 32.880184,
      longitude: -117.23642,
      source: MapSearchSource.poi,
    );
    EsriSearchCategory? selectedCategory;
    MapSearchResult? selectedRecent;
    int? removedIndex;
    var clearCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EsriMapSuggestionsPanel(
            categories: categories,
            recentSearches: const [recent],
            showRouteFields: false,
            activeRouteField: null,
            onSelectCurrentLocation: () {},
            onSelectCategory: (value) => selectedCategory = value,
            onSelectRecent: (value) => selectedRecent = value,
            onRemoveRecent: (index) => removedIndex = index,
            onClearRecent: () => clearCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Search Dining'));
    expect(selectedCategory, same(category));
    expect(find.byType(ListView), findsNothing);
    expect(
      tester.getRect(find.byTooltip('Search Recreation')).right,
      lessThanOrEqualTo(tester.getRect(find.byType(Scaffold)).right),
    );

    await tester.ensureVisible(find.text('Starbucks'));
    await tester.tap(find.text('Starbucks'));
    expect(selectedRecent, same(recent));

    await tester.tap(find.byTooltip('Remove Starbucks from recents'));
    expect(removedIndex, 0);

    await tester.tap(find.text('Clear'));
    expect(clearCount, 1);
  });
}

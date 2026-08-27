import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows one inline search progress indicator', (tester) async {
    final searchController = TextEditingController(text: 'library');
    final fromController = TextEditingController();
    final toController = TextEditingController();
    final focusNode = FocusNode();
    final fromFocusNode = FocusNode();
    final toFocusNode = FocusNode();
    addTearDown(() {
      searchController.dispose();
      fromController.dispose();
      toController.dispose();
      focusNode.dispose();
      fromFocusNode.dispose();
      toFocusNode.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EsriMapSearchBar(
            config: null,
            showRouteFields: false,
            searchController: searchController,
            focusNode: focusNode,
            fromController: fromController,
            fromFocusNode: fromFocusNode,
            toController: toController,
            toFocusNode: toFocusNode,
            showSuggestions: false,
            showResults: true,
            isSearching: true,
            searchResults: const [],
            matchingPoiClasses: const [],
            onPerformSearch: (_) {},
            onPerformClassSearch: (_) {},
            onSelectResult: (_) {},
            onClearSearch: () {},
            onClearRoute: () {},
            onSwapRouteFields: () {},
            onTapSearchField: () {},
            onTapFromField: () {},
            onTapToField: () {},
            onChangedFromField: (_) {},
            onChangedToField: (_) {},
            onClearFromField: () {},
            onClearToField: () {},
            onOpenAiSearch: () {},
            iconForClass: (_) => Icons.category,
            labelForClass: (value) => value,
            iconForResult: (_) => Icons.place,
          ),
        ),
      ),
    );

    final indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    final searchField = tester.widget<TextField>(find.byType(TextField));
    final hintPadding = searchField.decoration!.hint! as Padding;
    final hintText = hintPadding.child as Text;
    expect(indicator.semanticsLabel, 'Searching');
    expect(indicator.color, searchField.style?.color);
    expect(hintPadding.padding, const EdgeInsets.only(left: 4));
    expect(hintText.style?.fontSize, searchField.style?.fontSize);
    expect(find.byIcon(Icons.search), findsNothing);
    expect(find.text('No results found'), findsNothing);
  });
}

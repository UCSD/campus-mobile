import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _SearchHarness = ({
  TextEditingController search,
  FocusNode searchFocus,
  TextEditingController from,
  TextEditingController to,
  FocusNode fromFocus,
  FocusNode toFocus,
});

_SearchHarness _createHarness() {
  final search = TextEditingController();
  final searchFocus = FocusNode();
  final from = TextEditingController();
  final to = TextEditingController();
  final fromFocus = FocusNode();
  final toFocus = FocusNode();
  addTearDown(() {
    search.dispose();
    searchFocus.dispose();
    from.dispose();
    to.dispose();
    fromFocus.dispose();
    toFocus.dispose();
  });
  return (search: search, searchFocus: searchFocus, from: from, to: to, fromFocus: fromFocus, toFocus: toFocus);
}

Widget _buildBar(
  _SearchHarness harness, {
  bool isSearching = false,
  bool showResults = false,
  void Function(String)? onPerformSearch,
  void Function(String)? onChangeSearchText,
  VoidCallback? onClearSearch,
}) => MaterialApp(
  home: Scaffold(
    body: EsriMapSearchBar(
      config: null,
      showRouteFields: false,
      searchController: harness.search,
      focusNode: harness.searchFocus,
      fromController: harness.from,
      fromFocusNode: harness.fromFocus,
      toController: harness.to,
      toFocusNode: harness.toFocus,
      showSuggestions: false,
      showResults: showResults,
      isSearching: isSearching,
      searchResults: const [],
      matchingPoiClasses: const [],
      onPerformSearch: onPerformSearch ?? (_) {},
      onChangeSearchText: onChangeSearchText ?? (_) {},
      onPerformClassSearch: (_) {},
      onSelectResult: (_) {},
      onClearSearch: onClearSearch ?? () {},
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
);

void main() {
  testWidgets('shows one inline search progress indicator', (tester) async {
    final harness = _createHarness();
    harness.search.text = 'library';

    await tester.pumpWidget(_buildBar(harness, isSearching: true, showResults: true));

    final indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    final searchField = tester.widget<TextField>(find.byType(TextField));
    expect(indicator.semanticsLabel, 'Searching');
    expect(indicator.color, searchField.style?.color);
    expect(searchField.decoration?.hintText, 'Search buildings, places...');
    expect(searchField.decoration?.hintStyle?.fontSize, searchField.style?.fontSize);
    expect(find.byIcon(Icons.search), findsNothing);
    expect(find.text('No results found'), findsNothing);
  });

  testWidgets('typing changes text without submitting a search', (tester) async {
    final harness = _createHarness();
    final changed = <String>[];
    final submitted = <String>[];

    await tester.pumpWidget(_buildBar(harness, onChangeSearchText: changed.add, onPerformSearch: submitted.add));

    await tester.enterText(find.byType(TextField), 'lib');
    await tester.pump();

    expect(changed, ['lib']);
    expect(submitted, isEmpty);
  });

  testWidgets('search action submits the current text', (tester) async {
    final harness = _createHarness();
    final submitted = <String>[];

    await tester.pumpWidget(_buildBar(harness, onPerformSearch: submitted.add));

    await tester.enterText(find.byType(TextField), 'library');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(submitted, ['library']);
  });

  testWidgets('clearing all text calls onClearSearch', (tester) async {
    final harness = _createHarness();
    var cleared = 0;

    await tester.pumpWidget(_buildBar(harness, onClearSearch: () => cleared++));

    await tester.enterText(find.byType(TextField), 'lib');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(cleared, 1);
  });
}

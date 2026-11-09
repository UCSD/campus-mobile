import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/parking/manage_parking_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> pumpView(WidgetTester tester, _ParkingDataProvider provider) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ParkingDataProvider>.value(value: provider),
          ChangeNotifierProvider.value(value: CustomAppBar()),
        ],
        child: MaterialApp(home: ManageParkingView()),
      ),
    );
  }

  testWidgets('shows every structure and lot once in a flat, sorted list', (tester) async {
    final provider = _ParkingDataProvider(
      [
        _model('Hopkins', neighborhood: 'Central', isStructure: true),
        _model('Athena', neighborhood: 'East', isStructure: true),
        _model('Lot P701', neighborhood: 'East', isStructure: false),
      ],
      {'Hopkins': true, 'Athena': false, 'Lot P701': false},
    );

    await pumpView(tester, provider);

    // No neighborhood or "Parking Structures" group rows, and no drill-in arrows.
    expect(find.text('Neighborhoods'), findsNothing);
    expect(find.text('Parking Structures'), findsNothing);
    expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);

    expect(find.byType(CupertinoSwitch), findsNWidgets(3));
    for (final name in ['Athena', 'Hopkins', 'Lot P701']) {
      expect(find.text(name), findsOneWidget);
    }
    final athenaY = tester.getTopLeft(find.text('Athena')).dy;
    final hopkinsY = tester.getTopLeft(find.text('Hopkins')).dy;
    final lotY = tester.getTopLeft(find.text('Lot P701')).dy;
    expect(athenaY < hopkinsY && hopkinsY < lotY, isTrue);

    expect(_switch(tester, 'Hopkins').value, isTrue);
    expect(_switch(tester, 'Athena').value, isFalse);
  });

  testWidgets('switches and rows toggle selection through the provider', (tester) async {
    final provider = _ParkingDataProvider([_model('Hopkins'), _model('Athena')], {'Hopkins': true, 'Athena': false});

    await pumpView(tester, provider);

    await tester.tap(_switchFinder('Athena'));
    await tester.pump();
    expect(provider.toggleCalls, [('Athena', 1)]);
    expect(_switch(tester, 'Athena').value, isTrue);

    await tester.tap(find.text('Hopkins'));
    await tester.pump();
    expect(provider.toggleCalls.last, ('Hopkins', 2));
    expect(_switch(tester, 'Hopkins').value, isFalse);
  });

  testWidgets('blocks turning on a location past the max and shows the alert', (tester) async {
    final names = List.generate(
      ParkingDataProvider.MAX_SELECTED_LOTS + 1,
      (i) => 'Lot ${i.toString().padLeft(2, '0')}',
    );
    final provider = _ParkingDataProvider(names.map((n) => _model(n)).toList(), {
      for (final n in names) n: n != names.last,
    });

    await pumpView(tester, provider);
    await tester.scrollUntilVisible(find.text(names.last), 100);

    await tester.tap(_switchFinder(names.last));
    await tester.pumpAndSettle();
    expect(provider.toggleCalls, isEmpty);
    expect(find.byType(AlertDialogWidget), findsOneWidget);
  });

  testWidgets('shows loading, error, and empty states', (tester) async {
    final provider = _ParkingDataProvider([], {})..loading = true;
    await pumpView(tester, provider);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    provider
      ..loading = false
      ..err = 'boom';
    provider.notifyListeners();
    await tester.pump();
    expect(find.text('Unable to load parking locations. Please try again later.'), findsOneWidget);

    provider.err = null;
    provider.notifyListeners();
    await tester.pump();
    expect(find.text('No parking locations available.'), findsOneWidget);
  });
}

Finder _switchFinder(String name) => find.descendant(of: find.byKey(Key(name)), matching: find.byType(CupertinoSwitch));

CupertinoSwitch _switch(WidgetTester tester, String name) => tester.widget(_switchFinder(name));

ParkingModel _model(String name, {String neighborhood = 'Central', bool isStructure = false}) => ParkingModel(
  neighborhood: neighborhood,
  isStructure: isStructure,
  locationId: name,
  locationName: name,
  locationContext: '',
  locationProvider: '',
  availability: {},
);

class _ParkingDataProvider extends ChangeNotifier implements ParkingDataProvider {
  _ParkingDataProvider(this.models, this.state);

  final List<ParkingModel> models;
  final Map<String, bool> state;
  final List<(String, int)> toggleCalls = [];
  bool loading = false;
  String? err;

  @override
  get isLoading => loading;

  @override
  get error => err;

  @override
  List<ParkingModel> get parkingModels => models;

  @override
  Map<String, bool> get parkingViewState => state;

  @override
  void toggleLot(String location, int numSelected) {
    toggleCalls.add((location, numSelected));
    state[location] = !state[location]!;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

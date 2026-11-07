import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/shuttle/manage_shuttle_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _ManageShuttleProvider extends ShuttleDataProvider {
  final List<ShuttleStopModel> stops = [
    ShuttleStopModel(id: 1, name: 'First stop', lat: 32.0, lon: -117.0),
    ShuttleStopModel(id: 2, name: 'Second stop', lat: 32.1, lon: -117.1),
  ];
  List<int?>? reorderedIds;

  @override
  List<ShuttleStopModel> get stopsToRender => stops.toList(growable: false);

  @override
  void reorderStops(List<int?>? order) {
    reorderedIds = order;
  }
}

void main() {
  testWidgets('reordering stops copies the fixed provider list before mutation', (tester) async {
    final provider = _ManageShuttleProvider();
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ShuttleDataProvider>.value(value: provider),
          ChangeNotifierProvider<CustomAppBar>(create: (_) => CustomAppBar()),
        ],
        child: MaterialApp(home: Scaffold(body: ManageShuttleView())),
      ),
    );

    final list = tester.widget<ReorderableListView>(find.byType(ReorderableListView));
    list.onReorderItem!(0, 1);
    await tester.pump();

    expect(provider.reorderedIds, [2, 1]);
    expect(tester.takeException(), isNull);
  });
}

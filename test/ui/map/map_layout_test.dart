import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/map/map.dart';
import 'package:campus_mobile_experimental/ui/map/map_search_bar_ph.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const messagesChannel = MethodChannel('com.llfbandit.app_links/messages');
  const eventsChannel = MethodChannel('com.llfbandit.app_links/events');
  late GoogleMapsFlutterPlatform originalPlatform;
  late _MapPlatform platform;
  late BottomNavigationBarProvider navigation;
  late _MapsDataProvider maps;
  int initialLinkReads = 0;
  int linkSubscriptions = 0;
  int linkCancellations = 0;

  setUp(() {
    originalPlatform = GoogleMapsFlutterPlatform.instance;
    platform = _MapPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
    navigation = BottomNavigationBarProvider();
    maps = _MapsDataProvider();
    initialLinkReads = 0;
    linkSubscriptions = 0;
    linkCancellations = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(messagesChannel, (
      call,
    ) async {
      if (call.method == 'getInitialAppLink') initialLinkReads++;
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(eventsChannel, (
      call,
    ) async {
      if (call.method == 'listen') linkSubscriptions++;
      if (call.method == 'cancel') linkCancellations++;
      return null;
    });
  });

  tearDown(() {
    GoogleMapsFlutterPlatform.instance = originalPlatform;
    navigation.dispose();
    maps.dispose();
  });

  for (final screenSize in [const Size(320, 568), const Size(430, 932)]) {
    testWidgets('map warms up at full viewport size before opening its tab at $screenSize', (tester) async {
      await tester.binding.setSurfaceSize(screenSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(navigation, maps));
      expect(platform.viewIds, isEmpty);
      final viewportSize = tester.getSize(find.byKey(const Key('viewport')));
      await tester.pump();
      expect(platform.viewIds, hasLength(1));
      expect(platform.constraints.last, BoxConstraints.tight(viewportSize));

      navigation.currentIndex = NavigatorConstants.MAP_TAB;
      await tester.pump();
      expect(tester.getSize(find.byType(Maps)), viewportSize);
      expect(platform.viewIds, hasLength(1));
      expect(platform.constraints.last, BoxConstraints.tight(viewportSize));
      expect(tester.getSize(find.byType(GoogleMap)), viewportSize);
      expect(tester.getSize(find.byType(MapSearchBarPlaceHolder)).height, lessThan(viewportSize.height / 2));
      final mapState = tester.state(find.byType(GoogleMap));

      navigation.currentIndex = NavigatorConstants.HOME_TAB;
      await tester.pump();
      maps.notifyListeners();
      await tester.pump();
      navigation.currentIndex = NavigatorConstants.MAP_TAB;
      await tester.pump();
      expect(tester.state(find.byType(GoogleMap)), same(mapState));
      expect(platform.viewIds, hasLength(1));
      expect(platform.constraints.every((value) => value == BoxConstraints.tight(viewportSize)), isTrue);
      expect(initialLinkReads, 1);
      expect(linkSubscriptions, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(linkCancellations, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('starting directly on the map waits for its first layout', (tester) async {
    navigation.currentIndex = NavigatorConstants.MAP_TAB;
    await tester.pumpWidget(_app(navigation, maps));
    expect(platform.viewIds, isEmpty);
    final viewportSize = tester.getSize(find.byType(Maps));
    await tester.pump();
    expect(platform.viewIds, hasLength(1));
    expect(platform.constraints.last, BoxConstraints.tight(viewportSize));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading feedback appears only on the map and clears when the native view is ready', (tester) async {
    await tester.pumpWidget(_app(navigation, maps));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator, skipOffstage: false), findsNothing);

    navigation.currentIndex = NavigatorConstants.MAP_TAB;
    await tester.pump();
    final viewportSize = tester.getSize(find.byType(Maps));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator)).semanticsLabel,
      'Loading map',
    );

    final controller = _MapController();
    tester.widget<GoogleMap>(find.byType(GoogleMap)).onMapCreated!(controller);
    await tester.pump();
    expect(maps.mapController, same(controller));
    expect(find.byType(CircularProgressIndicator, skipOffstage: false), findsNothing);
    expect(tester.getSize(find.byType(Maps)), viewportSize);
    expect(platform.viewIds, hasLength(1));

    navigation.currentIndex = NavigatorConstants.HOME_TAB;
    await tester.pump();
    navigation.currentIndex = NavigatorConstants.MAP_TAB;
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(platform.viewIds, hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('map ready callback is safe if the page was removed during initialization', (tester) async {
    await tester.pumpWidget(_app(navigation, maps));
    await tester.pump();
    final onMapCreated = tester.widget<GoogleMap>(find.byType(GoogleMap, skipOffstage: false)).onMapCreated!;
    await tester.pumpWidget(const SizedBox.shrink());
    onMapCreated(_MapController());
    await tester.pump();
    expect(maps.mapController, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a map warmed up on Home opens without showing loading feedback', (tester) async {
    await tester.pumpWidget(_app(navigation, maps));
    await tester.pump();
    tester.widget<GoogleMap>(find.byType(GoogleMap, skipOffstage: false)).onMapCreated!(_MapController());
    await tester.pump();

    navigation.currentIndex = NavigatorConstants.MAP_TAB;
    await tester.pump();
    expect(find.byType(GoogleMap), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(platform.viewIds, hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a startup search link opens the map without repeating the search on rebuild', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(messagesChannel, (
      call,
    ) async {
      if (call.method == 'getInitialAppLink') {
        initialLinkReads++;
        return 'https://mobile.ucsd.edu/deeplinking.searchmap?query=Price%20Center';
      }
      return null;
    });
    await tester.pumpWidget(_app(navigation, maps));
    await tester.pump();
    await tester.pump();
    expect(navigation.currentIndex, NavigatorConstants.MAP_TAB);
    expect(maps.searchBarController.text, 'Price Center');
    expect(maps.searches, 1);
    expect(platform.viewIds, hasLength(1));

    maps.notifyListeners();
    await tester.pump();
    expect(maps.searches, 1);
    expect(initialLinkReads, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

Widget _app(BottomNavigationBarProvider navigation, MapsDataProvider maps) => MultiProvider(
  providers: [
    ChangeNotifierProvider<BottomNavigationBarProvider>.value(value: navigation),
    ChangeNotifierProvider<MapsDataProvider>.value(value: maps),
  ],
  child: MaterialApp(
    home: Scaffold(
      appBar: AppBar(toolbarHeight: 57),
      body: Consumer<BottomNavigationBarProvider>(
        builder: (context, provider, _) => SizedBox.expand(
          key: const Key('viewport'),
          child: IndexedStack(index: provider.currentIndex, children: [const SizedBox.expand(), Maps()]),
        ),
      ),
      bottomNavigationBar: const SizedBox(height: 73),
    ),
  ),
);

class _MapPlatform extends GoogleMapsFlutterPlatform {
  final Set<int> viewIds = {};
  final List<BoxConstraints> constraints = [];

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) {
    viewIds.add(creationId);
    // Measure the bounds passed to the native view without loading a Maps SDK.
    return LayoutBuilder(
      builder: (context, bounds) {
        constraints.add(bounds);
        return const SizedBox.expand();
      },
    );
  }
}

class _MapsDataProvider extends MapsDataProvider {
  int searches = 0;

  @override
  void fetchLocations() {
    searches++;
  }
}

class _MapController extends Fake implements GoogleMapController {}

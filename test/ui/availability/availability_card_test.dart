import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_card.dart';
import 'package:campus_mobile_experimental/ui/common/last_updated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed));

  setUpAll(() async {
    // Use the app's actual fonts so narrow-screen measurements are realistic.
    final bodyFonts = FontLoader('Brix Sans')
      ..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansMedium.otf'))
      ..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansMedium-Italic.otf'))
      ..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansBold.otf'));
    final headingFonts = FontLoader('Refrigerator Deluxe')
      ..addFont(rootBundle.load('assets/fonts/Refrigerator Deluxe Bold.otf'));
    await bodyFonts.load();
    await headingFonts.load();
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('timestamp and action fit a 320px screen in ${brightness.name} mode at ${scale}x text', (
        tester,
      ) async {
        final availability = _AvailabilityProvider(DateTime.now().subtract(const Duration(minutes: 5)))..failed = true;
        await _showCard(tester, brightness: brightness, scale: scale, provider: availability);
        final timestamp = find.byWidgetPredicate(
          (widget) => widget is Text && (widget.data?.contains('Updated') ?? false),
        );
        final action = find.text('MANAGE LOCATIONS');
        final timestampParagraph = tester.renderObject<RenderParagraph>(timestamp);
        final actionParagraph = tester.renderObject<RenderParagraph>(action);

        expect(timestampParagraph.didExceedMaxLines, isFalse);
        expect(actionParagraph.didExceedMaxLines, isFalse);
        expect(find.text('Unable to refresh. Showing last available data.'), findsOneWidget);
        expect(tester.getRect(timestamp).top, greaterThanOrEqualTo(tester.getRect(action).bottom));
        expect(tester.getRect(timestamp).left, closeTo(tester.getRect(action).left, 0.1));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('does not show a timestamp before the first successful update', (tester) async {
    await _showCard(tester, showTimestamp: false);
    expect(find.textContaining('Updated'), findsNothing);
    expect(find.text('MANAGE LOCATIONS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed refreshes rebuild the cached age and show a note until recovery', (tester) async {
    final lastUpdated = DateTime.now().subtract(const Duration(hours: 3));
    final availability = _AvailabilityProvider(lastUpdated);
    await _showCard(tester, provider: availability);
    const failureNote = 'Unable to refresh. Showing last available data.';
    expect(find.text(failureNote), findsNothing);
    var previousLabel = tester.widget<LastUpdatedWidget>(find.byType(LastUpdatedWidget));

    for (var attempt = 0; attempt < 3; attempt++) {
      availability.failed = true;
      availability.notifyListeners();
      await tester.pump();
      final label = tester.widget<LastUpdatedWidget>(find.byType(LastUpdatedWidget));
      expect(label.time, lastUpdated);
      expect(label, isNot(same(previousLabel)));
      expect(find.text('Last Updated: ${LastUpdatedWidget.determineText(lastUpdated)}'), findsOneWidget);
      expect(find.text(failureNote), findsOneWidget);
      expect(find.textContaining('Live'), findsNothing);
      previousLabel = label;
    }

    availability.failed = false;
    availability.notifyListeners();
    await tester.pump();
    expect(find.text(failureNote), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('enabled card refreshes silently every 90 seconds', (tester) async {
    final availability = _AvailabilityProvider(DateTime.now());
    await _showCard(tester, provider: availability);

    await tester.pump(const Duration(seconds: 89));
    expect(availability.refreshModes, isEmpty);
    await tester.pump(const Duration(seconds: 1));
    expect(availability.refreshModes, [true]);
    await tester.pump(const Duration(seconds: 90));
    expect(availability.refreshModes, [true, true]);
  });

  testWidgets('hidden card does not start polling', (tester) async {
    final availability = _AvailabilityProvider(DateTime.now());
    final cards = CardsDataProvider()..cardStates[cardId] = false;
    await _showCard(tester, provider: availability, cardsProvider: cards);

    await tester.pump(const Duration(minutes: 3));
    expect(availability.refreshModes, isEmpty);
  });

  testWidgets('hiding a mounted card cancels polling', (tester) async {
    final availability = _AvailabilityProvider(DateTime.now());
    final cards = CardsDataProvider();
    await _showCard(tester, provider: availability, cardsProvider: cards);
    await tester.pump(const Duration(seconds: 90));
    expect(availability.refreshModes, [true]);

    cards.cardStates[cardId] = false;
    cards.notifyListeners();
    await tester.pump();
    await tester.pump(const Duration(minutes: 3));
    expect(availability.refreshModes, [true]);
  });

  for (final tab in [
    NavigatorConstants.MAP_TAB,
    NavigatorConstants.AI_ASSISTANT_TAB,
    NavigatorConstants.NOTIFICATIONS_TAB,
    NavigatorConstants.PROFILE_TAB,
  ]) {
    testWidgets('card does not poll when tab $tab is initially selected', (tester) async {
      final availability = _AvailabilityProvider(DateTime.now());
      final navigation = BottomNavigationBarProvider()..currentIndex = tab;
      await _showCard(tester, provider: availability, navigationProvider: navigation);

      await tester.pump(const Duration(minutes: 3));
      expect(availability.refreshModes, isEmpty);
    });
  }

  testWidgets('switching tabs pauses polling and returning to Home resumes it', (tester) async {
    final availability = _AvailabilityProvider(DateTime.now());
    final navigation = BottomNavigationBarProvider();
    await _showCard(tester, provider: availability, navigationProvider: navigation);
    await tester.pump(const Duration(seconds: 60));

    navigation.currentIndex = NavigatorConstants.MAP_TAB;
    // Advance through the old deadline before rebuilding to check live tab state.
    await tester.pump(const Duration(seconds: 30));
    expect(availability.refreshModes, isEmpty);
    await tester.pump(const Duration(minutes: 3));
    expect(availability.refreshModes, isEmpty);

    navigation.currentIndex = NavigatorConstants.HOME_TAB;
    await tester.pump();
    await tester.pump(const Duration(seconds: 89));
    expect(availability.refreshModes, isEmpty);
    await tester.pump(const Duration(seconds: 1));
    expect(availability.refreshModes, [true]);
  });

  for (final state in AppLifecycleState.values.where((state) => state != AppLifecycleState.resumed)) {
    testWidgets('card does not start polling in ${state.name} lifecycle state', (tester) async {
      tester.binding.handleAppLifecycleStateChanged(state);
      final availability = _AvailabilityProvider(DateTime.now());
      await _showCard(tester, provider: availability);

      await tester.pump(const Duration(minutes: 3));
      expect(availability.refreshModes, isEmpty);
    });

    testWidgets('${state.name} pauses polling and resuming restarts it', (tester) async {
      final availability = _AvailabilityProvider(DateTime.now());
      await _showCard(tester, provider: availability);
      await tester.pump(const Duration(seconds: 60));

      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pump(const Duration(minutes: 3));
      expect(availability.refreshModes, isEmpty);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 89));
      expect(availability.refreshModes, isEmpty);
      await tester.pump(const Duration(seconds: 1));
      expect(availability.refreshModes, [true]);
    });
  }

  for (final age in <Duration?>[null, const Duration(seconds: 90), const Duration(minutes: 5)]) {
    testWidgets('activation promptly refreshes ${age == null ? 'missing' : '$age old'} data', (tester) async {
      final availability = _AvailabilityProvider(age == null ? null : DateTime.now().subtract(age))
        ..notifyOnFetch = true;
      await _showCard(tester, provider: availability);

      expect(availability.refreshModes, [true]);
      availability.notifyListeners();
      await tester.pump();
      expect(availability.refreshModes, [true]);
    });
  }

  for (final activity in ['card', 'tab', 'app']) {
    testWidgets('returning after $activity inactivity refreshes stale data promptly', (tester) async {
      final availability = _AvailabilityProvider(DateTime.now());
      final cards = CardsDataProvider();
      final navigation = BottomNavigationBarProvider();
      await _showCard(tester, provider: availability, cardsProvider: cards, navigationProvider: navigation);

      void setActive(bool active) {
        switch (activity) {
          case 'card':
            cards.cardStates[cardId] = active;
            cards.notifyListeners();
            break;
          case 'tab':
            navigation.currentIndex = active ? NavigatorConstants.HOME_TAB : NavigatorConstants.MAP_TAB;
            break;
          case 'app':
            tester.binding.handleAppLifecycleStateChanged(
              active ? AppLifecycleState.resumed : AppLifecycleState.paused,
            );
            break;
        }
      }

      setActive(false);
      await tester.pump();
      availability.updatedAt = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.pump(const Duration(minutes: 3));
      expect(availability.refreshModes, isEmpty);

      setActive(true);
      await tester.pump();
      expect(availability.refreshModes, [true]);
      await tester.pump(const Duration(seconds: 90));
      expect(availability.refreshModes, [true, true]);
    });
  }

  testWidgets('all activity conditions must hold before stale data refreshes', (tester) async {
    final availability = _AvailabilityProvider(DateTime.now().subtract(const Duration(minutes: 5)));
    final cards = CardsDataProvider()..cardStates[cardId] = false;
    final navigation = BottomNavigationBarProvider()..currentIndex = NavigatorConstants.MAP_TAB;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await _showCard(tester, provider: availability, cardsProvider: cards, navigationProvider: navigation);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(minutes: 3));
    expect(availability.refreshModes, isEmpty);
    cards.cardStates[cardId] = true;
    cards.notifyListeners();
    await tester.pump(const Duration(minutes: 3));
    expect(availability.refreshModes, isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    navigation.currentIndex = NavigatorConstants.HOME_TAB;
    await tester.pump(const Duration(minutes: 3));
    expect(availability.refreshModes, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(availability.refreshModes, [true]);
  });

  testWidgets('rapid lifecycle transitions discard obsolete activation callbacks', (tester) async {
    final availability = _AvailabilityProvider(DateTime.now());
    await _showCard(tester, provider: availability);
    availability.updatedAt = DateTime.now().subtract(const Duration(minutes: 5));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(availability.refreshModes, isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(availability.refreshModes, [true]);
    await tester.pump(const Duration(seconds: 90));
    expect(availability.refreshModes, [true, true]);
  });

  testWidgets('activation checks freshness again after the frame', (tester) async {
    final availability = _AvailabilityProvider(DateTime.now());
    await _showCard(tester, provider: availability);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    availability.updatedAt = DateTime.now().subtract(const Duration(minutes: 5));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    // Another request completed before the deferred activation refresh.
    availability.updatedAt = DateTime.now();
    availability.notifyListeners();
    await tester.pump();
    expect(availability.refreshModes, isEmpty);
    await tester.pump(const Duration(seconds: 90));
    expect(availability.refreshModes, [true]);
  });

  testWidgets('repeated activity changes keep one timer and rebuilds preserve its deadline', (tester) async {
    final availability = _AvailabilityProvider(DateTime.now());
    final cards = CardsDataProvider();
    final navigation = BottomNavigationBarProvider();
    await _showCard(tester, provider: availability, cardsProvider: cards, navigationProvider: navigation);

    for (var cycle = 0; cycle < 3; cycle++) {
      cards.cardStates[cardId] = false;
      cards.notifyListeners();
      navigation.currentIndex = NavigatorConstants.MAP_TAB;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      cards.cardStates[cardId] = true;
      cards.notifyListeners();
      navigation.currentIndex = NavigatorConstants.HOME_TAB;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
    }
    await tester.pump(const Duration(seconds: 60));
    availability.notifyListeners();
    cards.notifyListeners();
    navigation.currentIndex = NavigatorConstants.HOME_TAB;
    await tester.pump();
    expect(availability.refreshModes, isEmpty);
    await tester.pump(const Duration(seconds: 30));
    expect(availability.refreshModes, [true]);
    await tester.pump(const Duration(seconds: 90));
    expect(availability.refreshModes, [true, true]);
  });

  testWidgets('disposal cancels polling, pending activation refreshes, and lifecycle observation', (tester) async {
    final availability = _AvailabilityProvider(DateTime.now());
    await _showCard(tester, provider: availability);
    availability.updatedAt = DateTime.now().subtract(const Duration(minutes: 5));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 3));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(minutes: 3));
    expect(availability.refreshModes, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _showCard(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  double scale = 1,
  bool showTimestamp = true,
  _AvailabilityProvider? provider,
  CardsDataProvider? cardsProvider,
  BottomNavigationBarProvider? navigationProvider,
}) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final availability =
      provider ?? _AvailabilityProvider(showTimestamp ? DateTime.now().subtract(const Duration(minutes: 5)) : null);
  final cards = cardsProvider ?? CardsDataProvider();
  final navigation = navigationProvider ?? BottomNavigationBarProvider();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    availability.dispose();
    cards.dispose();
    navigation.dispose();
  });
  final dark = brightness == Brightness.dark;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AvailabilityDataProvider>.value(value: availability),
        ChangeNotifierProvider<CardsDataProvider>.value(value: cards),
        ChangeNotifierProvider<BottomNavigationBarProvider>.value(value: navigation),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: false,
          brightness: brightness,
          fontFamily: 'Brix Sans',
          textTheme: TextTheme(
            titleLarge: dark ? cardTitleStyleDark : cardTitleStyleLight,
            bodyMedium: dark ? bodyMediumDark : bodyMediumLight,
            labelLarge: dark ? labelLargeStyleDark : labelLargeStyleLight,
          ),
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: AvailabilityCard()),
          ),
        ),
      ),
    ),
  );
}

class _AvailabilityProvider extends AvailabilityDataProvider {
  _AvailabilityProvider(this.updatedAt);

  DateTime? updatedAt;
  bool failed = false;
  bool notifyOnFetch = false;
  final refreshModes = <bool>[];

  @override
  Future<void> fetchAvailability({bool silent = false}) async {
    refreshModes.add(silent);
    if (notifyOnFetch) notifyListeners();
  }

  @override
  bool get refreshFailed => failed;

  @override
  DateTime? get lastUpdated => updatedAt;

  @override
  List<AvailabilityModel?> get availabilityModels => [];
}

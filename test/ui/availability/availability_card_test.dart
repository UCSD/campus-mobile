import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
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
}

Future<void> _showCard(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  double scale = 1,
  bool showTimestamp = true,
  _AvailabilityProvider? provider,
}) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final availability =
      provider ?? _AvailabilityProvider(showTimestamp ? DateTime.now().subtract(const Duration(minutes: 5)) : null);
  final cards = CardsDataProvider();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    availability.dispose();
    cards.dispose();
  });
  final dark = brightness == Brightness.dark;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AvailabilityDataProvider>.value(value: availability),
        ChangeNotifierProvider<CardsDataProvider>.value(value: cards),
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

  final DateTime? updatedAt;
  bool failed = false;

  @override
  bool get refreshFailed => failed;

  @override
  DateTime? get lastUpdated => updatedAt;

  @override
  List<AvailabilityModel?> get availabilityModels => [];
}

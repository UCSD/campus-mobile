import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_card.dart';
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
        await _showCard(tester, brightness: brightness, scale: scale);
        final timestamp = find.byWidgetPredicate(
          (widget) => widget is Text && (widget.data?.contains('Updated') ?? false),
        );
        final action = find.text('MANAGE LOCATIONS');
        final timestampParagraph = tester.renderObject<RenderParagraph>(timestamp);
        final actionParagraph = tester.renderObject<RenderParagraph>(action);

        expect(timestampParagraph.didExceedMaxLines, isFalse);
        expect(actionParagraph.didExceedMaxLines, isFalse);
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
}

Future<void> _showCard(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  double scale = 1,
  bool showTimestamp = true,
}) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final availability = _AvailabilityProvider(
    showTimestamp ? DateTime.now().subtract(const Duration(minutes: 5)) : null,
  );
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

  @override
  DateTime? get lastUpdated => updatedAt;

  @override
  List<AvailabilityModel?> get availabilityModels => [];
}

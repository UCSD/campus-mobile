import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_router.dart' as campus;
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _expectedCredit =
    'Triton Credits was suggested by Kristhian Ortiz Alvarado and implemented by Prisha Jain on October 26, 2026.';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final titleFont = FontLoader('Refrigerator Deluxe')
      ..addFont(rootBundle.load('assets/fonts/Refrigerator Deluxe Bold.otf'));
    final bodyFont = FontLoader('Brix Sans')..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansMedium.otf'));
    await Future.wait([titleFont.load(), bodyFont.load()]);
  });

  for (final brightness in Brightness.values) {
    for (final layout in [
      (size: const Size(390, 844), scale: 1.0),
      (size: const Size(320, 568), scale: 3.0),
      (size: const Size(568, 320), scale: 2.0),
    ]) {
      testWidgets('credits render and scroll in ${brightness.name} mode at $layout', (tester) async {
        tester.view.physicalSize = layout.size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: false,
              brightness: brightness,
              textTheme: TextTheme(bodyMedium: brightness == Brightness.dark ? bodyMediumDark : bodyMediumLight),
            ),
            onGenerateRoute: campus.Router.generateRoute,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(layout.scale)),
              child: child!,
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.pushNamed(context, RoutePaths.TRITON_CREDITS),
                  child: const Text('Open credits'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open credits'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('TRITON CREDITS'), findsOneWidget);
        expect(find.text(_expectedCredit), findsOneWidget);
        expect(find.text('Suggested this page'), findsNothing);
        expect(find.text('Built this page'), findsNothing);
        expect(find.byType(Image), findsNWidgets(2));

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -3000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.getRect(find.text(_expectedCredit)).bottom, lessThanOrEqualTo(layout.size.height));

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text('Open credits'), findsOneWidget);
      });
    }
  }
}

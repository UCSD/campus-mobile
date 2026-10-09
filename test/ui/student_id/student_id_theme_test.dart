import 'dart:io';
import 'dart:ui' as ui;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:campus_mobile_experimental/core/providers/student_id.dart';
import 'package:campus_mobile_experimental/ui/student_id/student_id_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../student_id_test_support.dart';
import 'student_id_card_test.dart' show mountCard, resetView;

ThemeData appTheme(Brightness brightness) {
  // Match the colors and text styles used by Student ID in main.dart without
  // initializing unrelated application services or Firebase routes.
  final dark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: false,
    primaryColor: dark ? darkPrimaryColor : lightPrimaryColor,
    textTheme: (dark ? darkThemeText : lightThemeText).copyWith(
      titleLarge: dark ? cardTitleStyleDark : cardTitleStyleLight,
      titleMedium: dark ? titleMediumDark : titleMediumLight,
      titleSmall: dark ? titleSmallDark : titleSmallLight,
      bodyLarge: dark ? heading2StyleDark : heading2StyleLight,
      bodyMedium: dark ? bodyMediumDark : bodyMediumLight,
      bodySmall: dark ? descriptiveTextSmallDark : descriptiveTextSmallLight,
      labelLarge: dark ? labelLargeStyleDark : labelLargeStyleLight,
      labelMedium: dark ? labelMediumStyleDark : labelMediumStyleLight,
      headlineMedium: dark ? headlineMediumDark : headlineMediumLight,
    ),
    iconTheme: dark ? darkIconTheme : lightIconTheme,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorPrimary).copyWith(
      brightness: brightness,
      surface: dark ? darkButtonColor : lightButtonColor,
      secondary: dark ? lightAccentColor : darkAccentColor,
    ),
  );
}

Color textColor(WidgetTester tester, String text) {
  final finder = find.text(text);
  final widget = tester.widget<Text>(finder);
  return DefaultTextStyle.of(tester.element(finder)).style.merge(widget.style).color!;
}

double contrast(Color foreground, Color background) {
  final front = foreground.computeLuminance();
  final back = background.computeLuminance();
  return (front > back ? front + 0.05 : back + 0.05) / (front > back ? back + 0.05 : front + 0.05);
}

Future<void> capturePreview(WidgetTester tester, String filename, {Finder? finder}) async {
  if (!const bool.fromEnvironment('STUDENT_ID_PREVIEWS')) return;
  // Wait for asset decoding so the preview includes the photo placeholder.
  final assets = find.byType(Image);
  await tester.runAsync(() async {
    for (final element in assets.evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    finder ?? find.byKey(const ValueKey('student-id-theme-preview')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('build/student-id-themes/$filename.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    // Raster previews need real glyphs instead of the test runner's square font.
    final loader = FontLoader('Brix Sans')..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansRegular.otf'));
    await loader.load();
    final defaultFont = FontLoader('Roboto')..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansRegular.otf'));
    await defaultFont.load();
    final titleFont = FontLoader('Refrigerator Deluxe')
      ..addFont(rootBundle.load('assets/fonts/Refrigerator Deluxe Heavy.otf'));
    await titleFont.load();
    final icons = FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  for (final brightness in Brightness.values) {
    final mode = brightness.name;
    final background = brightness == Brightness.dark ? darkPrimaryBgColor : lightAccentColor;
    for (final size in [const Size(320, 640), const Size(390, 844), const Size(844, 390), const Size(1024, 768)]) {
      testWidgets('$mode theme keeps ready, loading, and failed sections legible at $size', (tester) async {
        final fixture = StudentIdTestFixture()..start();
        addTearDown(fixture.dispose);
        addTearDown(() => resetView(tester));
        final theme = appTheme(brightness);
        fixture.service.names.single.complete(testName('Alex Student'));
        fixture.service.profiles.single.complete(
          studentIdProfileModelFromJson(
            '{"Barcode":"1234567890","Classification_Type":"Undergraduate",'
            '"UG_Primary_Major_Current":"Computer Science","College_Current":"Revelle College"}',
          ),
        );
        fixture.service.photos.single.complete(testPhoto());
        await mountCard(tester, fixture, theme: theme, size: size);
        await tester.pump(const Duration(milliseconds: 300));
        final dimensions = '${size.width.toInt()}x${size.height.toInt()}';
        await capturePreview(tester, '$mode-loading-$dimensions');
        expect(contrast(textColor(tester, 'Alex Student'), background), greaterThanOrEqualTo(4.5));
        expect(contrast(textColor(tester, 'Computer Science'), background), greaterThanOrEqualTo(4.5));
        expect(contrast(textColor(tester, 'Revelle College'), background), greaterThanOrEqualTo(4.5));
        expect(contrast(textColor(tester, 'tap for easier scanning'), background), greaterThanOrEqualTo(4.5));
        final spinner = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
        final spinnerColor = spinner.color ?? theme.colorScheme.primary;
        expect(contrast(spinnerColor, background), greaterThanOrEqualTo(3));
        fixture.service.images.single.completeError(Exception('photo unavailable'));
        await tester.pumpAndSettle();
        await capturePreview(tester, '$mode-placeholder-$dimensions');
        expect(tester.takeException(), isNull);
        final barcode = tester.widget<BarcodeWidget>(find.byType(BarcodeWidget));
        expect(barcode.color, Colors.black);
        expect(barcode.backgroundColor, Colors.white);
        expect(contrast(textColor(tester, '1234567890'), Colors.white), greaterThanOrEqualTo(4.5));
        expect(contrast(textColor(tester, 'Undergraduate'), background), greaterThanOrEqualTo(4.5));
      });
    }

    testWidgets('$mode theme keeps long details legible with larger text', (tester) async {
      final fixture = StudentIdTestFixture()..start();
      addTearDown(fixture.dispose);
      addTearDown(() => resetView(tester));
      fixture.service.names.single.complete(testName('Alexandra Student Example'));
      fixture.service.profiles.single.complete(
        studentIdProfileModelFromJson(
          '{"Barcode":"1234567890123456","Classification_Type":"Undergraduate",'
          '"UG_Primary_Major_Current":"Cognitive Science and Neuroscience","College_Current":"Revelle College"}',
        ),
      );
      fixture.service.photos.single.complete(StudentIdPhotoModel());
      await mountCard(tester, fixture, theme: appTheme(brightness), size: const Size(320, 640));
      await tester.pumpAndSettle();
      await capturePreview(tester, '$mode-long-details');
      await mountCard(
        tester,
        fixture,
        theme: appTheme(brightness),
        size: const Size(320, 640),
        textScaler: TextScaler.linear(2),
      );
      await tester.pumpAndSettle();
      await capturePreview(tester, '$mode-large-text');
      expect(tester.takeException(), isNull);
    });

    testWidgets('$mode theme keeps name and barcode fallbacks and whole-card error legible', (tester) async {
      final fixture = StudentIdTestFixture()..start();
      addTearDown(fixture.dispose);
      addTearDown(() => resetView(tester));
      fixture.service.profiles.single.complete(testProfile());
      fixture.service.names.single.complete(StudentIdNameModel());
      fixture.service.photos.single.complete(StudentIdPhotoModel());
      await mountCard(tester, fixture, theme: appTheme(brightness));
      await tester.pumpAndSettle();
      expect(contrast(textColor(tester, 'Name unavailable'), background), greaterThanOrEqualTo(4.5));
      await capturePreview(tester, '$mode-name-unavailable');
      fixture.user.changeSession(pid: 'student-two', token: 'token-two');
      fixture.service.names.last.complete(testName('Alex Student'));
      fixture.service.profiles.last.complete(StudentIdProfileModel());
      fixture.service.photos.last.complete(StudentIdPhotoModel());
      await tester.pumpAndSettle();
      expect(contrast(textColor(tester, 'Barcode unavailable'), background), greaterThanOrEqualTo(4.5));
      await capturePreview(tester, '$mode-barcode-unavailable');
      fixture.user.changeSession(signOut: true);
      await tester.pumpAndSettle();
      expect(
        contrast(textColor(tester, 'An error occurred, please try again.'), background),
        greaterThanOrEqualTo(4.5),
      );
      await capturePreview(tester, '$mode-error');
      expect(tester.takeException(), isNull);
    });

    testWidgets('$mode theme keeps all partial-loading indicators visible', (tester) async {
      final fixture = StudentIdTestFixture()..start();
      addTearDown(fixture.dispose);
      addTearDown(() => resetView(tester));
      final theme = appTheme(brightness);
      fixture.service.photos.single.complete(testPhoto());
      await mountCard(tester, fixture, theme: theme);
      await tester.pump();
      fixture.service.images.single.complete(testStudentPhoto());
      await tester.pump();
      final indicators = tester.widgetList<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(indicators, hasLength(2));
      for (final indicator in indicators) {
        expect(contrast(indicator.color!, background), greaterThanOrEqualTo(3));
      }
      expect(tester.takeException(), isNull);
      fixture.service.names.single.complete(testName());
      fixture.service.profiles.single.complete(testProfile());
      await tester.pumpAndSettle();
    });

    testWidgets('$mode theme keeps popup fallback readable on its white surface', (tester) async {
      final fixture = StudentIdTestFixture()..start();
      addTearDown(fixture.dispose);
      addTearDown(() => resetView(tester));
      final theme = appTheme(brightness);
      fixture.service.names.single.complete(testName());
      fixture.service.profiles.single.complete(testProfile());
      fixture.service.photos.single.complete(StudentIdPhotoModel());
      await mountCard(tester, fixture, theme: theme);
      await tester.pump();
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(dialog.backgroundColor, Colors.white);
      expect(contrast(textColor(tester, 'Student ID'), Colors.white), greaterThanOrEqualTo(4.5));
      await capturePreview(tester, '$mode-popup', finder: find.byKey(const ValueKey('student-id-screen-preview')));
      tester.view.physicalSize = const Size(844, 390);
      await tester.pumpAndSettle();
      await capturePreview(
        tester,
        '$mode-popup-landscape',
        finder: find.byKey(const ValueKey('student-id-screen-preview')),
      );
      fixture.user.changeSession(signOut: true);
      await tester.pump();
      expect(contrast(textColor(tester, 'Barcode unavailable'), Colors.white), greaterThanOrEqualTo(4.5));
      await capturePreview(
        tester,
        '$mode-popup-fallback',
        finder: find.byKey(const ValueKey('student-id-screen-preview')),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('switching themes updates the scan hint while preserving loaded Student ID', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    fixture.service.names.single.complete(testName());
    fixture.service.profiles.single.complete(testProfile());
    fixture.service.photos.single.complete(StudentIdPhotoModel());
    await mountCard(tester, fixture, theme: appTheme(Brightness.light));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(StudentIdCard));
    final provider = context.read<StudentIdDataProvider>();
    expect(textColor(tester, 'tap for easier scanning'), linkColorLight);
    await mountCard(tester, fixture, theme: appTheme(Brightness.dark));
    await tester.pumpAndSettle();
    expect(textColor(tester, 'tap for easier scanning'), linkColorDark);
    expect(provider.hasBarcode, isTrue);
    expect(fixture.service.profiles, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}

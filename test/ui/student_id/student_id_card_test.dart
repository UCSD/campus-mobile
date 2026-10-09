import 'package:barcode_widget/barcode_widget.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/student_id.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/student_id/student_id_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../student_id_test_support.dart';

Future<void> mountCard(
  WidgetTester tester,
  StudentIdTestFixture fixture, {
  Size size = const Size(390, 844),
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StudentIdDataProvider>.value(value: fixture.provider),
        ChangeNotifierProvider<CardsDataProvider>(create: (_) => CardsDataProvider()..cardStates['student_id'] = true),
      ],
      child: MaterialApp(
        theme: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: RepaintBoundary(key: const ValueKey('student-id-screen-preview'), child: child),
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: RepaintBoundary(key: const ValueKey('student-id-theme-preview'), child: StudentIdCard()),
            ),
          ),
        ),
      ),
    ),
  );
}

void resetView(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

void main() {
  setUpAll(() async {
    // Use real glyph widths when checking long text and accessibility scaling.
    final loader = FontLoader('Roboto')..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansRegular.otf'));
    await loader.load();
    final brix = FontLoader('Brix Sans')..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansRegular.otf'));
    await brix.load();
  });

  testWidgets('popup adapts to rotation with a long valid barcode', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    fixture.service.names.single.complete(testName());
    fixture.service.profiles.single.complete(testProfile('123456789012345678901234567890'));
    fixture.service.photos.single.complete(StudentIdPhotoModel());
    await mountCard(tester, fixture, size: const Size(320, 640));
    await tester.pump();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(640, 320);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('popup stays isolated if a new user receives the same barcode', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    fixture.service.names.single.complete(testName());
    fixture.service.profiles.single.complete(testProfile());
    fixture.service.photos.single.complete(StudentIdPhotoModel());
    await mountCard(tester, fixture);
    await tester.pump();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    fixture.user.changeSession(pid: 'student-two', token: 'token-two');
    fixture.service.names.last.complete(testName('Student Two'));
    fixture.service.profiles.last.complete(testProfile());
    fixture.service.photos.last.complete(StudentIdPhotoModel());
    await tester.pump();
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.byType(BarcodeWidget)), findsNothing);
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('Barcode unavailable')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('popup follows a valid barcode replacement during refresh', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    fixture.service.names.single.complete(testName());
    fixture.service.profiles.single.complete(testProfile());
    fixture.service.photos.single.complete(testPhoto());
    await mountCard(tester, fixture);
    await tester.pump();
    fixture.service.images.single.complete(testStudentPhoto());
    await tester.pump();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    fixture.provider.fetchData();
    fixture.service.names.last.complete(testName());
    fixture.service.profiles.last.complete(testProfile('9876543210'));
    fixture.service.photos.last.complete(testPhoto());
    await tester.pump();
    fixture.service.images.last.complete(testStudentPhoto());
    await tester.pump();
    final popupBarcode = find.descendant(of: find.byType(AlertDialog), matching: find.byType(BarcodeWidget));
    expect(popupBarcode, findsOneWidget);
    expect(String.fromCharCodes(tester.widget<BarcodeWidget>(popupBarcode).data), '9876543210');
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('popup can rebuild after its source card is removed', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(844, 390);
    fixture.service.names.single.complete(testName());
    fixture.service.profiles.single.complete(testProfile());
    fixture.service.photos.single.complete(StudentIdPhotoModel());
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StudentIdDataProvider>.value(value: fixture.provider),
          ChangeNotifierProvider<CardsDataProvider>(
            create: (_) => CardsDataProvider()..cardStates['student_id'] = true,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: visible,
              // Home displays its cards in a scrolling list, including in landscape.
              builder: (_, value, __) =>
                  SingleChildScrollView(child: value ? StudentIdCard() : const SizedBox.shrink()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    visible.value = false;
    await tester.pump();
    fixture.provider.fetchData();
    await tester.pump();
    expect(tester.takeException(), isNull);
    fixture.service.photos.last.complete(StudentIdPhotoModel());
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('proxy registration loads once and responds safely to authentication changes', (tester) async {
    final fixture = StudentIdTestFixture();
    addTearDown(fixture.user.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserDataProvider>.value(value: fixture.user),
          ChangeNotifierProxyProvider<UserDataProvider, StudentIdDataProvider>(
            create: (_) => StudentIdDataProvider(service: fixture.service),
            update: (_, user, studentId) => studentId!..userDataProvider = user,
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final studentId = context.watch<StudentIdDataProvider>();
              return Text(studentId.hasName ? studentId.studentIdNameModel.displayName : 'Loading');
            },
          ),
        ),
      ),
    );
    expect(fixture.service.names, hasLength(1));
    fixture.service.names.single.complete(testName());
    fixture.service.profiles.single.complete(testProfile());
    fixture.service.photos.single.complete(StudentIdPhotoModel());
    await tester.pump();
    expect(find.text('Student One'), findsOneWidget);
    fixture.user.notifyListeners();
    await tester.pump();
    expect(fixture.service.names, hasLength(1));
    fixture.user.changeSession(pid: 'student-two', token: 'token-two');
    await tester.pump();
    expect(find.text('Student One'), findsNothing);
    expect(fixture.service.names, hasLength(2));
    fixture.service.names.last.complete(testName('Student Two'));
    fixture.service.profiles.last.complete(testProfile());
    fixture.service.photos.last.complete(StudentIdPhotoModel());
    await tester.pump();
    fixture.user.changeSession(signOut: true);
    await tester.pump();
    expect(find.text('Student Two'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an open popup clears the previous barcode on sign-out', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    fixture.service.names.single.complete(testName());
    fixture.service.profiles.single.complete(testProfile());
    fixture.service.photos.single.complete(StudentIdPhotoModel());
    await mountCard(tester, fixture);
    await tester.pump();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    fixture.user.changeSession(signOut: true);
    await tester.pump();
    expect(find.byType(BarcodeWidget, skipOffstage: false), findsNothing);
    expect(find.text('1234567890'), findsNothing);
    expect(find.text('Barcode unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('barcode alone retains the card with name/photo fallbacks', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    fixture.service.names.single.completeError(Exception('name'));
    fixture.service.photos.single.completeError(Exception('photo'));
    fixture.service.profiles.single.complete(testProfile());
    await mountCard(tester, fixture);
    await tester.pump();
    expect(find.text('Name unavailable'), findsOneWidget);
    expect(find.text('tap for easier scanning'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('Barcode unavailable'), findsNothing);
    expect(find.byType(Divider), findsNothing);
    final placeholder = tester.widget<Image>(find.byType(Image));
    expect((placeholder.image as AssetImage).assetName, 'assets/images/staff_id_placeholder.png');
    expect(tester.takeException(), isNull);
  });

  testWidgets('name alone disables scanning and omits unavailable fields and divider', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    fixture.service.names.single.complete(testName());
    fixture.service.photos.single.complete(StudentIdPhotoModel());
    fixture.service.profiles.single.complete(StudentIdProfileModel());
    await mountCard(tester, fixture);
    await tester.pump();
    expect(find.text('Student One'), findsOneWidget);
    expect(find.text('Barcode unavailable'), findsOneWidget);
    expect(find.text('tap for easier scanning'), findsNothing);
    expect(find.byType(BarcodeWidget), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(Divider), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('photo-only load starts behind whole-card spinner and becomes usable', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    fixture.service.names.single.complete(StudentIdNameModel());
    fixture.service.profiles.single.complete(StudentIdProfileModel());
    fixture.service.photos.single.complete(testPhoto());
    await mountCard(tester, fixture);
    await tester.pump();
    expect(fixture.service.images, hasLength(1));
    expect(tester.widget<CardContainer>(find.byType(CardContainer)).isLoading, isTrue);
    expect(find.byType(RawImage), findsNothing);
    fixture.service.images.single.complete(testStudentPhoto());
    await tester.pump();
    expect(find.byType(RawImage), findsOneWidget);
    expect(find.text('Name unavailable'), findsOneWidget);
    expect(find.text('Barcode unavailable'), findsOneWidget);
    expect(tester.widget<CardContainer>(find.byType(CardContainer)).errorText, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('image failure ends loading and displays exact error without verification', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    fixture.service.names.single.complete(StudentIdNameModel());
    fixture.service.profiles.single.complete(studentIdProfileModelFromJson('{"College_Current":"Revelle"}'));
    fixture.service.photos.single.complete(testPhoto());
    await mountCard(tester, fixture);
    await tester.pump();
    expect(find.text('Revelle'), findsNothing);
    fixture.service.images.single.completeError(Exception('decode'));
    await tester.pump();
    expect(find.text('An error occurred, please try again.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Name unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('valid academics survive an invalid barcode when name is usable', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    addTearDown(() => resetView(tester));
    fixture.service.names.single.complete(testName());
    fixture.service.photos.single.complete(StudentIdPhotoModel());
    fixture.service.profiles.single.complete(
      studentIdProfileModelFromJson(
        '{"Barcode":"bad","College_Current":"Revelle","UG_Primary_Major_Current":"Biology"}',
      ),
    );
    await mountCard(tester, fixture);
    await tester.pump();
    expect(find.text('Revelle'), findsOneWidget);
    expect(find.text('Biology'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.text('Barcode unavailable'), findsOneWidget);
    expect(find.byType(BarcodeWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 640), const Size(390, 844), const Size(844, 390), const Size(1024, 768)]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('card aligns details and barcode at $size with text scale $scale', (tester) async {
        final fixture = StudentIdTestFixture()..start();
        addTearDown(fixture.dispose);
        addTearDown(() => resetView(tester));
        const name = 'A Very Long Student Display Name';
        const classification = 'Undergraduate student classification';
        const major = 'A very long major name';
        const college = 'A very long college name';
        fixture.service.names.single.complete(testName(name));
        fixture.service.profiles.single.complete(
          studentIdProfileModelFromJson(
            '{"Barcode":"1234567890123456","Classification_Type":"$classification",'
            '"College_Current":"$college","UG_Primary_Major_Current":"$major"}',
          ),
        );
        fixture.service.photos.single.complete(StudentIdPhotoModel());
        await mountCard(tester, fixture, size: size, textScaler: TextScaler.linear(scale));
        await tester.pumpAndSettle();

        final photo = tester.getRect(find.byKey(const ValueKey('student-id-photo')));
        final nameBounds = tester.getRect(find.text(name));
        expect(photo.top, closeTo(nameBounds.top, 0.01));
        expect(photo.right, lessThan(nameBounds.left));
        expect(photo.width, lessThanOrEqualTo(120));
        expect(photo.height / photo.width, closeTo(1.25, 0.01));
        for (final label in [classification, major, college]) {
          expect(tester.getRect(find.text(label)).left, closeTo(nameBounds.left, 0.01));
        }
        final divider = tester.getRect(find.byType(Divider));
        expect(divider.left, closeTo(nameBounds.left, 0.01));
        expect(divider.right, closeTo(nameBounds.right, 0.01));

        final surface = tester.getRect(find.byKey(const ValueKey('student-id-inline-barcode')));
        final bars = tester.getRect(find.byType(BarcodeWidget));
        final number = tester.getRect(find.text('1234567890123456'));
        expect(surface.top, greaterThan(tester.getRect(find.text(college)).bottom));
        // Preserve the original photo-left, details-and-barcode-right layout.
        expect(surface.left, closeTo(nameBounds.left, 0.01));
        expect(surface.right, closeTo(nameBounds.right, 0.01));
        expect(surface.left, greaterThan(photo.right));
        expect(surface.center.dx, closeTo(nameBounds.center.dx, 0.01));
        expect(bars.left - surface.left, closeTo(16, 0.01));
        expect(surface.right - bars.right, closeTo(16, 0.01));
        expect(bars.height, inInclusiveRange(40, 64));
        expect(number.center.dx, closeTo(bars.center.dx, 0.01));
        expect(number.top, greaterThanOrEqualTo(bars.bottom));
        expect(number.width, lessThanOrEqualTo(bars.width));
        final barcode = tester.widget<BarcodeWidget>(find.byType(BarcodeWidget));
        expect(String.fromCharCodes(barcode.data), '1234567890123456');
        expect(barcode.drawText, isFalse);
        expect(barcode.color, Colors.black);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('photo transitions keep bounds/details stable at $size', (tester) async {
      final fixture = StudentIdTestFixture()..start();
      addTearDown(fixture.dispose);
      addTearDown(() => resetView(tester));
      fixture.service.names.single.complete(testName('A Very Long Student Display Name'));
      fixture.service.profiles.single.complete(
        studentIdProfileModelFromJson(
          '{"Barcode":"1234567890123456","Classification_Type":"Undergraduate student classification",'
          '"College_Current":"A very long college name","UG_Primary_Major_Current":"A very long major name"}',
        ),
      );
      fixture.service.photos.single.complete(testPhoto());
      await mountCard(tester, fixture, size: size);
      await tester.pump();
      final photoBounds = tester.getRect(find.byKey(const ValueKey('student-id-photo')));
      final detailsPosition = tester.getTopLeft(find.text('A Very Long Student Display Name'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
      fixture.service.images.single.completeError(Exception('image unavailable'));
      await tester.pump();
      expect(tester.getRect(find.byKey(const ValueKey('student-id-photo'))), photoBounds);
      expect(tester.getTopLeft(find.text('A Very Long Student Display Name')), detailsPosition);
      expect(tester.takeException(), isNull);
      fixture.provider.fetchData();
      await tester.pump();
      fixture.service.images.last.complete(testStudentPhoto());
      await tester.pump();
      expect(tester.getRect(find.byKey(const ValueKey('student-id-photo'))), photoBounds);
      expect(tester.getTopLeft(find.text('A Very Long Student Display Name')), detailsPosition);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RawImage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('popup uses the card barcode without overflow at $size', (tester) async {
      final fixture = StudentIdTestFixture()..start();
      addTearDown(fixture.dispose);
      addTearDown(() => resetView(tester));
      fixture.service.names.single.complete(testName());
      fixture.service.profiles.single.complete(testProfile());
      fixture.service.photos.single.complete(StudentIdPhotoModel());
      await mountCard(tester, fixture, size: size);
      await tester.pump();
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      final barcodes = tester.widgetList<BarcodeWidget>(find.byType(BarcodeWidget, skipOffstage: false));
      expect(barcodes.length, 2);
      expect(barcodes.map((widget) => String.fromCharCodes(widget.data)), everyElement('1234567890'));
      final popupBarcode = find.descendant(of: find.byType(AlertDialog), matching: find.byType(BarcodeWidget));
      final barcodeBounds = tester.getRect(popupBarcode);
      final titleBounds = tester.getRect(find.text('Student ID'));
      final scanningBounds = tester.getRect(find.byKey(const ValueKey('student-id-scanning-area')));
      expect(barcodeBounds.top - titleBounds.bottom, lessThanOrEqualTo(36));
      final portrait = size.height > size.width;
      final barLength = portrait ? barcodeBounds.width : barcodeBounds.height;
      expect(barLength, greaterThan(0));
      expect(barLength, lessThanOrEqualTo(120));
      if (portrait) {
        expect(barcodeBounds.height, closeTo(scanningBounds.height - 24, 0.01));
        // The bars and printed number stay centered together in the dialog.
        expect(barcodeBounds.center.dx - 20, closeTo(scanningBounds.center.dx, 0.01));
      } else {
        expect(barcodeBounds.width, closeTo(scanningBounds.width - 24, 0.01));
        expect(barcodeBounds.center.dx, closeTo(scanningBounds.center.dx, 0.01));
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });
  }
}

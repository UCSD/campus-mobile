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
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../student_id_test_support.dart';

Future<void> mountCard(WidgetTester tester, StudentIdTestFixture fixture, {Size size = const Size(390, 844)}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StudentIdDataProvider>.value(value: fixture.provider),
        ChangeNotifierProvider<CardsDataProvider>(create: (_) => CardsDataProvider()..cardStates['student_id'] = true),
      ],
      child: MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: StudentIdCard())),
      ),
    ),
  );
}

void resetView(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

void main() {
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

  for (final size in [const Size(320, 640), const Size(390, 844), const Size(844, 390)]) {
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
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });
  }
}

import 'dart:ui' as ui;

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_router.dart' as campus;
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/ui/triton_credits/credit.dart';
import 'package:campus_mobile_experimental/ui/triton_credits/triton_credits.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

const _expectedCredit =
    'Triton Credits was suggested by Kristhian Ortiz and implemented by Prisha Jain on October 2, 2026.';
const _expectedWaitlistedCredit =
    'Show Waitlisted Classes was suggested by Saeli Yuki and implemented by Gibson Connor on October 24, 2026.';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final titleFont = FontLoader('Refrigerator Deluxe')
      ..addFont(rootBundle.load('assets/fonts/Refrigerator Deluxe Bold.otf'));
    final bodyFont = FontLoader('Brix Sans')..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansMedium.otf'));
    bodyFont.addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansRegular.otf'));
    bodyFont.addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansBold.otf'));
    await Future.wait([titleFont.load(), bodyFont.load()]);
  });

  for (final brightness in Brightness.values) {
    for (final layout in [
      (size: const Size(390, 844), scale: 1.0),
      (size: const Size(320, 568), scale: 3.0),
      (size: const Size(568, 320), scale: 2.0),
      (size: const Size(1024, 768), scale: 1.0),
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
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(layout.scale), padding: const EdgeInsets.only(bottom: 34)),
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
        expect(find.text(_expectedWaitlistedCredit), findsOneWidget);
        expect(find.textContaining('Alvarado'), findsNothing);
        final creditText = tester.widget<Text>(find.text(_expectedCredit));
        final creditSpans = (creditText.textSpan as TextSpan).children!.whereType<TextSpan>();
        expect(creditSpans.where((span) => span.style?.fontWeight == FontWeight.bold).map((span) => span.text), [
          'Triton Credits',
          'Kristhian Ortiz',
          'Prisha Jain',
        ]);
        expect(creditText.style!.fontWeight, FontWeight.w400);
        expect(creditSpans.last.text, ' on October 2, 2026.');
        expect(creditSpans.last.style?.fontWeight, isNull);
        final waitlistedText = tester.widget<Text>(find.text(_expectedWaitlistedCredit));
        final waitlistedSpans = (waitlistedText.textSpan as TextSpan).children!.whereType<TextSpan>();
        expect(waitlistedSpans.where((span) => span.style?.fontWeight == FontWeight.bold).map((span) => span.text), [
          'Show Waitlisted Classes',
          'Saeli Yuki',
          'Gibson Connor',
        ]);
        expect(find.text('Suggested this page'), findsNothing);
        expect(find.text('Built this page'), findsNothing);
        expect(find.byType(Image), findsNWidgets(3));
        expect(find.textContaining('Have an idea? Submit a feedback ticket to '), findsOneWidget);
        expect(find.textContaining('and you could be immortalized on this page!'), findsOneWidget);
        final invitation = tester.widget<Text>(find.textContaining('Have an idea?'));
        expect(invitation.textSpan!.toPlainText(), contains('to Feedback & Support and you could be immortalized'));
        expect(find.byType(Divider), findsOneWidget);
        final invitationRect = tester.getRect(find.textContaining('Have an idea?'));
        final invitationTapRect = tester.getRect(
          find.ancestor(of: find.textContaining('Have an idea?'), matching: find.byType(InkWell)).first,
        );
        final thanksRect = tester.getRect(find.text('Thank you for contributing to your campus mobile app!'));
        final heading = find.text('UCSD Campus Mobile App Contributions');
        final headingRect = tester.getRect(heading);
        expect(tester.widget<Text>(heading).textAlign, TextAlign.center);
        final descriptionRect = tester.getRect(find.textContaining('This page is dedicated'));
        final dividerRect = tester.getRect(find.byType(Divider));
        final firstCreditRect = tester.getRect(find.text(_expectedWaitlistedCredit));
        final lastCreditRect = tester.getRect(find.text(_expectedCredit));
        expect(invitationRect.bottom, lessThanOrEqualTo(dividerRect.top));
        expect(invitationTapRect.height, greaterThanOrEqualTo(48));
        expect(thanksRect.top - lastCreditRect.bottom, closeTo(24, 0.01));
        expect(dividerRect.bottom, lessThanOrEqualTo(headingRect.top));
        expect(headingRect.bottom, lessThanOrEqualTo(firstCreditRect.top));
        expect(dividerRect.bottom, lessThanOrEqualTo(firstCreditRect.top));
        expect(firstCreditRect.bottom, lessThanOrEqualTo(lastCreditRect.top));
        for (final rect in [
          descriptionRect,
          invitationRect,
          thanksRect,
          headingRect,
          firstCreditRect,
          lastCreditRect,
        ]) {
          expect(rect.left, closeTo(dividerRect.left, 0.01));
          expect(rect.right, closeTo(dividerRect.right, 0.01));
        }
        expect(dividerRect.width, lessThanOrEqualTo(560));
        expect(dividerRect.left, greaterThanOrEqualTo(24));
        expect(dividerRect.center.dx, closeTo(layout.size.width / 2, 0.01));
        for (final image in find.byType(Image).evaluate()) {
          expect(tester.getRect(find.byWidget(image.widget)).center.dx, closeTo(dividerRect.center.dx, 0.01));
        }

        final scrollable = tester.state<ScrollableState>(
          find.descendant(of: find.byType(SingleChildScrollView), matching: find.byType(Scrollable)),
        );
        await tester.drag(
          find.byType(SingleChildScrollView),
          Offset(0, -scrollable.position.maxScrollExtent - layout.size.height),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.getRect(find.text('Thank you for contributing to your campus mobile app!')).bottom,
          lessThanOrEqualTo(layout.size.height - 34),
        );

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text('Open credits'), findsOneWidget);
      });
    }
  }

  for (final count in [0, 1, 3]) {
    testWidgets('$count credits have decorative separators only between entries', (tester) async {
      final entries = List.generate(
        count,
        (index) => credit(
          feature: 'Feature $index',
          ideaOwner: 'Idea $index',
          devName: 'Developer $index',
          date: DateTime(2026, 11, 1),
        ),
      );
      await tester.pumpWidget(MaterialApp(home: TritonCredits(credits: entries)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final tridents = find.byWidgetPredicate((widget) => widget is Image && widget.width == 20 && widget.height == 20);
      expect(tridents, findsNWidgets(count > 0 ? count - 1 : 0));
      expect(find.byType(Divider), findsOneWidget);
      for (var index = 0; index < count - 1; index++) {
        final trident = tridents.at(index);
        final tridentRect = tester.getRect(trident);
        expect(tridentRect.center.dx, closeTo(tester.view.physicalSize.width / tester.view.devicePixelRatio / 2, 0.01));
        expect(tridentRect.top, greaterThan(tester.getRect(find.text(entries[index].description)).bottom));
        expect(tridentRect.bottom, lessThan(tester.getRect(find.text(entries[index + 1].description)).top));

        final row = tester.widget<Row>(find.ancestor(of: trident, matching: find.byType(Row)).first);
        final symbols = row.children
            .where((widget) => widget is Image || widget is SizedBox && widget.child is DecoratedBox)
            .toList();
        expect(symbols, hasLength(5));
        expect(symbols[2], isA<Image>());
        for (final symbol in [symbols[0], symbols[1], symbols[3], symbols[4]]) {
          final dot = (symbol as SizedBox).child as DecoratedBox;
          expect((dot.decoration as BoxDecoration).shape, BoxShape.circle);
        }
      }
    });
  }

  testWidgets('credits sort newest first and preserve input order for the same calendar date', (tester) async {
    final dates = [
      DateTime(2025, 12, 31),
      DateTime(2026, 10, 24),
      DateTime(2026, 1, 1),
      DateTime.utc(2026, 10, 24, 23),
      DateTime(2026, 11, 1),
    ];
    final entries = List<Credit>.unmodifiable(
      List.generate(
        dates.length,
        (index) => credit(
          feature: 'Feature $index',
          ideaOwner: 'Idea $index',
          devName: 'Developer $index',
          date: dates[index],
        ),
      ),
    );
    await tester.pumpWidget(MaterialApp(home: TritonCredits(credits: entries)));
    await tester.pumpAndSettle();

    final renderedCredits = tester.widgetList<Text>(find.textContaining(' was suggested by '));
    expect(renderedCredits.map((text) => text.textSpan!.toPlainText()), [
      for (final index in [4, 1, 3, 2, 0]) entries[index].description,
    ]);
    expect(entries.map((entry) => entry.feature), ['Feature 0', 'Feature 1', 'Feature 2', 'Feature 3', 'Feature 4']);
    expect(
      tester.getRect(find.text('Thank you for contributing to your campus mobile app!')).top,
      greaterThan(tester.getRect(find.text(entries.first.description)).bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('feedback link opens the same support form as the Profile menu', (tester) async {
    final previousLauncher = UrlLauncherPlatform.instance;
    final launcher = _FeedbackLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previousLauncher);

    await tester.pumpWidget(const MaterialApp(home: TritonCredits()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('Have an idea?'));
    await tester.pumpAndSettle();
    final semantics = tester.ensureSemantics();
    try {
      await tester.pump();
      expect(
        find.semantics.byLabel(RegExp('Have an idea\\?')).evaluate().single,
        isSemantics(
          label:
              'Have an idea? Submit a feedback ticket to Feedback & Support and you could be immortalized on this page!',
          isLink: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );
      expect(
        find.semantics.byLabel('UCSD Campus Mobile App Contributions').evaluate().single,
        isSemantics(label: 'UCSD Campus Mobile App Contributions', isHeader: true),
      );
    } finally {
      semantics.dispose();
    }
    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: find.textContaining('Have an idea?'), matching: find.byType(RichText)),
    );
    final linkStart = paragraph.text.toPlainText().indexOf('Feedback & Support');
    final linkBoxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: linkStart, extentOffset: linkStart + 'Feedback & Support'.length),
    );
    await tester.tapAt(paragraph.localToGlobal(linkBoxes.first.toRect().center));
    await tester.pumpAndSettle();

    expect(launcher.launchedUrl, 'https://eforms.ucsd.edu/view.php?id=857622');
    expect(launcher.options!.mode, PreferredLaunchMode.inAppBrowserView);
    expect(launcher.launchCount, 1);

    final tapArea = find.ancestor(of: find.textContaining('Have an idea?'), matching: find.byType(InkWell)).first;
    final tapRect = tester.getRect(tapArea);
    // The padded area remains tappable even outside the text's glyph bounds.
    await tester.tapAt(Offset(tapRect.center.dx, tapRect.top + 2));
    await tester.pumpAndSettle();
    expect(launcher.launchCount, 2);

    // Keyboard users can focus and activate the same link.
    Focus.of(tester.element(find.textContaining('Have an idea?'))).requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(launcher.launchCount, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('feedback invitation visibly highlights while pressed and clears on cancellation', (tester) async {
    final previousLauncher = UrlLauncherPlatform.instance;
    final launcher = _FeedbackLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previousLauncher);

    const boundaryKey = ValueKey('credits-paint');
    await tester.pumpWidget(
      const MaterialApp(
        home: RepaintBoundary(key: boundaryKey, child: TritonCredits()),
      ),
    );
    await tester.pumpAndSettle();
    final tapArea = find.ancestor(of: find.textContaining('Have an idea?'), matching: find.byType(InkWell)).first;
    await tester.ensureVisible(tapArea);
    await tester.pumpAndSettle();
    final tapRect = tester.getRect(tapArea);
    final point = Offset(tapRect.center.dx, tapRect.top + 4);
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(boundaryKey));
    final before = await _readPixel(tester, boundary, point);

    final gesture = await tester.startGesture(point);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    final pressed = await _readPixel(tester, boundary, point);
    // Check the painted feedback itself, including the padded touch area.
    for (var channel = 0; channel < 3; channel++) {
      expect(pressed[channel], greaterThan(before[channel]));
    }
    expect(launcher.launchCount, 0);

    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(await _readPixel(tester, boundary, point), before);
    expect(launcher.launchCount, 0);
    expect(tester.takeException(), isNull);
  });
}

Future<List<int>> _readPixel(WidgetTester tester, RenderRepaintBoundary boundary, Offset globalPoint) async {
  final pixel = await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final point = boundary.globalToLocal(globalPoint);
      final offset = (point.dy.floor() * image.width + point.dx.floor()) * 4;
      return bytes!.buffer.asUint8List(bytes.offsetInBytes + offset, 4).toList();
    } finally {
      image.dispose();
    }
  });
  return pixel!;
}

class _FeedbackLauncher extends UrlLauncherPlatform {
  int launchCount = 0;
  String? launchedUrl;
  LaunchOptions? options;

  @override
  get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchCount++;
    launchedUrl = url;
    this.options = options;
    return true;
  }
}

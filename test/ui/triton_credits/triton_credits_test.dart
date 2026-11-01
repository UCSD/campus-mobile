import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_router.dart' as campus;
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/ui/triton_credits/triton_credits.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

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
        expect(find.textContaining('Have an idea? Submit a feedback ticket to '), findsOneWidget);
        expect(
          find.textContaining(
            'and you could be immortalized in this page! Thank you for contributing to improving your campus app.',
          ),
          findsOneWidget,
        );
        expect(find.text('Feedback & Support'), findsOneWidget);
        expect(find.byType(Divider), findsOneWidget);
        final invitationRect = tester.getRect(find.textContaining('Have an idea?'));
        final dividerRect = tester.getRect(find.byType(Divider));
        final creditRect = tester.getRect(find.text(_expectedCredit));
        expect(invitationRect.bottom, lessThanOrEqualTo(dividerRect.top));
        expect(dividerRect.bottom, lessThanOrEqualTo(creditRect.top));

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

  testWidgets('feedback link opens the same support form as the Profile menu', (tester) async {
    final previousLauncher = UrlLauncherPlatform.instance;
    final launcher = _FeedbackLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previousLauncher);

    await tester.pumpWidget(const MaterialApp(home: TritonCredits()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Feedback & Support'));
    await tester.tap(find.text('Feedback & Support'));
    await tester.pumpAndSettle();

    expect(launcher.launchedUrl, 'https://eforms.ucsd.edu/view.php?id=857622');
    expect(launcher.options!.mode, PreferredLaunchMode.inAppBrowserView);
    expect(tester.takeException(), isNull);
  });
}

class _FeedbackLauncher extends UrlLauncherPlatform {
  String? launchedUrl;
  LaunchOptions? options;

  @override
  get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    this.options = options;
    return true;
  }
}

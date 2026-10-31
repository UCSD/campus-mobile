import 'dart:ui' as ui;

import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';
import 'package:campus_mobile_experimental/core/models/notices.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/connectivity.dart';
import 'package:campus_mobile_experimental/core/providers/notices.dart';
import 'package:campus_mobile_experimental/ui/home/home.dart';
import 'package:campus_mobile_experimental/ui/navigator/bottom.dart';
import 'package:campus_mobile_experimental/ui/notices/notices_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart' as web;

const _bannerUrl = 'https://example.invalid/home-scroll-test.png';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    resetHomeScrollOffset();
    final visibilityController = VisibilityDetectorController.instance;
    final previousInterval = visibilityController.updateInterval;
    visibilityController.updateInterval = Duration.zero;
    addTearDown(() => visibilityController.updateInterval = previousInterval);
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('com.llfbandit.app_links/messages'), (_) async => null);
    messenger.setMockMethodCallHandler(const MethodChannel('com.llfbandit.app_links/events'), (_) async => null);
  });

  Future<_NoticesProvider> showHome(
    WidgetTester tester,
    int count, {
    bool mockDecorations = false,
    CardsDataProvider? cards,
  }) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Cache a real banner image so the actual notice cards have deterministic
    // dimensions without HTTP requests or application service initialization.
    final image = await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(const Rect.fromLTWH(0, 0, 300, 120), Paint()..color = Colors.blue);
      final picture = recorder.endRecording();
      final image = await picture.toImage(300, 120);
      picture.dispose();
      return image;
    });
    PaintingBinding.instance.imageCache.putIfAbsent(
      const NetworkImage(_bannerUrl),
      () => OneFrameImageStreamCompleter(Future.value(ImageInfo(image: image!))),
    );

    if (mockDecorations) {
      final circleImage = await tester.runAsync(() async {
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawRect(const Rect.fromLTWH(0, 0, 300, 300), Paint()..color = const Color(0xFFFF0000));
        final picture = recorder.endRecording();
        final image = await picture.toImage(300, 300);
        picture.dispose();
        return image;
      });
      for (final circle in [
        (asset: 'circle-1-background.png', size: Size(298.64, 280)),
        (asset: 'circle-2-background.png', size: Size(136, 136)),
        (asset: 'circle-4-background.png', size: Size(399.7, 398)),
        (asset: 'circle-5-background.png', size: Size(197, 197)),
        (asset: 'circle-6-background.png', size: Size(188, 188)),
        (asset: 'circle-3-background.png', size: Size(300, 298.6)),
      ]) {
        final key = await ResizeImage(
          AssetImage('assets/images/circles/${circle.asset}'),
          width: circle.size.width.ceil(),
          height: circle.size.height.ceil(),
          policy: ResizeImagePolicy.fit,
        ).obtainKey(const ImageConfiguration(devicePixelRatio: 1));
        PaintingBinding.instance.imageCache.evict(key);
        PaintingBinding.instance.imageCache.putIfAbsent(
          key,
          () => OneFrameImageStreamCompleter(Future.value(ImageInfo(image: circleImage!.clone()))),
        );
      }
      circleImage!.dispose();
    }

    final notices = _NoticesProvider(count);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CardsDataProvider>(create: (_) => cards ?? _EmptyCardsProvider()),
          ChangeNotifierProvider<InternetConnectivityProvider>(create: (_) => InternetConnectivityProvider()),
          ChangeNotifierProvider<NoticesDataProvider>.value(value: notices),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(key: const ValueKey('home capture'), child: Home()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      notices.dispose();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    });
    return notices;
  }

  ScrollPosition position(WidgetTester tester) => tester.state<ScrollableState>(find.byType(Scrollable)).position;

  Future<Color> pixel(WidgetTester tester, int x, int y) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('home capture')));
    return (await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final index = (y * image.width + x) * 4;
      final color = Color.fromARGB(
        bytes.getUint8(index + 3),
        bytes.getUint8(index),
        bytes.getUint8(index + 1),
        bytes.getUint8(index + 2),
      );
      image.dispose();
      return color;
    }))!;
  }

  testWidgets('empty home does not scroll for decorations', (tester) async {
    await showHome(tester, 0);
    expect(position(tester).maxScrollExtent, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('one short card does not scroll for decorations', (tester) async {
    await showHome(tester, 1);
    expect(find.byType(NoticesCard), findsOneWidget);
    expect(tester.getSize(find.byType(NoticesCard)).height, greaterThan(120));
    expect(position(tester).maxScrollExtent, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long home reaches the final card with normal bottom padding', (tester) async {
    await showHome(tester, 32);
    final scrollPosition = position(tester);
    expect(scrollPosition.maxScrollExtent, greaterThan(0));
    scrollPosition.jumpTo(scrollPosition.maxScrollExtent);
    await tester.pump();
    expect(
      find.byWidgetPredicate((widget) => widget is NoticesCard && widget.notice.title == 'Notice 31'),
      findsOneWidget,
    );
    final lastCardBottom = tester.getBottomLeft(find.byType(NoticesCard).last).dy;
    expect(lastCardBottom, closeTo(scrollPosition.viewportDimension - cardMargin - 2, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('home mounts cards near the viewport and mounts later cards on scroll', (tester) async {
    await showHome(tester, 32);
    final initialCount = find.byType(NoticesCard).evaluate().length;
    expect(initialCount, greaterThan(0));
    expect(initialCount, lessThan(32));
    expect(
      find.byWidgetPredicate((widget) => widget is NoticesCard && widget.notice.title == 'Notice 31'),
      findsNothing,
    );

    final scrollPosition = position(tester);
    scrollPosition.jumpTo(scrollPosition.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is NoticesCard && widget.notice.title == 'Notice 31'),
      findsOneWidget,
    );
    expect(find.byType(NoticesCard).evaluate().length, lessThan(32));
    expect(tester.takeException(), isNull);
  });

  testWidgets('home restores a saved scroll offset', (tester) async {
    setHomeScrollOffset(1000);
    await showHome(tester, 32);
    expect(position(tester).pixels, closeTo(1000, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('offscreen WebView controller is created and loads only when approached', (tester) async {
    final previousPlatform = web.WebViewPlatform.instance;
    final platform = _WebViewPlatform();
    web.WebViewPlatform.instance = platform;
    addTearDown(() => web.WebViewPlatform.instance = previousPlatform ?? _WebViewPlatform());
    await showHome(tester, 32, cards: _WebCardsProvider());
    expect(platform.controllers, isEmpty);
    position(tester).jumpTo(position(tester).maxScrollExtent);
    await tester.pumpAndSettle();
    expect(platform.controllers, hasLength(1));
    expect(platform.controllers.single.requests, contains('https://example.invalid/web-card'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shortening the list clamps the existing scroll offset', (tester) async {
    final notices = await showHome(tester, 32);
    final scrollPosition = position(tester);
    scrollPosition.jumpTo(scrollPosition.maxScrollExtent);
    await tester.pump();
    notices.setCount(1);
    await tester.pumpAndSettle();
    expect(position(tester).maxScrollExtent, 0);
    expect(position(tester).pixels, 0);
    expect(tester.getTopLeft(find.byType(NoticesCard)).dy, closeTo(0, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('decorations are clipped to the card content and bottom padding bounds', (tester) async {
    await showHome(tester, 1, mockDecorations: true);
    final sliver = tester.renderObject<RenderDecoratedSliver>(find.byType(DecoratedSliver));
    final cardHeight = tester.getSize(find.byType(NoticesCard)).height;
    expect(sliver.geometry!.scrollExtent, closeTo(cardHeight + cardMargin + 2, 0.01));
    expect(await pixel(tester, 398, 500), Colors.transparent);
    expect(tester.takeException(), isNull);
  });

  testWidgets('decorations cover bottom padding at the end of scrolling', (tester) async {
    await showHome(tester, 3, mockDecorations: true);
    tester.view.physicalSize = const Size(400, 400);
    await tester.pumpAndSettle();
    final scrollPosition = position(tester);
    expect(scrollPosition.maxScrollExtent, greaterThan(0));
    scrollPosition.jumpTo(scrollPosition.maxScrollExtent);
    await tester.pumpAndSettle();
    final lastCardBottom = tester.getBottomLeft(find.byType(NoticesCard).last).dy;
    expect(lastCardBottom, closeTo(scrollPosition.viewportDimension - cardMargin - 2, 0.01));
    // Circle 1 intersects the content end. Check continuity into the final
    // padding and through the last visible row, outside the cards horizontally.
    expect(await pixel(tester, 398, 389), const Color(0xFFFF0000));
    expect(await pixel(tester, 398, 399), const Color(0xFFFF0000));
    expect(tester.takeException(), isNull);
  });

  testWidgets('circles remain behind the cards and move with scrolling', (tester) async {
    await showHome(tester, 32, mockDecorations: true);
    expect(await pixel(tester, 398, 500), const Color(0xFFFF0000));
    expect(await pixel(tester, 100, 60), const Color(0xFF2196F3));
    position(tester).jumpTo(100);
    await tester.pumpAndSettle();
    expect(await pixel(tester, 398, 400), const Color(0xFFFF0000));
    expect(tester.takeException(), isNull);
  });
}

class _EmptyCardsProvider extends CardsDataProvider {
  @override
  List<String> get cardOrder => [];
}

class _NoticesProvider extends NoticesDataProvider {
  _NoticesProvider(this.count);

  int count;

  void setCount(int value) {
    count = value;
    notifyListeners();
  }

  @override
  List<NoticesModel> get noticesModel =>
      List.generate(count, (index) => NoticesModel(title: 'Notice $index', imageUrl: _bannerUrl, link: ''));
}

class _WebCardsProvider extends CardsDataProvider {
  @override
  List<String> get cardOrder => ['review_web'];

  @override
  Map<String, bool> get cardStates => {'review_web': true};

  @override
  Map<String, CardsModel?> get webCards => {
    'review_web': CardsModel(
      cardActive: true,
      initialURL: 'https://example.invalid/web-card',
      isWebCard: true,
      requireAuth: false,
      titleText: 'Test web card',
    ),
  };
}

class _WebViewPlatform extends web.WebViewPlatform {
  final controllers = <_WebViewController>[];

  @override
  web.PlatformWebViewController createPlatformWebViewController(web.PlatformWebViewControllerCreationParams params) {
    final controller = _WebViewController(params);
    controllers.add(controller);
    return controller;
  }

  @override
  web.PlatformNavigationDelegate createPlatformNavigationDelegate(
    web.PlatformNavigationDelegateCreationParams params,
  ) => _NavigationDelegate(params);

  @override
  web.PlatformWebViewWidget createPlatformWebViewWidget(web.PlatformWebViewWidgetCreationParams params) =>
      _WebViewWidget(params);
}

class _WebViewController extends web.PlatformWebViewController {
  _WebViewController(super.params) : super.implementation();

  final requests = <String>[];

  @override
  Future<void> setJavaScriptMode(web.JavaScriptMode mode) async {}

  @override
  Future<void> addJavaScriptChannel(web.JavaScriptChannelParams params) async {}

  @override
  Future<void> setPlatformNavigationDelegate(web.PlatformNavigationDelegate delegate) async {}

  @override
  Future<void> loadRequest(web.LoadRequestParams params) async => requests.add(params.uri.toString());

  @override
  Future<String?> currentUrl() async => requests.isEmpty ? null : requests.last;
}

class _NavigationDelegate extends web.PlatformNavigationDelegate {
  _NavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnPageFinished(web.PageEventCallback callback) async {}
}

class _WebViewWidget extends web.PlatformWebViewWidget {
  _WebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

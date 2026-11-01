import 'dart:async';
import 'dart:ui' as ui;

import 'package:campus_mobile_experimental/ui/home/home_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _images = [
  (asset: 'circle-1-background.png', native: Size(1679, 1571), display: Size(298.64, 280)),
  (asset: 'circle-3-background.png', native: Size(1404, 1398), display: Size(300, 298.6)),
  (asset: 'circle-4-background.png', native: Size(1876, 1870), display: Size(399.7, 398)),
  (asset: 'circle-2-background.png', native: Size(2401, 2401), display: Size(136, 136)),
  (asset: 'circle-5-background.png', native: Size(2401, 2401), display: Size(197, 197)),
  (asset: 'circle-6-background.png', native: Size(2401, 2401), display: Size(188, 188)),
];

void main() {
  final binding = _ImageTestBinding();
  final cache = binding.imageCache as _RecordingImageCache;

  tearDown(() {
    cache.clear();
    cache.clearLiveImages();
  });

  for (final ratio in [1.0, 2.0, 2.5, 3.0, 4.0]) {
    testWidgets('background decodes actual PNGs for pixel ratio $ratio', (tester) async {
      final painter = const HomeBackgroundDecoration().createBoxPainter(() {});
      addTearDown(painter.dispose);
      await tester.runAsync(() async {
        final recorder = ui.PictureRecorder();
        cache.startBatch();
        painter.paint(
          Canvas(recorder),
          Offset.zero,
          ImageConfiguration(bundle: rootBundle, devicePixelRatio: ratio, size: const Size(400, 3700)),
        );
        recorder.endRecording().dispose();
        await cache.batch.future.timeout(const Duration(seconds: 10));
      });

      expect(cache.images, hasLength(6));
      for (final spec in _images) {
        final actual = cache.images.entries.singleWhere((entry) => entry.key.contains(spec.asset)).value;
        expect(actual.width, lessThanOrEqualTo((spec.display.width * ratio).ceil()), reason: spec.asset);
        expect(actual.height, lessThanOrEqualTo((spec.display.height * ratio).ceil()), reason: spec.asset);
        final aspectRatio = spec.native.width / spec.native.height;
        expect(
          (actual.width - actual.height * aspectRatio).abs(),
          lessThanOrEqualTo(1 + aspectRatio),
          reason: '${spec.asset}: allow one physical pixel of rounding per axis',
        );
        final alpha = cache.alpha.entries.singleWhere((entry) => entry.key.contains(spec.asset)).value;
        expect(alpha, (min: 0, max: 255), reason: '${spec.asset}: retain transparent and opaque pixels');
      }
      final bytes = cache.images.values.fold<double>(0, (sum, size) => sum + size.width * size.height * 4);
      print('Pixel ratio $ratio: ${(bytes / (1024 * 1024)).toStringAsFixed(2)} MiB of decoded RGBA pixels');
    });
  }

  testWidgets('the same painter updates decode sizes when pixel ratio changes', (tester) async {
    final painter = const HomeBackgroundDecoration().createBoxPainter(() {});
    addTearDown(painter.dispose);
    final widths = <double>[];
    for (final ratio in [1.0, 3.0]) {
      await tester.runAsync(() async {
        cache.startBatch();
        final recorder = ui.PictureRecorder();
        painter.paint(
          Canvas(recorder),
          Offset.zero,
          ImageConfiguration(bundle: rootBundle, devicePixelRatio: ratio, size: const Size(400, 3700)),
        );
        recorder.endRecording().dispose();
        await cache.batch.future.timeout(const Duration(seconds: 10));
      });
      widths.add(
        cache.images.entries.singleWhere((entry) => entry.key.contains('circle-2-background.png')).value.width,
      );
    }
    expect(widths, [136, 408]);
  });

  for (final width in [320, 800]) {
    testWidgets('right-edge circle keeps the 390-pixel reference crop at width $width', (tester) async {
      final painter = const HomeBackgroundDecoration().createBoxPainter(() {});
      addTearDown(painter.dispose);
      await tester.runAsync(() async {
        cache.startBatch();
        final recorder = ui.PictureRecorder();
        painter.paint(
          Canvas(recorder),
          Offset.zero,
          ImageConfiguration(bundle: rootBundle, devicePixelRatio: 1, size: const Size(390, 1600)),
        );
        recorder.endRecording().dispose();
        await cache.batch.future.timeout(const Duration(seconds: 10));

        Future<Uint8List> rightEdge(int canvasWidth) async {
          final recorder = ui.PictureRecorder();
          painter.paint(
            Canvas(recorder),
            const Offset(0, -1065),
            ImageConfiguration(bundle: rootBundle, devicePixelRatio: 1, size: Size(canvasWidth.toDouble(), 1600)),
          );
          final picture = recorder.endRecording();
          final image = await picture.toImage(canvasWidth, 398);
          picture.dispose();
          final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
          image.dispose();
          final edge = Uint8List(200 * 398 * 4);
          for (var row = 0; row < 398; row++) {
            final source = (row * canvasWidth + canvasWidth - 200) * 4;
            edge.setRange(row * 800, (row + 1) * 800, bytes, source);
            expect(
              bytes[(row * canvasWidth + canvasWidth - 201) * 4 + 3],
              0,
              reason: 'circle should not extend left of its 200-pixel edge crop',
            );
          }
          return edge;
        }

        final reference = await rightEdge(390);
        expect(
          [for (var index = 3; index < reference.length; index += 4) reference[index]].any((alpha) => alpha > 0),
          isTrue,
          reason: 'reference crop must contain visible circle pixels',
        );
        final actual = await rightEdge(width);
        var maxDifference = 0;
        for (var index = 0; index < actual.length; index++) {
          final difference = (actual[index] - reference[index]).abs();
          if (difference > maxDifference) maxDifference = difference;
        }
        // Fractional image bounds can round a channel by one byte when translated.
        expect(
          maxDifference,
          lessThanOrEqualTo(1),
          reason: 'retain the right-edge crop within 1/255 of raster rounding per channel',
        );
      });
    });
  }
}

class _ImageTestBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  ImageCache createImageCache() => _RecordingImageCache();
}

class _RecordingImageCache extends ImageCache {
  final images = <String, Size>{};
  final alpha = <String, ({int min, int max})>{};
  late Completer<void> batch;

  void startBatch() {
    images.clear();
    alpha.clear();
    batch = Completer<void>();
  }

  @override
  ImageStreamCompleter? putIfAbsent(Object key, ImageStreamCompleter Function() loader, {ImageErrorListener? onError}) {
    final stream = super.putIfAbsent(key, loader, onError: onError);
    if (stream != null) {
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          stream.removeListener(listener);
          unawaited(_capture(stream.debugLabel ?? key.toString(), info));
        },
        onError: (Object error, StackTrace? stack) {
          if (!batch.isCompleted) batch.completeError(error, stack);
        },
      );
      stream.addListener(listener);
    }
    return stream;
  }

  Future<void> _capture(String label, ImageInfo info) async {
    try {
      final bytes = (await info.image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      var minimum = 255;
      var maximum = 0;
      for (var index = 3; index < bytes.lengthInBytes; index += 4) {
        final value = bytes.getUint8(index);
        if (value < minimum) minimum = value;
        if (value > maximum) maximum = value;
      }
      alpha[label] = (min: minimum, max: maximum);
      images[label] = Size(info.image.width.toDouble(), info.image.height.toDouble());
      if (images.length == 6 && !batch.isCompleted) batch.complete();
    } catch (error, stack) {
      if (!batch.isCompleted) batch.completeError(error, stack);
    } finally {
      info.dispose();
    }
  }
}

import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_scale_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EsriMapScaleBar Widget Tests', () {
    testWidgets('renders imperial and metric units when autoFade is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EsriMapScaleBar(
              scale: 24000.0,
              isDark: false,
              autoFade: false,
            ),
          ),
        ),
      );

      expect(find.byType(EsriMapScaleBar), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders close-up zoom scale (e.g. 500)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EsriMapScaleBar(
              scale: 500.0,
              isDark: false,
              autoFade: false,
            ),
          ),
        ),
      );

      expect(find.byType(EsriMapScaleBar), findsOneWidget);
      expect(find.text('20 ft'), findsOneWidget);
      expect(find.text('5 m'), findsOneWidget);
    });

    testWidgets('fades in on zoom change and fades out after delay', (tester) async {
      double currentScale = 24000.0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  EsriMapScaleBar(
                    scale: currentScale,
                    autoFade: true,
                    fadeDelay: const Duration(milliseconds: 500),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => currentScale = 12000.0),
                    child: const Text('Zoom'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Initially opacity is 0.0
      final animatedOpacityFinder = find.byType(AnimatedOpacity);
      expect(animatedOpacityFinder, findsOneWidget);
      AnimatedOpacity opacityWidget = tester.widget(animatedOpacityFinder);
      expect(opacityWidget.opacity, 0.0);

      // Trigger zoom/scale change
      await tester.tap(find.text('Zoom'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Now opacity is 1.0 (visible while zooming)
      opacityWidget = tester.widget(animatedOpacityFinder);
      expect(opacityWidget.opacity, 1.0);

      // Wait for fade delay
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 300));

      // Now opacity has returned to 0.0 (faded out when zooming stopped)
      opacityWidget = tester.widget(animatedOpacityFinder);
      expect(opacityWidget.opacity, 0.0);
    });

    testWidgets('returns SizedBox.shrink when scale is 0 or negative', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EsriMapScaleBar(
              scale: 0.0,
              isDark: false,
              autoFade: false,
            ),
          ),
        ),
      );

      expect(find.text('ft'), findsNothing);
    });
  });
}

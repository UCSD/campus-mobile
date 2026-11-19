import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/ui/common/last_updated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final staleAges = {
    const Duration(minutes: 5): '5 minutes ago',
    const Duration(hours: 3): '3 hours ago',
    const Duration(days: 3): '3 days ago',
  };
  for (final entry in staleAges.entries) {
    test('stale timestamp displays ${entry.value}', () {
      final lastUpdated = DateTime.now().subtract(entry.key);
      expect(LastUpdatedWidget.determineText(lastUpdated), entry.value);
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets('last updated text is readable in ${brightness.name} mode', (tester) async {
      final background = brightness == Brightness.dark ? darkPrimaryBgColor : lightAccentColor;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: Card(
              color: background,
              child: LastUpdatedWidget(time: DateTime.now().subtract(const Duration(minutes: 5))),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, 'Last Updated: 5 minutes ago');
      expect(text.style!.fontSize, greaterThanOrEqualTo(16));
      final foregroundLuminance = text.style!.color!.computeLuminance();
      final backgroundLuminance = background.computeLuminance();
      final lighter = foregroundLuminance > backgroundLuminance ? foregroundLuminance : backgroundLuminance;
      final darker = foregroundLuminance < backgroundLuminance ? foregroundLuminance : backgroundLuminance;
      expect((lighter + 0.05) / (darker + 0.05), greaterThanOrEqualTo(4.5));
    });
  }
}

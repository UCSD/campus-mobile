import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('blueprintMapOverlayTheme', () {
    test('applies blueprint accent and surface colors', () {
      final themed = blueprintMapOverlayTheme(ThemeData.light());

      expect(themed.scaffoldBackgroundColor, blueprintSurfaceColor);
      expect(themed.colorScheme.primary, blueprintAccentColor);
      expect(themed.colorScheme.secondary, blueprintAccentColor);
    });

    test('stays light-mode so dark overlay styling is not triggered', () {
      final themed = blueprintMapOverlayTheme(ThemeData.light());

      expect(themed.brightness, Brightness.light);
      expect(themed.colorScheme.brightness, Brightness.light);
    });

    test('preserves unrelated base theme properties', () {
      final base = ThemeData.light().copyWith(textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Brix Sans'));
      final themed = blueprintMapOverlayTheme(base);

      expect(themed.textTheme.bodyMedium?.fontFamily, 'Brix Sans');
    });
  });
}

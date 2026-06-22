import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mobile_experimental/core/models/notices.dart';
import 'package:campus_mobile_experimental/ui/notices/notices_card.dart';
import 'package:flutter/material.dart';

Finder findBannerSemantics() =>
    find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.image == true);

void main() {
  group('NoticesCard Tests', () {
    testWidgets('spells out TWOW as separate letters in the accessibility label', (WidgetTester tester) async {
      final semanticsHandle = tester.ensureSemantics();
      addTearDown(semanticsHandle.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NoticesCard(notice: NoticesModel(title: 'UC San Diego TWOW', imageUrl: '', link: ''))),
        ),
      );

      final semantics = tester.getSemantics(findBannerSemantics());
      expect(semantics.label, 'UC San Diego T W O W');
    });

    testWidgets('leaves titles without TWOW unchanged', (WidgetTester tester) async {
      final semanticsHandle = tester.ensureSemantics();
      addTearDown(semanticsHandle.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoticesCard(notice: NoticesModel(title: 'Welcome Week Schedule', imageUrl: '', link: '')),
          ),
        ),
      );

      final semantics = tester.getSemantics(findBannerSemantics());
      expect(semantics.label, 'Welcome Week Schedule');
    });

    testWidgets('does not alter words that merely contain twow as a substring', (WidgetTester tester) async {
      final semanticsHandle = tester.ensureSemantics();
      addTearDown(semanticsHandle.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NoticesCard(notice: NoticesModel(title: 'TWOWeek Kickoff', imageUrl: '', link: ''))),
        ),
      );

      final semantics = tester.getSemantics(findBannerSemantics());
      expect(semantics.label, 'TWOWeek Kickoff');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mobile_experimental/ui/common/base64_image_widget.dart';
import 'package:flutter/material.dart';

void main() {
  group('Base64ImageWidget Tests', () {
    testWidgets('should show placeholder when base64String is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Base64ImageWidget(
              base64String: null,
              placeholderAssetPath: 'assets/images/staff_id_placeholder.png',
            ),
          ),
        ),
      );

      // Should find the placeholder image
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should show placeholder when base64String is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Base64ImageWidget(
              base64String: '',
              placeholderAssetPath: 'assets/images/staff_id_placeholder.png',
            ),
          ),
        ),
      );

      // Should find the placeholder image
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should show placeholder when base64String is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Base64ImageWidget(
              base64String: 'invalid_base64_string',
              placeholderAssetPath: 'assets/images/staff_id_placeholder.png',
            ),
          ),
        ),
      );

      await tester.pump();

      // Should find the placeholder image
      expect(find.byType(Image), findsOneWidget);
    });
  });
}

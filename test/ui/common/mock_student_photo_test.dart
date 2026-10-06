import 'dart:convert';
import 'dart:io';

import 'package:campus_mobile_experimental/ui/common/base64_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// MA-759: mock base64 encoded student photo for testing
void main() {
  final mockBase64 = File('test/mock_student_photo_base64.txt').readAsStringSync();

  group('Mock student photo (MA-759)', () {
    test('mock fixture decodes to a valid PNG', () {
      final bytes = base64Decode(mockBase64);
      // PNG magic number
      expect(bytes.sublist(0, 8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    });

    testWidgets('renders decoded base64 image instead of placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Base64ImageWidget(
              base64String: mockBase64,
              placeholderAssetPath: 'assets/images/staff_id_placeholder.png',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Image.memory produces an Image widget with a MemoryImage provider
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.image, isA<MemoryImage>());
    });

    testWidgets('falls back to placeholder on empty photo string', (WidgetTester tester) async {
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

      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.image, isA<AssetImage>());
    });
  });
}

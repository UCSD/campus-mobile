import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:campus_mobile_experimental/core/services/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final saved = <String, Object?>{};
  final updated = <String>[];

  setUp(() {
    saved.clear();
    updated.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (call) async {
        final args = call.arguments as Map;
        if (call.method == 'saveWidgetData') saved[args['id']] = args['data'];
        if (call.method == 'updateWidget') updated.add(args['name']);
        return true;
      },
    );
  });

  test('syncClasses writes one line per class for every weekday', () async {
    await HomeWidgetService.syncClasses({
      'MO': [
        _class('CSE', '141L', time: '10:00-10:50', building: 'CENTR', room: '115'),
        _class('MATH', '20C', time: null),
      ],
    });

    expect(saved['classes_MO'], 'CSE 141L  10:00  CENTR 115\nMATH 20C  TBA');
    expect(saved['classes_TU'], '');
    expect(saved.keys.where((key) => key.startsWith('classes_')), hasLength(7));
    expect(updated, ['ClassesWidget']);
  });

  testWidgets('barcode image fits the widget PNG without overflowing', (tester) async {
    // Same wrapping as HomeWidget.renderFlutterWidget: a Column inside a box of exactly logicalSize.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox.fromSize(
            size: HomeWidgetService.barcodeSize,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [HomeWidgetService.barcodeImage('1234567890')],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  test('clear removes every key so the widgets show signed out', () async {
    await HomeWidgetService.clear();

    expect(saved, hasLength(9));
    expect(saved.values, everyElement(isNull));
    expect(updated, ['StudentIdWidget', 'ClassesWidget']);
  });
}

ScheduledClass _class(String subject, String course, {String? time, String? building, String? room}) => ScheduledClass(
  course: ClassData(subjectCode: subject, courseCode: course),
  section: SectionData(time: time, building: building, room: room),
);

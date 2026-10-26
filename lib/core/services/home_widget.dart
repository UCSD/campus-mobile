import 'package:barcode_widget/barcode_widget.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// Pushes Student ID and Classes data to the native home screen widgets
/// (ios/CampusWidgets, android/app/src/main/kotlin/edu/ucsd/HomeWidgets.kt).
class HomeWidgetService {
  static const appGroupId = 'group.edu.ucsd.ucsandiego';
  static const _days = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  static const barcodeSize = Size(300, 80);

  static Future<void> syncStudentId(String name, String barcode) async {
    await HomeWidget.saveWidgetData<String>('student_name', name);
    if (barcode.isEmpty) {
      await HomeWidget.saveWidgetData<String>('student_barcode', null);
    } else {
      // ponytail: neither iOS nor Android draws Codabar natively, so reuse barcode_widget as a PNG
      await HomeWidget.renderFlutterWidget(barcodeImage(barcode), key: 'student_barcode', logicalSize: barcodeSize);
    }
    await HomeWidget.updateWidget(name: 'StudentIdWidget');
  }

  /// Sized explicitly: renderFlutterWidget wraps this in a Column, where BarcodeWidget
  /// would default to width / 2 (150px) tall and overflow the 80px image.
  static Widget barcodeImage(String barcode) => BarcodeWidget(
    barcode: Barcode.codabar(),
    data: barcode,
    width: barcodeSize.width,
    height: barcodeSize.height,
    drawText: false,
    backgroundColor: Colors.white,
  );

  /// One list per weekday so the widget picks "today" itself after midnight.
  static Future<void> syncClasses(Map<String, List<ScheduledClass>> classesByDay) async {
    for (final day in _days) {
      final lines = (classesByDay[day] ?? []).map((c) => classLine(c));
      await HomeWidget.saveWidgetData<String>('classes_$day', lines.join('\n'));
    }
    await HomeWidget.updateWidget(name: 'ClassesWidget');
  }

  /// i.e. "CSE 141L  10:00  CENTR 115"
  static String classLine(ScheduledClass c) {
    final time = c.section.time?.trim() ?? '';
    final start = time.isEmpty ? 'TBA' : time.split('-').first;
    return '${c.subjectCode} ${c.courseCode}  $start  ${c.section.building ?? ''} ${c.section.room ?? ''}'.trim();
  }

  /// Logout: the widgets must never keep showing the previous user's ID.
  static Future<void> clear() async {
    for (final key in ['student_name', 'student_barcode', for (final day in _days) 'classes_$day']) {
      await HomeWidget.saveWidgetData<String>(key, null);
    }
    await HomeWidget.updateWidget(name: 'StudentIdWidget');
    await HomeWidget.updateWidget(name: 'ClassesWidget');
  }
}

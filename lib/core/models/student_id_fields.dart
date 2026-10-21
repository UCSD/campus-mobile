import 'dart:convert';

Map<String, dynamic> studentIdObjectFromJson(String source) {
  final value = json.decode(source);
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Expected a Student ID JSON object');
  }
  return value;
}

String studentIdText(dynamic value) => value is String ? value.trim() : '';

String retainStudentIdText(String replacement, String retained) => replacement.isNotEmpty ? replacement : retained;

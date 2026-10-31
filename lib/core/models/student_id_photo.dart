import 'dart:convert';
import 'package:campus_mobile_experimental/core/models/student_id_fields.dart';

// To parse this JSON data, do
//
//     final studentIdPhotoModel = studentIdPhotoModelFromJson(jsonString);
StudentIdPhotoModel studentIdPhotoModelFromJson(String str) =>
    StudentIdPhotoModel.fromJson(studentIdObjectFromJson(str));

String studentIdPhotoModelToJson(StudentIdPhotoModel data) => json.encode(data.toJson());

class StudentIdPhotoModel {
  String studentId;
  String photoUrl;

  StudentIdPhotoModel({this.studentId = '', this.photoUrl = ''});

  factory StudentIdPhotoModel.fromJson(Map<String, dynamic> json) =>
      StudentIdPhotoModel(studentId: studentIdText(json["studentId"]), photoUrl: _validatedUrl(json["photoUrl"]));

  static String _validatedUrl(dynamic value) {
    final text = studentIdText(value);
    final uri = Uri.tryParse(text);
    return uri != null &&
            (uri.scheme == 'https' || uri.scheme == 'http') &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty &&
            !RegExp(r'\s').hasMatch(text)
        ? text
        : '';
  }

  Map<String, dynamic> toJson() => {"studentId": studentId, "photoUrl": photoUrl};
}

// To parse this JSON data, do
//
//     final studentIdPhotoModel = studentIdPhotoModelFromJson(jsonString);

import 'dart:convert';

StudentIdPhotoModel studentIdPhotoModelFromJson(String str) =>
    StudentIdPhotoModel.fromJson(json.decode(str));

String studentIdPhotoModelToJson(StudentIdPhotoModel data) =>
    json.encode(data.toJson());

class StudentIdPhotoModel {
  String studentId;
  String photoUrl;

  StudentIdPhotoModel({
    required this.studentId,
    required this.photoUrl
  });

  factory StudentIdPhotoModel.fromJson(Map<String, dynamic> json) =>
      StudentIdPhotoModel(
        studentId: json["studentId"],
        photoUrl: json["photoUrl"]
      );

  Map<String, dynamic> toJson() => {
        "studentId": studentId,
        "photoUrl": photoUrl
      };

  factory StudentIdPhotoModel.empty() => StudentIdPhotoModel(
    studentId: '',
    photoUrl: ''
  );
}

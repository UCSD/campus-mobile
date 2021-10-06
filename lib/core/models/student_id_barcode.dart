// To parse this JSON data, do
//
//     final studentIdBarcodeModel = studentIdBarcodeModelFromJson(jsonString);

import 'dart:convert';

StudentIdBarcodeModel studentIdBarcodeModelFromJson(String str) =>
    StudentIdBarcodeModel.fromJson(json.decode(str));

String studentIdBarcodeModelToJson(StudentIdBarcodeModel data) =>
    json.encode(data.toJson());

class StudentIdBarcodeModel {
  String? studentId;
  int? barCode;

  StudentIdBarcodeModel({
    this.studentId,
    this.barCode,
  });

  factory StudentIdBarcodeModel.fromJson(Map<String, dynamic> json) =>
      StudentIdBarcodeModel(
        studentId: json["studentId"],
        barCode: json["barCode"] == null ? 0 : json["barCode"],
      );

  Map<String, dynamic> toJson() => {
        "studentId": studentId,
        "barCode": barCode == null ? 0 : barCode,
      };
}

// To parse this JSON data, do
//
//     final academicTermModel = academicTermModelFromJson(jsonString);

import 'dart:convert';

AcademicTermModel academicTermModelFromJson(String str) =>
    AcademicTermModel.fromJson(json.decode(str));

String academicTermModelToJson(AcademicTermModel data) =>
    json.encode(data.toJson());

class AcademicTermModel {
  String termName;
  String termCode;

  AcademicTermModel({
    this.termName,
    this.termCode,
  });

  factory AcademicTermModel.fromJson(Map<String, dynamic> json) =>
      AcademicTermModel(
        termName: json["term_name"],
        termCode: json["term_code"],
      );

  Map<String, dynamic> toJson() => {
        "term_name": termName,
        "term_code": termCode,
      };
}

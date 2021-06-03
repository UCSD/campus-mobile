// To parse this JSON data, do
//
//     final studentIdNameModel = studentIdNameModelFromJson(jsonString);

import 'dart:convert';

StudentIdNameModel studentIdNameModelFromJson(String str) =>
    StudentIdNameModel.fromJson(json.decode(str));

String studentIdNameModelToJson(StudentIdNameModel data) =>
    json.encode(data.toJson());

class StudentIdNameModel {
  String? studentId;
  String? firstName;
  String? middleName;
  String? lastName;
  String? lastUpdatedBy;
  int? internalId;
  dynamic lastUpdatedDate;

  StudentIdNameModel({
    this.studentId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.lastUpdatedBy,
    this.internalId,
    this.lastUpdatedDate,
  });

  factory StudentIdNameModel.fromJson(Map<String, dynamic> json) =>
      StudentIdNameModel(
        studentId: json["studentId"],
        firstName: json["firstName"],
        middleName: json["middleName"],
        lastName: json["lastName"],
        lastUpdatedBy: json["lastUpdatedBy"],
        internalId: json["internalId"],
        lastUpdatedDate: json["lastUpdatedDate"],
      );

  Map<String, dynamic> toJson() => {
        "studentId": studentId,
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
        "lastUpdatedBy": lastUpdatedBy,
        "internalId": internalId,
        "lastUpdatedDate": lastUpdatedDate,
      };
}

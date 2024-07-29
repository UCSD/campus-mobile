// To parse this JSON data, do
//
//     final studentIdNameModel = studentIdNameModelFromJson(jsonString);

import 'dart:convert';

StudentIdNameModel studentIdNameModelFromJson(String str) =>
    StudentIdNameModel.fromJson(json.decode(str));

String studentIdNameModelToJson(StudentIdNameModel data) =>
    json.encode(data.toJson());

class StudentIdNameModel {
  String studentId;
  String firstName;
  String middleName;
  String lastName;
  String lastUpdatedBy;
  int internalId;
  dynamic lastUpdatedDate;

  StudentIdNameModel({
    required this.studentId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.lastUpdatedBy,
    required this.internalId,
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

  factory StudentIdNameModel.empty() => StudentIdNameModel(
    studentId: '',
    firstName: '',
    middleName: '',
    lastName: '',
    lastUpdatedBy: '',
    internalId: 0,
    lastUpdatedDate: 0
  );
}

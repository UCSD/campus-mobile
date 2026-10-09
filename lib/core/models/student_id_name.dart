import 'dart:convert';
import 'package:campus_mobile_experimental/core/models/student_id_fields.dart';

// To parse this JSON data, do
//
//     final studentIdNameModel = studentIdNameModelFromJson(jsonString);
StudentIdNameModel studentIdNameModelFromJson(String str) => StudentIdNameModel.fromJson(studentIdObjectFromJson(str));

String studentIdNameModelToJson(StudentIdNameModel data) => json.encode(data.toJson());

class StudentIdNameModel {
  String studentId;
  String firstName;
  String middleName;
  String lastName;
  String lastUpdatedBy;
  int internalId;
  dynamic lastUpdatedDate;

  StudentIdNameModel({
    this.studentId = '',
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.lastUpdatedBy = '',
    this.internalId = 0,
    this.lastUpdatedDate = '',
  });

  factory StudentIdNameModel.fromJson(Map<String, dynamic> json) => StudentIdNameModel(
    studentId: studentIdText(json["studentId"]),
    firstName: studentIdText(json["firstName"]),
    middleName: studentIdText(json["middleName"]),
    lastName: studentIdText(json["lastName"]),
    lastUpdatedBy: studentIdText(json["lastUpdatedBy"]),
    internalId: json["internalId"] is int ? json["internalId"] : 0,
    lastUpdatedDate: json["lastUpdatedDate"],
  );

  String get displayName => [firstName, lastName].where((part) => part.isNotEmpty).join(' ');

  StudentIdNameModel mergeValid(StudentIdNameModel replacement) => StudentIdNameModel(
    firstName: retainStudentIdText(replacement.firstName, firstName),
    lastName: retainStudentIdText(replacement.lastName, lastName),
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

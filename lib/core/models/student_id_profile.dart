import 'dart:convert';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:campus_mobile_experimental/core/models/student_id_fields.dart';

// To parse this JSON data, do
//
//     final studentIdProfileModel = studentIdProfileModelFromJson(jsonString);
StudentIdProfileModel studentIdProfileModelFromJson(String str) =>
    StudentIdProfileModel.fromJson(studentIdObjectFromJson(str));

String studentIdProfileModelToJson(StudentIdProfileModel data) => json.encode(data.toJson());

class StudentIdProfileModel {
  String studentPid;
  String termYear;
  String studentLevelCurrent;
  String collegeCurrent;
  String ugPrimaryMajorCurrent;
  String graduatePrimaryMajorCurrent;
  int athleteCurrentCount;
  String cardNumber;
  String barcode;
  String classificationType;
  int issueNumber;

  StudentIdProfileModel({
    this.studentPid = '',
    this.termYear = '',
    this.studentLevelCurrent = '',
    this.collegeCurrent = '',
    this.ugPrimaryMajorCurrent = '',
    this.graduatePrimaryMajorCurrent = '',
    this.athleteCurrentCount = 0,
    this.cardNumber = '',
    this.barcode = '',
    this.classificationType = '',
    this.issueNumber = 0,
  });

  factory StudentIdProfileModel.fromJson(Map<String, dynamic> json) => StudentIdProfileModel(
    studentPid: studentIdText(json["Student_PID"]),
    termYear: studentIdText(json["Term_Year"]),
    studentLevelCurrent: studentIdText(json["Student_Level_Current"]),
    collegeCurrent: studentIdText(json["College_Current"]),
    ugPrimaryMajorCurrent: studentIdText(json["UG_Primary_Major_Current"]),
    graduatePrimaryMajorCurrent: studentIdText(json["Graduate_Primary_Major_Current"]),
    athleteCurrentCount: json["Athlete_Current_Count"] is int ? json["Athlete_Current_Count"] : 0,
    cardNumber: studentIdText(json["Card_Number"]),
    barcode: _validatedBarcode(json["Barcode"]),
    classificationType: studentIdText(json["Classification_Type"]),
    issueNumber: json["Issue_Number"] is int ? json["Issue_Number"] : 0,
  );

  static String _validatedBarcode(dynamic value) =>
      value is String && value.isNotEmpty && Barcode.codabar().isValid(value) ? value : '';

  String get major => graduatePrimaryMajorCurrent.isNotEmpty ? graduatePrimaryMajorCurrent : ugPrimaryMajorCurrent;

  StudentIdProfileModel mergeValid(StudentIdProfileModel replacement) => StudentIdProfileModel(
    classificationType: retainStudentIdText(replacement.classificationType, classificationType),
    collegeCurrent: retainStudentIdText(replacement.collegeCurrent, collegeCurrent),
    ugPrimaryMajorCurrent: retainStudentIdText(replacement.ugPrimaryMajorCurrent, ugPrimaryMajorCurrent),
    graduatePrimaryMajorCurrent: retainStudentIdText(
      replacement.graduatePrimaryMajorCurrent,
      graduatePrimaryMajorCurrent,
    ),
    barcode: retainStudentIdText(replacement.barcode, barcode),
  );

  Map<String, dynamic> toJson() => {
    "Student_PID": studentPid,
    "Term_Year": termYear,
    "Student_Level_Current": studentLevelCurrent,
    "College_Current": collegeCurrent,
    "UG_Primary_Major_Current": ugPrimaryMajorCurrent,
    "Graduate_Primary_Major_Current": graduatePrimaryMajorCurrent,
    "Athlete_Current_Count": athleteCurrentCount,
    "Card_Number": cardNumber,
    "Barcode": barcode,
    "Classification_Type": classificationType,
    "Issue_Number": issueNumber,
  };
}

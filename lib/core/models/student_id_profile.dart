// To parse this JSON data, do
//
//     final studentIdProfileModel = studentIdProfileModelFromJson(jsonString);

import 'dart:convert';

StudentIdProfileModel studentIdProfileModelFromJson(String str) =>
    StudentIdProfileModel.fromJson(json.decode(str));

String studentIdProfileModelToJson(StudentIdProfileModel data) =>
    json.encode(data.toJson());

class StudentIdProfileModel {
  String? studentPid;
  String? termYear;
  String? studentLevelCurrent;
  String? collegeCurrent;
  String? ugPrimaryMajorCurrent;
  dynamic graduatePrimaryMajorCurrent;
  int? athleteCurrentCount;
  String? cardNumber;
  String? barcode;
  String? classificationType;
  int? issueNumber;

  StudentIdProfileModel({
    this.studentPid,
    this.termYear,
    this.studentLevelCurrent,
    this.collegeCurrent,
    this.ugPrimaryMajorCurrent,
    this.graduatePrimaryMajorCurrent,
    this.athleteCurrentCount,
    this.cardNumber,
    this.barcode,
    this.classificationType,
    this.issueNumber,
  });

  factory StudentIdProfileModel.fromJson(Map<String, dynamic> json) =>
      StudentIdProfileModel(
        studentPid: json["Student_PID"],
        termYear: json["Term_Year"],
        studentLevelCurrent: json["Student_Level_Current"],
        collegeCurrent:
            json["College_Current"] == null
                ? ""
                : json["College_Current"],
        ugPrimaryMajorCurrent: json["UG_Primary_Major_Current"] == null
            ? ""
            : json["UG_Primary_Major_Current"],
        graduatePrimaryMajorCurrent:
            json["Graduate_Primary_Major_Current"] == null
                ? ""
                : json["Graduate_Primary_Major_Current"],
        athleteCurrentCount: json["Athlete_Current_Count"],
        cardNumber: json["ID_Card_Number"],
        barcode: json["ID_Card_Bar_Code"],
        classificationType: json["ID_Card_Classification_Type"],
        issueNumber: json["ID_Card_Issue_Number"],
      );

  Map<String, dynamic> toJson() => {
        "Student_PID": studentPid,
        "Term_Year": termYear,
        "Student_Level_Current": studentLevelCurrent,
        "College_Current": collegeCurrent == null ? "" : collegeCurrent,
        "UG_Primary_Major_Current":
            ugPrimaryMajorCurrent == null ? "" : ugPrimaryMajorCurrent,
        "Graduate_Primary_Major_Current": graduatePrimaryMajorCurrent == null
            ? ""
            : graduatePrimaryMajorCurrent,
        "Athlete_Current_Count": athleteCurrentCount,
        "ID_Card_Number": cardNumber,
        "ID_Card_Bar_Code": barcode,
        "ID_Card_Classification_Type": classificationType,
        "ID_Card_Issue_Number": issueNumber,
      };
}

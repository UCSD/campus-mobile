// To parse this JSON data, do
//
//     final classScheduleModel = classScheduleModelFromJson(jsonString);

import 'dart:convert';

ClassScheduleModel classScheduleModelFromJson(String str) =>
    ClassScheduleModel.fromJson(json.decode(str));

String classScheduleModelToJson(ClassScheduleModel data) =>
    json.encode(data.toJson());

class ClassScheduleModel {
  Metadata metadata;
  List<Data> data;

  ClassScheduleModel({
    this.metadata,
    this.data,
  });

  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) =>
      ClassScheduleModel(
        metadata: Metadata.fromJson(json["metadata"]),
        data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "metadata": metadata.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Data {
  String termCode;
  String subjectCode;
  String courseCode;
  int units;
  String courseLevel;
  String gradeOption;
  String grade;
  String courseTitle;
  String enrollmentStatus;
  String repeatCode;
  List<SectionData> sectionData;

  Data({
    this.termCode,
    this.subjectCode,
    this.courseCode,
    this.units,
    this.courseLevel,
    this.gradeOption,
    this.grade,
    this.courseTitle,
    this.enrollmentStatus,
    this.repeatCode,
    this.sectionData,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        termCode: json["term_code"],
        subjectCode: json["subject_code"],
        courseCode: json["course_code"],
        units: json["units"],
        courseLevel: json["course_level"],
        gradeOption: json["grade_option"],
        grade: json["grade"],
        courseTitle: json["course_title"],
        enrollmentStatus: json["enrollment_status"],
        repeatCode: json["repeat_code"],
        sectionData: List<SectionData>.from(
            json["section_data"].map((x) => SectionData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "term_code": termCode,
        "subject_code": subjectCode,
        "course_code": courseCode,
        "units": units,
        "course_level": courseLevel,
        "grade_option": gradeOption,
        "grade": grade,
        "course_title": courseTitle,
        "enrollment_status": enrollmentStatus,
        "repeat_code": repeatCode,
        "section_data": List<dynamic>.from(sectionData.map((x) => x.toJson())),
      };
}

class SectionData {
  String section;
  String meetingType;
  String time;
  String days;
  String building;
  String room;
  String instructorName;
  String specialMtgCode;

  SectionData({
    this.section,
    this.meetingType,
    this.time,
    this.days,
    this.building,
    this.room,
    this.instructorName,
    this.specialMtgCode,
  });

  factory SectionData.fromJson(Map<String, dynamic> json) => SectionData(
        section: json["section"],
        meetingType: json["meeting_type"],
        time: json["time"],
        days: json["days"],
        building: json["building"],
        room: json["room"],
        instructorName: json["instructor_name"],
        specialMtgCode: json["special_mtg_code"],
      );

  Map<String, dynamic> toJson() => {
        "section": section,
        "meeting_type": meetingType,
        "time": time,
        "days": days,
        "building": building,
        "room": room,
        "instructor_name": instructorName,
        "special_mtg_code": specialMtgCode,
      };
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata();

  Map<String, dynamic> toJson() => {};
}

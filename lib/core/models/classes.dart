// To parse this JSON data, do
//
//     final classScheduleModel = classScheduleModelFromJson(jsonString);

import 'dart:convert';

ClassScheduleModel classScheduleModelFromJson(String str) =>
    ClassScheduleModel.fromJson(json.decode(str));

String classScheduleModelToJson(ClassScheduleModel data) =>
    json.encode(data.toJson());

class ClassScheduleModel {
  Metadata? metadata;
  List<ClassData>? data;

  ClassScheduleModel({
    this.metadata,
    this.data,
  });
  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) =>
      ClassScheduleModel(
        metadata: json["metadata"] == null
            ? null
            : Metadata.fromJson(json["metadata"]),
        data: json["data"] == null
            ? null
            : List<ClassData>.from(
                json["data"].map((x) => ClassData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "metadata": metadata == null ? null : metadata!.toJson(),
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ClassData {
  String? termCode;
  String? subjectCode;
  String? courseCode;
  double? units;
  String? courseLevel;
  String? gradeOption;
  String? grade;
  String? courseTitle;
  String? enrollmentStatus;
  String? repeatCode;
  List<SectionData>? sectionData;

  ClassData({
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

  factory ClassData.fromJson(Map<String, dynamic> json) => ClassData(
        termCode: json["term_code"] == null ? null : json["term_code"],
        subjectCode: json["subject_code"] == null ? null : json["subject_code"],
        courseCode: json["course_code"] == null ? null : json["course_code"],
        units: json["units"] == null ? null : json["units"],
        courseLevel: json["course_level"] == null ? null : json["course_level"],
        gradeOption: json["grade_option"] == null ? null : json["grade_option"],
        grade: json["grade"] == null ? null : json["grade"],
        courseTitle: json["course_title"] == null ? null : json["course_title"],
        enrollmentStatus: json["enrollment_status"] == null
            ? null
            : json["enrollment_status"],
        repeatCode: json["repeat_code"] == null ? null : json["repeat_code"],
        sectionData: json["section_data"] == null
            ? null
            : List<SectionData>.from(
                json["section_data"].map((x) => SectionData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "term_code": termCode == null ? null : termCode,
        "subject_code": subjectCode == null ? null : subjectCode,
        "course_code": courseCode == null ? null : courseCode,
        "units": units == null ? null : units,
        "course_level": courseLevel == null ? null : courseLevel,
        "grade_option": gradeOption == null ? null : gradeOption,
        "grade": grade == null ? null : grade,
        "course_title": courseTitle == null ? null : courseTitle,
        "enrollment_status": enrollmentStatus == null ? null : enrollmentStatus,
        "repeat_code": repeatCode == null ? null : repeatCode,
        "section_data": sectionData == null
            ? null
            : List<dynamic>.from(sectionData!.map((x) => x.toJson())),
      };
}

class SectionData {
  String? section;
  String? meetingType;
  String? time;
  String? days;
  String? date;
  String? building;
  String? room;
  String? instructorName;
  String? specialMtgCode;
  String? subjectCode;
  String? courseCode;
  String? courseTitle;
  late String gradeOption;
  String? enrollStatus;

  SectionData({
    this.section,
    this.meetingType,
    this.time,
    this.days,
    this.date,
    this.building,
    this.room,
    this.instructorName,
    this.specialMtgCode,
    this.enrollStatus,
  });

  factory SectionData.fromJson(Map<String, dynamic> json) => SectionData(
        section: json["section"] == null ? null : json["section"],
        meetingType: json["meeting_type"] == null ? null : json["meeting_type"],
        time: json["time"] == null ? null : json["time"],
        days: json["days"] == null ? null : json["days"],
        date: json["date"] == null ? null : json["date"],
        building: json["building"] == null ? null : json["building"],
        room: json["room"] == null ? null : json["room"],
        instructorName:
            json["instructor_name"] == null ? null : json["instructor_name"],
        specialMtgCode:
            json["special_mtg_code"] == null ? null : json["special_mtg_code"],
        enrollStatus:
            json["enrollStatus"] == null ? null : json["enrollStatus"],
      );

  Map<String, dynamic> toJson() => {
        "section": section == null ? null : section,
        "meeting_type": meetingType == null ? null : meetingType,
        "time": time == null ? null : time,
        "days": days == null ? null : days,
        "date": date == null ? null : date,
        "building": building == null ? null : building,
        "room": room == null ? null : room,
        "instructor_name": instructorName == null ? null : instructorName,
        "special_mtg_code": specialMtgCode == null ? null : specialMtgCode,
        "enrollStatus": enrollStatus == null ? null : enrollStatus,
      };
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic>? json) => Metadata();

  Map<String, dynamic> toJson() => {};
}

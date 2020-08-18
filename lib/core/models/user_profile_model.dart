// To parse this JSON data, do
//
//     final userProfileModel = userProfileModelFromJson(jsonString);

import 'dart:convert';

import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

UserProfileModel userProfileModelFromJson(String str) =>
    UserProfileModel.fromJson(json.decode(str));

String userProfileModelToJson(UserProfileModel data) =>
    json.encode(data.toJson());

@HiveType(typeId: 2)
class UserProfileModel extends HiveObject {
  Classifications classifications;
  int latestTimeStamp;
  String pid;
  @HiveField(0)
  List<String> selectedLots;
  @HiveField(1)
  List<String> selectedOccuspaceLocations;
  @HiveField(2)
  List<String> subscribedTopics;
  String ucsdaffiliation;
  String username;
  Map<String,bool> selectedParkingSpots;

  UserProfileModel({
    this.classifications,
    this.latestTimeStamp,
    this.pid,
    this.selectedLots,
    this.selectedOccuspaceLocations,
    this.subscribedTopics,
    this.ucsdaffiliation,
    this.username,
    this.selectedParkingSpots
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        classifications: json["classifications"] == null
            ? null
            : Classifications.fromJson(json["classifications"]),
        latestTimeStamp:
            json["latestTimeStamp"] == null ? null : json["latestTimeStamp"],
        pid: json["pid"] == null ? null : json["pid"],
        selectedLots: json["selectedLots"] == null
            ? List<String>()
            : List<String>.from(json["selectedLots"].map((x) => x)),
        selectedOccuspaceLocations: json["selectedOccuspaceLocations"] == null
            ? List<String>()
            : List<String>.from(
                json["selectedOccuspaceLocations"].map((x) => x)),
        subscribedTopics: json["subscribedTopics"] == null
            ? List<String>()
            : List<String>.from(json["subscribedTopics"].map((x) => x)),
        ucsdaffiliation:
            json["ucsdaffiliation"] == null ? null : json["ucsdaffiliation"],
        username: json["username"] == null ? null : json["username"],
        selectedParkingSpots: json["selectedparkingspots"] == null ? null : json["selectedparkingspots"],
      );

  Map<String, dynamic> toJson() => {
        "classifications":
            classifications == null ? null : classifications.toJson(),
        "latestTimeStamp": latestTimeStamp == null ? null : latestTimeStamp,
        "pid": pid == null ? null : pid,
        "selectedLots": selectedLots == null
            ? null
            : List<dynamic>.from(selectedLots.map((x) => x)),
        "selectedOccuspaceLocations": selectedOccuspaceLocations == null
            ? null
            : List<dynamic>.from(selectedOccuspaceLocations.map((x) => x)),
        "subscribedTopics": subscribedTopics == null
            ? null
            : List<dynamic>.from(subscribedTopics.map((x) => x)),
        "ucsdaffiliation": ucsdaffiliation == null ? null : ucsdaffiliation,
        "username": username == null ? null : username,
        "selectedparkingspots" : selectedParkingSpots == null ? null : selectedParkingSpots,
      };
}

class Classifications {
  bool student;
  bool staff;

  Classifications({
    this.student,
    this.staff,
  });

  factory Classifications.fromJson(Map<String, dynamic> json) =>
      Classifications(
        student: json["student"] == null ? null : json["student"],
        staff: json["staff"] == null ? null : json["staff"],
      );

  Map<String, dynamic> toJson() => {
        "student": student == null ? null : student,
        "staff": staff == null ? null : staff,
      };
}

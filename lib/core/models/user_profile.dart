// To parse this JSON data, do
//
//     final userProfileModel = userProfileModelFromJson(jsonString);

import 'dart:convert';

import 'package:hive/hive.dart';

part 'user_profile.g.dart';

UserProfileModel userProfileModelFromJson(String str) =>
    UserProfileModel.fromJson(json.decode(str));

String userProfileModelToJson(UserProfileModel data) =>
    json.encode(data.toJson());

@HiveType(typeId: 2)
class UserProfileModel extends HiveObject {
  Classifications? classifications;
  int? latestTimeStamp;
  String? pid;
  String? ucsdaffiliation;
  String? username;

  @HiveField(0)
  List<String>? selectedLots;
  @HiveField(1)
  List<String?>? selectedOccuspaceLocations;
  @HiveField(2)
  List<String?>? subscribedTopics;
  @HiveField(3)
  Map<String?, bool>? selectedParkingSpots;
  @HiveField(4)
  Map<String?, bool>? selectedParkingLots;
  @HiveField(5)
  List<int?>? selectedStops;
  @HiveField(6)
  List<String>? surveyCompletion;
  @HiveField(7)
  List<String?>? selectedVentilationLocations;
  @HiveField(8)
  List<String?>? cardsOrder;

  UserProfileModel(
      {this.classifications,
      this.latestTimeStamp,
      this.pid,
      this.selectedLots,
      this.selectedOccuspaceLocations,
      this.subscribedTopics,
      this.ucsdaffiliation,
      this.username,
      this.selectedParkingSpots,
      this.selectedParkingLots,
      this.selectedStops,
      this.surveyCompletion,
      this.selectedVentilationLocations,
      this.cardsOrder});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        classifications: json["classifications"] == null
            ? null
            : Classifications.fromJson(json["classifications"]),
        latestTimeStamp:
            json["latestTimeStamp"] == null ? null : json["latestTimeStamp"],
        pid: json["pid"] == null ? null : json["pid"],
        selectedLots: json["selectedLots"] == null
            ? []
            : List<String>.from(json["selectedLots"].map((x) => x)),
        selectedOccuspaceLocations: json["selectedOccuspaceLocations"] == null
            ? []
            : List<String>.from(
                json["selectedOccuspaceLocations"].map((x) => x)),
        subscribedTopics: json["subscribedTopics"] == null
            ? []
            : List<String>.from(json["subscribedTopics"].map((x) => x)),
        ucsdaffiliation:
            json["ucsdaffiliation"] == null ? null : json["ucsdaffiliation"],
        username: json["username"] == null ? null : json["username"],
        selectedParkingLots: json["selectedParkingLots"] == null
            ? Map<String, bool>()
            : Map<String, bool>.from(json["selectedParkingLots"]
                .map((x, y) => MapEntry<String, bool>(x, y))),
        selectedParkingSpots: json["selectedParkingSpots"] == null
            ? Map<String, bool>()
            : Map<String, bool>.from(json["selectedParkingSpots"]
                .map((x, y) => MapEntry<String, bool>(x, y))),
        selectedStops: json["selectedStops"] == null
            ? []
            : List<int>.from(json["selectedStops"].map((x) => x)),
        surveyCompletion: json["surveyCompletion"] == null
            ? []
            : List<String>.from(json["surveyCompletion"].map((x) => x)),
        selectedVentilationLocations:
            json['selectedVentilationLocations'] == null
                ? []
                : List<String>.from(
                    json["selectedVentilationLocations"].map((x) => x)),
        cardsOrder: json['cardsOrder'] == null
            ? []
            : List<String>.from(json["cardsOrder"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "classifications":
            classifications == null ? null : classifications!.toJson(),
        "latestTimeStamp": latestTimeStamp == null ? null : latestTimeStamp,
        "pid": pid == null ? null : pid,
        "selectedLots": selectedLots == null
            ? null
            : List<dynamic>.from(selectedLots!.map((x) => x)),
        "selectedOccuspaceLocations": selectedOccuspaceLocations == null
            ? null
            : List<dynamic>.from(selectedOccuspaceLocations!.map((x) => x)),
        "subscribedTopics": subscribedTopics == null
            ? null
            : List<dynamic>.from(subscribedTopics!.map((x) => x)),
        "ucsdaffiliation": ucsdaffiliation == null ? null : ucsdaffiliation,
        "username": username == null ? null : username,
        "selectedParkingLots": selectedParkingLots == null
            ? null
            : Map.from(selectedParkingLots!
                .map((x, y) => MapEntry<String?, bool>(x, y))),
        "selectedParkingSpots": selectedParkingSpots == null
            ? null
            : Map.from(selectedParkingSpots!
                .map((x, y) => MapEntry<String?, bool>(x, y))),
        "selectedStops": selectedStops == null
            ? null
            : List<dynamic>.from(selectedStops!.map((x) => x)),
        "surveyCompletion": surveyCompletion == null
            ? null
            : List<dynamic>.from(surveyCompletion!.map((x) => x)),
        "selectedVentilationLocations": selectedVentilationLocations == null
            ? null
            : List<dynamic>.from(selectedVentilationLocations!.map((x) => x)),
        "cardsOrder": cardsOrder == null
            ? null
            : List<dynamic>.from(cardsOrder!.map((x) => x)),
      };
}

class Classifications {
  bool? student;
  bool? staff;

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

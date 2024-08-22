// To parse this JSON data, do
//
//     final availabilityStatus = availabilityStatusFromJson(jsonString);

import 'dart:convert';

AvailabilityStatus availabilityStatusFromJson(String str) =>
    AvailabilityStatus.fromJson(json.decode(str));

String availabilityStatusToJson(AvailabilityStatus data) =>
    json.encode(data.toJson());

class AvailabilityStatus {
  AvailabilityStatus({
    required this.status,
    required this.data,
    required this.timestamp,
  });

  String status;
  List<AvailabilityModel> data;
  DateTime timestamp;

  factory AvailabilityStatus.fromJson(Map<String, dynamic> json) =>
      AvailabilityStatus(
        status: json["status"]!,
        data: List<AvailabilityModel>.from(
                json["data"]!.map((x) => AvailabilityModel.fromJson(x))
        ),
        timestamp: DateTime.parse(json["timestamp"]!),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "timestamp": timestamp.toIso8601String(),
      };
}

class AvailabilityModel {
  AvailabilityModel({
    required this.id,
    required this.name,
    required this.subLocations,
  });

  int id;
  String name;
  List<SubLocations> subLocations;

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityModel(
        id: json["id"]!,
        name: json["name"]!,
        subLocations: List<SubLocations>.from(
                json["childCounts"]!.map((x) => SubLocations.fromJson(x))
        ),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "childCounts": List<dynamic>.from(
            subLocations.map((x) => x.toJson())
        ),
      };
}

class SubLocations {
  SubLocations({
    required this.id,
    required this.name,
    required this.percentage,
    required this.isActive,
    required this.floors
  });

  int id;
  String name;
  double percentage;
  bool isActive;
  List<Floor> floors;

  factory SubLocations.fromJson(Map<String, dynamic> json) => SubLocations(
      id: json["id"]!,
      name: json["name"]!,
      percentage: json["percentage"]!.toDouble(),
      isActive: json["isActive"]!,
      floors: List<Floor>.from(
          json["childCounts"]!.map((x) => Floor.fromJson(x))
      )
  );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "percentage": percentage,
        "isActive": isActive,
        "floors": floors
      };
}

class Floor {
  Floor({
    required this.id,
    required this.name,
    required this.count,
    required this.percentage,
    required this.isActive
  });

  int id;
  String name;
  int count;
  double percentage;
  bool isActive;

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
        id: json["id"]!,
        name: json["name"]!,
        count: json["count"]!,
        percentage: json["percentage"]!.toDouble(),
        isActive: json["isActive"]!,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "percentage": percentage,
        "isActive": isActive,
      };
}

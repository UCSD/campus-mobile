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
    this.status,
    this.data,
    this.timestamp,
  });

  String? status;
  List<AvailabilityModel>? data;
  DateTime? timestamp;

  factory AvailabilityStatus.fromJson(Map<String, dynamic> json) =>
      AvailabilityStatus(
        status: json["status"] == null ? null : json["status"],
        data: json["data"] == null
            ? null
            : List<AvailabilityModel>.from(
                json["data"].map((x) => AvailabilityModel.fromJson(x))),
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "timestamp": timestamp == null ? null : timestamp!.toIso8601String(),
      };
}

class AvailabilityModel {
  AvailabilityModel({
    this.id,
    this.name,
    this.childCounts,
  });

  int? id;
  String? name;
  List<ChildCount>? childCounts;

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityModel(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        childCounts: json["childCounts"] == null
            ? null
            : List<ChildCount>.from(
                json["childCounts"].map((x) => ChildCount.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "childCounts": childCounts == null
            ? null
            : List<dynamic>.from(childCounts!.map((x) => x.toJson())),
      };
}

class ChildCount {
  ChildCount({
    this.id,
    this.name,
    this.percentage,
    this.isActive,
  });

  int? id;
  String? name;
  double? percentage;
  bool? isActive;

  factory ChildCount.fromJson(Map<String, dynamic> json) => ChildCount(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        percentage:
            json["percentage"] == null ? null : json["percentage"].toDouble(),
        isActive: json["isActive"] == null ? null : json["isActive"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "percentage": percentage == null ? null : percentage,
        "isActive": isActive == null ? null : isActive,
      };
}

import 'dart:convert';

AvailabilityApiModel availabilityApiModelFromJson(String str) =>
    AvailabilityApiModel.fromJson(json.decode(str));

String availabilityApiModelToJson(AvailabilityApiModel data) =>
    json.encode(data.toJson());

class AvailabilityApiModel {
  AvailabilityApiModel({
    this.status,
    this.data,
    this.timestamp,
  });

  String? status;
  List<AvailabilityGroups>? data;
  DateTime? timestamp;

  factory AvailabilityApiModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityApiModel(
        status: json["status"] == null ? null : json["status"],
        data: json["data"] == null
            ? null
            : List<AvailabilityGroups>.from(
                json["data"].map((x) => AvailabilityGroups.fromJson(x))),
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

class AvailabilityGroups {
  AvailabilityGroups({
    this.id,
    this.name,
    this.childCounts,
  });

  int? id;
  String? name;
  List<AvailabilityModel>? childCounts;

  factory AvailabilityGroups.fromJson(Map<String, dynamic> json) =>
      AvailabilityGroups(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        childCounts: json["childCounts"] == null
            ? null
            : List<AvailabilityModel>.from(
                json["childCounts"].map((x) => AvailabilityModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "childCounts": childCounts == null
            ? null
            : List<dynamic>.from(childCounts!.map((x) => x.toJson())),
      };
}

class AvailabilityModel {
  AvailabilityModel({
    this.id,
    this.name,
    this.percentage,
    this.isActive,
  });

  int? id;
  String? name;
  double? percentage;
  bool? isActive;

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityModel(
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

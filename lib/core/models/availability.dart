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
            : ((){
              List<AvailabilityModel> returnList = List<AvailabilityModel>.from(
                  json["data"].map((x) => AvailabilityModel.fromJson(x)));
              for (int index = 0; index < returnList.length; index++) {
                if (returnList[index].subLocations!.length > 3) {
                    String baseName = returnList[index].name!;
                    int baseId = returnList[index].id!;
                    List<SubLocations> baseSubLocations = returnList[index].subLocations!;
                    returnList.removeAt(index);
                    index--;
                    int curPageIndex = 1;
                    int maxPageIndex = (baseSubLocations.length / 3).ceil();
                    for (int i = 0; i < baseSubLocations.length; i += 3) {
                      index++;
                      List<SubLocations> curSubList = baseSubLocations.sublist(i, i + 3 > baseSubLocations.length ? baseSubLocations.length : i + 3);
                      String curName = baseName + " ($curPageIndex/$maxPageIndex)";
                      returnList.insert(index, AvailabilityModel(id: baseId, name: curName, subLocations: curSubList));
                      curPageIndex++;
                    }
                }
              }
              return returnList;
            })(),
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
    this.subLocations,
  });

  int? id;
  String? name;
  List<SubLocations>? subLocations;

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityModel(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        subLocations: json["childCounts"] == null
            ? null
            : List<SubLocations>.from(
                json["childCounts"].map((x) => SubLocations.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "childCounts": subLocations == null
            ? null
            : List<dynamic>.from(subLocations!.map((x) => x.toJson())),
      };
}

class SubLocations {
  SubLocations(
      {this.id, this.name, this.percentage, this.isActive, this.floors});

  int? id;
  String? name;
  double? percentage;
  bool? isActive;
  List<Floor>? floors;

  factory SubLocations.fromJson(Map<String, dynamic> json) => SubLocations(
      id: json["id"] == null ? null : json["id"],
      name: json["name"] == null ? null : json["name"],
      percentage:
          json["percentage"] == null ? null : json["percentage"].toDouble(),
      isActive: json["isActive"] == null ? null : json["isActive"],
      floors: json["childCounts"] == null
          ? null
          : List<Floor>.from(
              json["childCounts"].map((x) => Floor.fromJson(x))));

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "percentage": percentage == null ? null : percentage,
        "isActive": isActive == null ? null : isActive,
        "floors": floors == null ? null : floors
      };
}

class Floor {
  Floor({this.id, this.name, this.count, this.percentage, this.isActive});

  int? id;
  String? name;
  int? count;
  double? percentage;
  bool? isActive;

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        count: json["count"] == null ? null : json["count"],
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

import 'dart:convert';

List<VentilationLocationsModel> ventilationLocationsModelFromJson(String str) =>
    List<VentilationLocationsModel>.from(
        json.decode(str).map((x) => VentilationLocationsModel.fromJson(x)));

String ventilationLocationsModelToJson(List<VentilationLocationsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VentilationLocationsModel {
  VentilationLocationsModel({
    this.buildingId,
    this.buildingName,
    this.buildingFloors,
  });

  String? buildingId;
  String? buildingName;
  List<BuildingFloor>? buildingFloors;

  factory VentilationLocationsModel.fromJson(Map<String, dynamic> json) =>
      VentilationLocationsModel(
        buildingId: json["BuildingId"] == null ? null : json["BuildingId"],
        buildingName:
            json["BuildingName"] == null ? null : json["BuildingName"],
        buildingFloors: json["BuildingFloors"] == null
            ? null
            : List<BuildingFloor>.from(
                json["BuildingFloors"].map((x) => BuildingFloor.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "BuildingId": buildingId == null ? null : buildingId,
        "BuildingName": buildingName == null ? null : buildingName,
        "BuildingFloors": buildingFloors == null
            ? null
            : List<dynamic>.from(buildingFloors!.map((x) => x.toJson())),
      };
}

class BuildingFloor {
  BuildingFloor({
    this.buildingFloorNumber,
    this.buildingFloorRooms,
  });

  int? buildingFloorNumber;
  List<String>? buildingFloorRooms;

  factory BuildingFloor.fromJson(Map<String, dynamic> json) => BuildingFloor(
        buildingFloorNumber: json["BuildingFloorNumber"] == null
            ? null
            : json["BuildingFloorNumber"],
        buildingFloorRooms: json["BuildingFloorRooms"] == null
            ? null
            : List<String>.from(json["BuildingFloorRooms"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "BuildingFloorNumber":
            buildingFloorNumber == null ? null : buildingFloorNumber,
        "BuildingFloorRooms": buildingFloorRooms == null
            ? null
            : List<dynamic>.from(buildingFloorRooms!.map((x) => x)),
      };
}

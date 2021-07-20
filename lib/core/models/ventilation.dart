import 'dart:convert';

List<VentilationModel> ventilationModelFromJson(String str) =>
    List<VentilationModel>.from(
        json.decode(str).map((x) => VentilationModel.fromJson(x)));

String ventilationModelToJson(List<VentilationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VentilationModel {
  String? buildingId;
  String? buildingName;
  List<BuildingFloor>? buildingFloors;

  VentilationModel({
    this.buildingId,
    this.buildingName,
    this.buildingFloors,
  });

  factory VentilationModel.fromJson(Map<String, dynamic> json) =>
      VentilationModel(
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
  List<BuildingFloorRoom>? buildingFloorRooms;

  factory BuildingFloor.fromJson(Map<String, dynamic> json) => BuildingFloor(
        buildingFloorNumber: json["BuildingFloorNumber"] == null
            ? null
            : json["BuildingFloorNumber"],
        buildingFloorRooms: json["BuildingFloorRooms"] == null
            ? null
            : List<BuildingFloorRoom>.from(json["BuildingFloorRooms"]
                .map((x) => BuildingFloorRoom.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "BuildingFloorNumber":
            buildingFloorNumber == null ? null : buildingFloorNumber,
        "BuildingFloorRooms": buildingFloorRooms == null
            ? null
            : List<dynamic>.from(buildingFloorRooms!.map((x) => x.toJson())),
      };
}

class BuildingFloorRoom {
  BuildingFloorRoom({
    this.buildingRoomName,
    this.currentTemperature,
    this.windowsOpen,
    this.hvacActive,
  });

  String? buildingRoomName;
  String? currentTemperature;
  bool? windowsOpen;
  bool? hvacActive;

  factory BuildingFloorRoom.fromJson(Map<String, dynamic> json) =>
      BuildingFloorRoom(
        buildingRoomName:
            json["BuildingRoomName"] == null ? null : json["BuildingRoomName"],
        currentTemperature: json["CurrentTemperature"] == null
            ? null
            : json["CurrentTemperature"],
        windowsOpen: json["WindowsOpen"] == null ? null : json["WindowsOpen"],
        hvacActive: json["HVACActive"] == null ? null : json["HVACActive"],
      );

  Map<String, dynamic> toJson() => {
        "BuildingRoomName": buildingRoomName == null ? null : buildingRoomName,
        "CurrentTemperature":
            currentTemperature == null ? null : currentTemperature,
        "WindowsOpen": windowsOpen == null ? null : windowsOpen,
        "HVACActive": hvacActive == null ? null : hvacActive,
      };
}

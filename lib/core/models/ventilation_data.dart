import 'dart:convert';

/// MIGHT WANT TO FIX THE INSIDE OF THE CODE
List<VentilationDataModel> ventilationDataModelFromJson(String str) {
  return List<VentilationDataModel>.from(
      json.decode(str).map((x) => VentilationDataModel.fromJson(x)));
}

String ventilationDataModelToJson(VentilationDataModel data) =>
    json.encode(data.toJson());

class VentilationDataModel {
  VentilationDataModel({
    this.buildingName,
    this.buildingFloorName,
    this.buildingRoomName,
    this.currentTemperature,
    this.windowsOpen,
    this.hvacActive,
  });

  String? buildingName;
  String? buildingFloorName;
  String? buildingRoomName;
  String? currentTemperature;
  bool? windowsOpen;
  bool? hvacActive;

  factory VentilationDataModel.fromJson(Map<String, dynamic> json) =>
      VentilationDataModel(
        buildingName:
            json["BuildingName"] == null ? null : json["BuildingName"],
        buildingFloorName: json["BuildingFloorName"] == null
            ? null
            : json["BuildingFloorName"],
        buildingRoomName:
            json["BuildingRoomName"] == null ? null : json["BuildingRoomName"],
        currentTemperature: json["CurrentTemperature"] == null
            ? null
            : json["CurrentTemperature"],
        windowsOpen: json["WindowsOpen"] == null ? null : json["WindowsOpen"],
        hvacActive: json["HVACActive"] == null ? null : json["HVACActive"],
      );

  Map<String, dynamic> toJson() => {
        "BuildingName": buildingName == null ? null : buildingName,
        "BuildingFloorName":
            buildingFloorName == null ? null : buildingFloorName,
        "BuildingRoomName": buildingRoomName == null ? null : buildingRoomName,
        "CurrentTemperature":
            currentTemperature == null ? null : currentTemperature,
        "WindowsOpen": windowsOpen == null ? null : windowsOpen,
        "HVACActive": hvacActive == null ? null : hvacActive,
      };
}

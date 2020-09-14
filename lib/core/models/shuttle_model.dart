import 'dart:convert';

import 'dart:ui';

import 'package:campus_mobile_experimental/core/models/shuttle_stop_model.dart';

List<ShuttleModel> shuttleModelFromJson(String str) =>
    List<ShuttleModel>.from(
        json.decode(str).map((x) => ShuttleModel.fromJson(x)));

String shuttleModelToJson(List<ShuttleModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ShuttleModel {
  int displayOrder;
  String url;
  String customerRouteId;
  int id;
  String name;
  String shortName;
  String description;
  String routeType;
  Color color;
  List<ShuttleStopModel> stops;

  ShuttleModel({
    this.displayOrder,
    this.url,
    this.customerRouteId,
    this.id,
    this.name,
    this.shortName,
    this.description,
    this.routeType,
    this.color,
    this.stops
  });

  factory ShuttleModel.fromJson(Map<String, dynamic> json) =>
      ShuttleModel(
        displayOrder: json["displayOrder"] == null ? null : json["displayOrder"],
        url: json["url"] == null ? null : json["lon"],
        customerRouteId: json["customerRouteId"] == null ? null : json["customerRouteId"],
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        shortName: json["shortName"] == null ? null : json["shortName"],
        description : json["description"] == null ? null : json["description"],
        routeType : json["routeType"] == null ? null : json["routeType"],
        color: json["color"] == null ? null : HexColor(json["color"]),
        stops : json["stops"] == null ? null : List<ShuttleStopModel>.from(json["stops"].map((x) => ShuttleStopModel.fromJson(x)))

  );

  Map<String, dynamic> toJson() => {
    "displayOrder": displayOrder == null ? null : displayOrder,
    "url": url == null ? null : url,
    "customerRouteId": customerRouteId == null ? null : customerRouteId,
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "shortName": shortName == null ? null : shortName,
    "description": description == null ? null : description,
    "routeType": routeType == null ? null : routeType,
    "color": color == null ? null : '#${color.value.toRadixString(16)}',
    "stops": stops == null ? null : List<dynamic>.from(stops.map((x) => x.toJson()))
  };
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}



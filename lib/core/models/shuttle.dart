import 'dart:convert';
import 'dart:ui';

import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';

List<ShuttleModel> shuttleModelFromJson(String str) =>
    json.decode(str).map((x) => ShuttleModel.fromJson(x));

//    List<ShuttleModel>.from(
//        json.decode(str).map((x) => ShuttleModel.fromJson(x)));

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
  List<ShuttleStopModel> stops = List<ShuttleStopModel>();

  ShuttleModel(
      {this.displayOrder,
      this.url,
      this.customerRouteId,
      this.id,
      this.name,
      this.shortName,
      this.description,
      this.routeType,
      this.color,
      this.stops});

  ShuttleModel.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      return (ShuttleModel(
          displayOrder:
              value["displayOrder"] == null ? null : value["displayOrder"],
          url: value["url"] == null ? null : value["lon"],
          customerRouteId: value["customerRouteId"] == null
              ? null
              : value["customerRouteId"],
          id: value["id"] == null ? null : value["id"],
          name: value["name"] == null ? null : value["name"],
          shortName: value["shortName"] == null ? null : value["shortName"],
          description:
              value["description"] == null ? null : value["description"],
          routeType: value["routeType"] == null ? null : value["routeType"],
          color: value["color"] == null ? null : HexColor(value["color"]),
          stops: value["stops"] == null
              ? null
              : value["stops"]
                  .entries
                  .map((entry) {
                    return (ShuttleStopModel.fromJson(entry.value));
                  })
                  .toList()
                  .cast<ShuttleStopModel>()));
    });
  }

  List<ShuttleModel> getListOfShuttles(String str) {
    Map<String, dynamic> list = json.decode(str);
    List<ShuttleModel> ret = List<ShuttleModel>();
    list.forEach((key, value) {
      ret.add(ShuttleModel(
          displayOrder:
              value["displayOrder"] == null ? null : value["displayOrder"],
          url: value["url"] == null ? null : value["lon"],
          customerRouteId: value["customerRouteId"] == null
              ? null
              : value["customerRouteId"],
          id: value["id"] == null ? null : value["id"],
          name: value["name"] == null ? null : value["name"],
          shortName: value["shortName"] == null ? null : value["shortName"],
          description:
              value["description"] == null ? null : value["description"],
          routeType: value["routeType"] == null ? null : value["routeType"],
          color: value["color"] == null ? null : HexColor(value["color"]),
          stops: value["stops"] == null
              ? null
              : value["stops"]
                  .entries
                  .map((entry) {
                    return (ShuttleStopModel.fromJson(entry.value));
                  })
                  .toList()
                  .cast<ShuttleStopModel>()));
    });
    return ret;
  }

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
        "stops": stops == null
            ? null
            : List<dynamic>.from(stops.map((x) => x.toJson()))
      };
}

class HexColor extends Color {
  static int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(getColorFromHex(hexColor));
}

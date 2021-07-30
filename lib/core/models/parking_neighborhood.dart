// To parse this JSON data, do
//
//     final neighborhoodsModel = neighborhoodsModelFromJson(jsonString);

import 'dart:convert';

List<NeighborhoodsModel> neighborhoodsModelFromJson(String str) => List<NeighborhoodsModel>.from(json.decode(str).map((x) => NeighborhoodsModel.fromJson(x)));

String neighborhoodsModelToJson(List<NeighborhoodsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NeighborhoodsModel {
  NeighborhoodsModel({
    this.neighborhoodId,
    this.neighborhoodName,
    this.neighborhoodLots,
  });

  String? neighborhoodId;
  String? neighborhoodName;
  List<String>? neighborhoodLots;

  factory NeighborhoodsModel.fromJson(Map<String, dynamic> json) => NeighborhoodsModel(
    neighborhoodId: json["NeighborhoodId"] == null ? null : json["NeighborhoodId"],
    neighborhoodName: json["NeighborhoodName"] == null ? null : json["NeighborhoodName"],
    neighborhoodLots: json["NeighborhoodLots"] == null ? null : List<String>.from(json["NeighborhoodLots"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "NeighborhoodId": neighborhoodId == null ? null : neighborhoodId,
    "NeighborhoodName": neighborhoodName == null ? null : neighborhoodName,
    "NeighborhoodLots": neighborhoodLots == null ? null : List<dynamic>.from(neighborhoodLots!.map((x) => x)),
  };
}

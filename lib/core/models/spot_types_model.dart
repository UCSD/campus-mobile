import 'dart:convert';

SpotTypeModel spotTypeModelFromJson(String str) =>
    SpotTypeModel.fromJson(json.decode(str));

String spotTypeModelToJson(SpotTypeModel data) => json.encode(data.toJson());

class SpotTypeModel {
  List<Spot> spots;

  SpotTypeModel({
    this.spots,
  });

  factory SpotTypeModel.fromJson(Map<String, dynamic> json) => SpotTypeModel(
        spots: json["spots"] == null
            ? null
            : List<Spot>.from(json["spots"].map((x) => Spot.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "spots": spots == null
            ? null
            : List<dynamic>.from(spots.map((x) => x.toJson())),
      };
}

class Spot {
  String spotKey;
  String name;
  String color;

  Spot({this.spotKey, this.name, this.color});

  factory Spot.fromJson(Map<String, dynamic> json) => Spot(
        spotKey: json["key"] == null ? null : json["key"],
        name: json["name"] == null ? null : json["name"],
        color: json["color"] == null ? null : json["color"],
      );

  Map<String, dynamic> toJson() => {
        "key": spotKey == null ? null : spotKey,
        "name": name == null ? null : name,
        "color": color == null ? null : color,
      };
}

import 'dart:convert';

SpotTypeModel spotTypeModelFromJson(String str) =>
    SpotTypeModel.fromJson(json.decode(str));

String spotTypeModelToJson(SpotTypeModel data) => json.encode(data.toJson());

class SpotTypeModel {
  List<Spot>? spots;

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
            : List<dynamic>.from(spots!.map((x) => x.toJson())),
      };
}

class Spot {
  String spotKey;
  String name;
  String logoBackgroundColor;
  String logoText;
  String logoTextColor;

  Spot({
    this.spotKey = '',
    this.name = '',
    this.logoBackgroundColor = '',
    this.logoText = '',
    this.logoTextColor = '',
  });

  factory Spot.fromJson(Map<String, dynamic> json) => Spot(
        spotKey: json["key"] ?? '',
        name: json["name"] ?? '',
        logoBackgroundColor: json["logo_background_color"] ?? '',
        logoText: json["logo_text"] ?? '',
        logoTextColor: json["logo_text_color"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "key": spotKey,
        "name": name,
        "logo_background_color": logoBackgroundColor,
        "logo_text": logoText,
        "logo_text_color": logoTextColor,
      };
}

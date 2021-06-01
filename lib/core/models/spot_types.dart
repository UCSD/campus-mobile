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
  String? spotKey;
  String? name;
  String? color;
  String? text;
  String? textColor;

  Spot({this.spotKey, this.name, this.color, this.text, this.textColor});

  factory Spot.fromJson(Map<String, dynamic> json) => Spot(
        spotKey: json["key"] == null ? null : json["key"],
        name: json["name"] == null ? null : json["name"],
        color: json["color"] == null ? null : json["color"],
        text: json["text"] == null ? null : json["text"],
        textColor: json["text_color"] == null ? null : json["text_color"],
      );

  Map<String, dynamic> toJson() => {
        "key": spotKey == null ? null : spotKey,
        "name": name == null ? null : name,
        "color": color == null ? null : color,
        "text": text == null ? null : text,
        "textColor": textColor == null ? null : textColor
      };
}

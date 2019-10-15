// To parse this JSON data, do
//
//     final links = linksFromJson(jsonString);

import 'dart:convert';

List<LinksModel> linksFromJson(String str) =>
    List<LinksModel>.from(json.decode(str).map((x) => LinksModel.fromJson(x)));

String linksToJson(List<LinksModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LinksModel {
  String name;
  String url;
  String icon;
  int cardOrder;

  LinksModel({
    this.name,
    this.url,
    this.icon,
    this.cardOrder,
  });

  factory LinksModel.fromJson(Map<String, dynamic> json) => LinksModel(
        name: json["name"] == null ? null : json["name"],
        url: json["url"] == null ? null : json["url"],
        icon: json["icon"] == null ? null : json["icon"],
        cardOrder: json["card-order"] == null ? null : json["card-order"],
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "url": url == null ? null : url,
        "icon": icon == null ? null : icon,
        "card-order": cardOrder == null ? null : cardOrder,
      };
}

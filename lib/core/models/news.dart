// To parse this JSON data, do
//
//     final newsModel = newsModelFromJson(jsonString);

import 'dart:convert';

NewsModel newsModelFromJson(String str) => NewsModel.fromJson(json.decode(str));

String newsModelToJson(NewsModel data) => json.encode(data.toJson());

class NewsModel {
  List<Item> items;

  NewsModel({
    this.items,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        items: json["items"] == null
            ? null
            : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  DateTime date;
  String title;
  String description;
  String link;
  String image;

  Item({
    this.date,
    this.title,
    this.description,
    this.link,
    this.image,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        title: json["title"] == null ? null : json["title"],
        description:
            json["description"] == null ? null : json["description"].trim(),
        link: json["link"] == null ? null : json["link"],
        image: json["image"] == null ? null : json["image"],
      );

  Map<String, dynamic> toJson() => {
        "date": date == null ? null : date.toIso8601String(),
        "title": title == null ? null : title,
        "description": description == null ? null : description.trim(),
        "link": link == null ? null : link,
        "image": image == null ? null : image,
      };
}

// To parse this JSON data, do
//
//     final newsModel = newsModelFromJson(jsonString);

import 'dart:convert';

NewsModel newsModelFromJson(String str) => NewsModel.fromJson(json.decode(str));

String newsModelToJson(NewsModel data) => json.encode(data.toJson());

class NewsModel {
  List<Item> items;

  NewsModel({
    List<Item>? items,
  }) : items = items ?? [];

  NewsModel.fromJson(Map<String, dynamic> json)
      : items = List<Item>.from(json["items"].map((x) => Item.fromJson(x)));

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  DateTime date;
  String title;
  String description;
  String link;
  String image;

  Item({
    required this.date,
    required this.title,
    required this.description,
    required this.link,
    required this.image,
  });

  Item.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json["date"]),
        title = json["title"],
        description = json["description"].trim(),
        link = json["link"],
        image = json["image"];

  Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "title": title,
        "description": description.trim(),
        "link": link,
        "image": image,
      };
}

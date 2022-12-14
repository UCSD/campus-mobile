// To parse this JSON data, do
//
//     final eventModel = eventModelFromJson(jsonString);

import 'dart:convert';

List<EventModel> eventModelFromJson(String str) =>
    List<EventModel>.from(json.decode(str).map((x) => EventModel.fromJson(x)));

String eventModelToJson(List<EventModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventModel {
  EventModel({
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.imageHQ,
    this.imageThumb,
    this.link,
    this.id,
    this.tags,
    this.location,
  });

  String? title;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  String? imageHQ;
  String? imageThumb;
  String? link;
  String? id;
  List<String>? tags;
  String? location;

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        startDate: DateTime.tryParse(json["startDate"]),
        endDate: DateTime.tryParse(json["endDate"]),
        imageHQ: json["imageHQ"] == null ? null : json["imageHQ"],
        imageThumb: json["imageThumb"] == null ? null : json["imageThumb"],
        link: json["link"] == null ? null : json["link"],
        id: json["id"] == null ? null : json["id"],
        tags: json["tags"] == null
            ? null
            : List<String>.from(json["tags"].map((x) => x)),
        location: json["location"] == null ? null : json["location"],
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "startDate": startDate == null ? null : startDate,
        "endDate": endDate == null ? null : endDate,
        "imageHQ": imageHQ == null ? null : imageHQ,
        "imageThumb": imageThumb == null ? null : imageThumb,
        "link": link == null ? null : link,
        "id": id == null ? null : id,
        "tags": tags == null ? null : List<dynamic>.from(tags!.map((x) => x)),
        "location": location == null ? null : location,
      };
}

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
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.imageHQ,
    required this.imageThumb,
    this.link,
    this.id,
    this.tags,
    this.location,
  });

  String title;
  String? description;
  DateTime startDate;
  DateTime endDate;
  String imageHQ;
  String imageThumb;
  String? link;
  String? id;
  List<String>? tags; // unused, nullability not confirmed
  String? location;

  EventModel.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        description = json["description"],
        startDate = DateTime.parse(json["startDate"]),
        endDate = DateTime.parse(json["endDate"]),
        imageHQ = json["imageHQ"],
        imageThumb = json["imageThumb"],
        link = json["link"],
        id = json["id"],
        tags = json["tags"] == null
            ? null
            : List<String>.from(json["tags"].map((x) => x)),
        location = json["location"];

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "startDate": startDate,
        "endDate": endDate,
        "imageHQ": imageHQ,
        "imageThumb": imageThumb,
        "link": link,
        "id": id,
        "tags": tags == null ? null : List<dynamic>.from(tags!.map((x) => x)),
        "location": location,
      };
}

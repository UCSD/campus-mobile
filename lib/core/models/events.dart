// To parse this JSON data, do
//
//     final eventsModel = eventsModelFromJson(jsonString);

import 'dart:convert';

List<EventModel> eventsModelFromJson(String str) =>
    List<EventModel>.from(json.decode(str).map((x) => EventModel.fromJson(x)));

String eventsModelToJson(List<EventModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventModel {
  String id;
  String title;
  String location;
  DateTime eventDate;
  String startTime;
  String endTime;
  String description;
  String shortDescription;
  String imageThumb;
  String imageHQ;
  String contactInfo;
  String contactPhone;
  String url;
  List<String> tags;

  EventModel({
    this.id,
    this.title,
    this.location,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.description,
    this.shortDescription,
    this.imageThumb,
    this.imageHQ,
    this.contactInfo,
    this.contactPhone,
    this.url,
    this.tags,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        location: json["location"] == null ? null : json["location"],
        eventDate: json["eventdate"] == null
            ? null
            : DateTime.parse(json["eventdate"]),
        startTime: json["starttime"] == null ? null : json["starttime"],
        endTime: json["endtime"] == null ? null : json["endtime"],
        description: json["description"] == null ? null : json["description"],
        shortDescription:
            json["shortdescription"] == null ? null : json["shortdescription"],
        imageThumb: json["imagethumb"] == null ? null : json["imagethumb"],
        imageHQ: json["imagehq"] == null ? null : json["imagehq"],
        contactInfo: json["contact_info"] == null ? null : json["contact_info"],
        contactPhone:
            json["contact_phone"] == null ? null : json["contact_phone"],
        url: json["url"] == null ? null : json["url"],
        tags: json["tags"] == null
            ? null
            : List<String>.from(json["tags"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "location": location == null ? null : location,
        "eventdate": eventDate == null
            ? null
            : "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
        "starttime": startTime == null ? null : startTime,
        "endtime": endTime == null ? null : endTime,
        "description": description == null ? null : description,
        "shortdescription": shortDescription == null ? null : shortDescription,
        "imagethumb": imageThumb == null ? null : imageThumb,
        "imagehq": imageHQ == null ? null : imageHQ,
        "contact_info": contactInfo == null ? null : contactInfo,
        "contact_phone": contactPhone == null ? null : contactPhone,
        "url": url == null ? null : url,
        "tags": tags == null ? null : List<dynamic>.from(tags.map((x) => x)),
      };
}

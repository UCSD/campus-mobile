// To parse this JSON data, do
//
//     final newsModel = newsModelFromJson(jsonString);

import 'dart:convert';

List<NewsModel> newsModelFromJson(String str) =>
    List<NewsModel>.from(json.decode(str).map((x) => NewsModel.fromJson(x)));

String newsModelToJson(List<NewsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewsModel {
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

  NewsModel({
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

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
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

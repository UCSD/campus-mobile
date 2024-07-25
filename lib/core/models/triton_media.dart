// To parse this JSON data, do
//
//     final eventModel = eventModelFromJson(jsonString);

import 'dart:convert';

List<MediaModel> mediaModelFromJson(String str) =>
    List<MediaModel>.from(json.decode(str).map((x) => MediaModel.fromJson(x)));

String mediaModelToJson(List<MediaModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

//Remove location as well as end, event and start dates
class MediaModel {
  MediaModel({
    required this.title,
    required this.description,
    required this.imageHQ,
    required this.imageThumb,
    required this.link,
    required this.id,
    required this.tags,
  });

  String title;
  String description;
  String imageHQ;
  String imageThumb;
  String link;
  String id;
  List<String> tags;

  factory MediaModel.fromJson(Map<String, dynamic> json) => MediaModel(
    title: json["title"] ?? '',
    description: json["description"] ?? '',
    imageHQ: json["imageHQ"] ?? '',
    imageThumb: json["imageThumb"] ?? '',
    link: json["link"] ?? '',
    id: json["id"] ?? '',
    tags: json["tags"] != null ? List<String>.from(json["tags"].map((x) => x)) : [],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "imageHQ": imageHQ,
    "imageThumb": imageThumb,
    "link": link,
    "id": id,
    "tags": List<dynamic>.from(tags.map((x) => x)),
  };
}

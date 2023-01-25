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
  MediaModel(
      {this.title,
      this.description,
      this.imageHQ,
      this.imageThumb,
      this.link,
      this.id,
      this.tags,
      this.eventDate});

  String? title;
  String? description;
  String? imageHQ;
  String? imageThumb;
  String? link;
  String? id;
  DateTime? eventDate;
  List<String>? tags;

  factory MediaModel.fromJson(Map<String, dynamic> json) => MediaModel(
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        imageHQ: json["imageHQ"] == null ? null : json["imageHQ"],
        imageThumb: json["imageThumb"] == null ? null : json["imageThumb"],
        eventDate: DateTime.tryParse(json["eventdate"]),
        link: json["link"] == null ? null : json["link"],
        id: json["id"] == null ? null : json["id"],
        tags: json["tags"] == null
            ? null
            : List<String>.from(json["tags"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "imageHQ": imageHQ == null ? null : imageHQ,
        "imageThumb": imageThumb == null ? null : imageThumb,
        "link": link == null ? null : link,
        "id": id == null ? null : id,
        "eventDate": eventDate == null ? null : eventDate,
        "tags": tags == null ? null : List<dynamic>.from(tags!.map((x) => x)),
      };
}

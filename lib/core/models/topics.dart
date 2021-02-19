// To parse this JSON data, do
//
//     final topicsModel = topicsModelFromJson(jsonString);

import 'dart:convert';

List<TopicsModel> topicsModelFromJson(String str) => List<TopicsModel>.from(
    json.decode(str).map((x) => TopicsModel.fromJson(x)));

String topicsModelToJson(List<TopicsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TopicsModel {
  String audienceId;
  List<Topic> topics;

  TopicsModel({
    this.audienceId,
    this.topics,
  });

  factory TopicsModel.fromJson(Map<String, dynamic> json) => TopicsModel(
        audienceId: json["audienceId"] == null ? null : json["audienceId"],
        topics: json["topics"] == null
            ? null
            : List<Topic>.from(json["topics"].map((x) => Topic.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "audienceId": audienceId == null ? null : audienceId,
        "topics": topics == null
            ? null
            : List<dynamic>.from(topics.map((x) => x.toJson())),
      };
}

class Topic {
  String topicId;
  TopicMetadata topicMetadata;

  Topic({
    this.topicId,
    this.topicMetadata,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        topicId: json["topicId"] == null ? null : json["topicId"],
        topicMetadata: json["topicMetadata"] == null
            ? null
            : TopicMetadata.fromJson(json["topicMetadata"]),
      );

  Map<String, dynamic> toJson() => {
        "topicId": topicId == null ? null : topicId,
        "topicMetadata": topicMetadata == null ? null : topicMetadata.toJson(),
      };
}

class TopicMetadata {
  String name;
  String description;

  TopicMetadata({
    this.name,
    this.description,
  });

  factory TopicMetadata.fromJson(Map<String, dynamic> json) => TopicMetadata(
        name: json["name"] == null ? null : json["name"],
        description: json["description"] == null ? null : json["description"],
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "description": description == null ? null : description,
      };
}

// To parse this JSON data, do
//
//     final messages = messagesFromJson(jsonString);

import 'dart:convert';

Messages messagesFromJson(String str) => Messages.fromJson(json.decode(str));

String messagesToJson(Messages data) => json.encode(data.toJson());

class Messages {
  List<MessageElement>? messages;
  int? next;

  Messages({this.messages, this.next});

  factory Messages.fromJson(Map<String, dynamic> json) => Messages(
        messages: json["messages"] == null
            ? null
            : List<MessageElement>.from(
                json["messages"].map((x) => MessageElement.fromJson(x))),
        next: json["next"] == null ? null : json["next"],
      );

  Map<String, dynamic> toJson() => {
        "messages": messages == null
            ? null
            : List<dynamic>.from(messages!.map((x) => x.toJson())),
        "next": next == null ? null : next
      };
}

class MessageElement {
  MessageElement({
    this.sender,
    this.message,
    this.messageId,
    this.audience,
    this.timestamp,
  });

  String? sender;
  Message? message;
  String? messageId;
  Audience? audience;
  int? timestamp;

  factory MessageElement.fromJson(Map<String, dynamic> json) => MessageElement(
        sender: json["sender"] == null ? null : json["sender"],
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
        messageId: json["messageId"] == null ? null : json["messageId"],
        audience: json["audience"] == null
            ? null
            : Audience.fromJson(json["audience"]),
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "sender": sender == null ? null : sender,
        "message": message == null ? null : message!.toJson(),
        "messageId": messageId == null ? null : messageId,
        "audience": audience == null ? null : audience!.toJson(),
        "timestamp": timestamp == null ? null : timestamp,
      };
}

class Audience {
  Audience({
    this.topics,
  });

  List<String>? topics;

  factory Audience.fromJson(Map<String, dynamic> json) => Audience(
        topics: json["topics"] == null
            ? null
            : List<String>.from(json["topics"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "topics":
            topics == null ? null : List<dynamic>.from(topics!.map((x) => x)),
      };
}

class Message {
  String? message;
  String? title;
  Data? data;

  Message({
    this.message,
    this.title,
    this.data,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        message: json["message"],
        title: json["title"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "title": title,
        "data": data == null ? null : data!.toJson(),
      };
}

class Data {
  Data();

  factory Data.fromJson(Map<String, dynamic>? json) => Data();

  Map<String, dynamic> toJson() => {};
}

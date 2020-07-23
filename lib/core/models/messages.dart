// To parse this JSON data, do
//
//     final messages = messagesFromJson(jsonString);

import 'dart:convert';

Messages messagesFromJson(String str) => Messages.fromJson(json.decode(str));

String messagesToJson(Messages data) => json.encode(data.toJson());

class Messages {
  List<MessageElement> messages;
  int next;

  Messages({
    this.messages,
    this.next
  });

  factory Messages.fromJson(Map<String, dynamic> json) => Messages(
        messages: List<MessageElement>.from(
            json["messages"].map((x) => MessageElement.fromJson(x))),
        next: json["next"] == null ? null : json["next"],
      );

  Map<String, dynamic> toJson() => {
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
        "next": next == null ? null : next,
      };
}

class MessageElement {
  String sender;
  Message message;
  String messageId;
  int timestamp;

  MessageElement({
    this.sender,
    this.message,
    this.messageId,
    this.timestamp,
  });

  factory MessageElement.fromJson(Map<String, dynamic> json) => MessageElement(
        sender: json["sender"],
        message: Message.fromJson(json["message"]),
        messageId: json["messageId"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "sender": sender,
        "message": message.toJson(),
        "messageId": messageId,
        "timestamp": timestamp,
      };
}

class Message {
  String message;
  String title;
  Data data;

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
        "data": data == null ? null : data.toJson(),
      };
}

class Data {
  Data();

  factory Data.fromJson(Map<String, dynamic> json) => Data();

  Map<String, dynamic> toJson() => {};
}

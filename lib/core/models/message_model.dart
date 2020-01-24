// To parse this JSON data, do
//
//     final messagingModel = messagingModelFromJson(jsonString);

import 'dart:convert';

MessagingModel messagingModelFromJson(String str) => MessagingModel.fromJson(json.decode(str));

String messagingModelToJson(MessagingModel data) => json.encode(data.toJson());

class MessagingModel {
    List<Message> messages;
    int next;

    MessagingModel({
        this.messages,
        this.next,
    });

    factory MessagingModel.fromJson(Map<String, dynamic> json) => MessagingModel(
        messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
        next: json["next"],
    );

    Map<String, dynamic> toJson() => {
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
        "next": next,
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
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "title": title,
        "data": data.toJson(),
    };
}

class Data {
    Data();

    factory Data.fromJson(Map<String, dynamic> json) => Data(
    );

    Map<String, dynamic> toJson() => {
    };
}

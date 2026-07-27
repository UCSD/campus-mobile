import 'dart:convert';

// To parse this JSON data, do
//
//     final cardsModel = cardsModelFromJson(jsonString);
Map<String, CardsModel> cardsModelFromJson(String str) =>
    Map.from(json.decode(str)).map((k, v) => MapEntry<String, CardsModel>(k, CardsModel.fromJson(v)));

String cardsModelToJson(Map<String, CardsModel> data) =>
    json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())));

class CardsModel {
  CardsModel(
      {required this.cardActive,
      required this.initialURL,
      required this.isWebCard,
      required this.requireAuth,
      required this.titleText,
      this.externalLinkURL = '',
      this.externalLinkText = ''});

  bool cardActive;
  String initialURL;
  bool isWebCard;
  bool requireAuth;
  String titleText;
  String externalLinkURL;
  String externalLinkText;

  factory CardsModel.fromJson(Map<String, dynamic> json) => CardsModel(
        cardActive: json["cardActive"]!,
        initialURL: json["initialURL"]!,
        isWebCard: json["isWebCard"]!,
        requireAuth: json["requireAuth"]!,
        titleText: json["titleText"]!,
        externalLinkURL: json["externalLinkURL"] as String? ?? '',
        externalLinkText: json["externalLinkText"] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        "cardActive": cardActive,
        "initialURL": initialURL,
        "isWebCard": isWebCard,
        "requireAuth": requireAuth,
        "titleText": titleText,
        "externalLinkURL": externalLinkURL,
        "externalLinkText": externalLinkText,
      };
}

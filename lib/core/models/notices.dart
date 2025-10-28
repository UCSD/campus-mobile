import 'dart:convert';

String noticeTitleKey = "notice-title";
String noticeBannerImageKey = "notice-banner-image";
String noticeBannerLinkKey = "notice-banner-link";

List<NoticesModel> noticesModelFromJson(String str) => List<NoticesModel>.from(
    json.decode(str).map((x) => NoticesModel.fromJson(x)));

String noticesModelToJson(List<NoticesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NoticesModel
{
  String title;
  String imageUrl;
  String link;

  NoticesModel({
    required this.title,
    required this.imageUrl,
    required this.link,
  });

  NoticesModel.fromJson(Map<String, dynamic> json)
      : title = json[noticeTitleKey],
        imageUrl = json[noticeBannerImageKey],
        link = json[noticeBannerLinkKey];

  Map<String, dynamic> toJson() => {
        noticeTitleKey: title,
        noticeBannerImageKey: imageUrl,
        noticeBannerLinkKey: link
      };
}

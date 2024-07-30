import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/notices.dart';
import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticesCard extends StatelessWidget {
  const NoticesCard({
    Key? key,
    required this.notice,
  }) : super(key: key);

  final NoticesModel notice;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
          top: 0.0, right: 0.0, bottom: cardMargin * 1.5, left: 0.0),
      child: buildBannerView(notice),
    );
  }

  Widget buildBannerView(NoticesModel notice) {
    // The screen reader will read - "image - (text on the image)"
    return Semantics(
      label: notice.title,
      image: true,
      button: true,
      child: GestureDetector(
          onTap: () {
            openLink(notice.link);
          },
          child: ImageLoader(
            url: notice.imageUrl,
            fullSize: true,
          )),
    );
  }

  openLink(String url) async {
    try {
      launch(url, forceSafariVC: true);
    } catch (e) {
      // an error occurred, do nothing
    }
  }
}

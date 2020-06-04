import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/notices_model.dart';
import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:campus_mobile_experimental/ui/views/special_events/banner_container.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/image_loader.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticesCard extends StatelessWidget {
  const NoticesCard({
    Key key,
    @required this.notice,
  }) : super(key: key);

  final NoticesModel notice;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 0.0, right: 0.0, bottom: cardMargin, left: 0.0),
      child: buildBannerView(notice),
    );
  }

  Widget buildBannerView(NoticesModel notice) {
    return GestureDetector(
      onTap: () {
        openLink(notice.link);
      },
      child: ImageLoader(
        url: notice.imageUrl,
        fullSize: true,
      ));
  }

  openLink(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    }
    else {
      // can't launch url, there is some error
    }
  }
}
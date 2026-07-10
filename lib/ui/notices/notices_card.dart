import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/notices.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:flutter/material.dart';

class NoticesCard extends StatelessWidget {
  const NoticesCard({
    Key? key,
    required this.notice,
  }) : super(key: key);

  /// MODELS
  final NoticesModel notice;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 0.0, right: 0.0, bottom: cardMargin * 1.5, left: 0.0),
      elevation: 4,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: buildBannerView(notice),
      ),
    );
  }

  Widget buildBannerView(NoticesModel notice) {
    String accessibilityLabel = notice.title;
    if (notice.title == 'Triton Weeks of Welcome - Welcoming new students to the Triton community') accessibilityLabel = 'T W O W - Triton Weeks of Welcome - visit t w o w dot ucsd dot e d u';

    // The screen reader will read - "image - (text on the image)"
    // print('\x1B[32mNoticesModel(title: ${notice.title}, link: ${notice.link}, imageUrl: ${notice.imageUrl})\x1B[0m');
    return Semantics(
      label: accessibilityLabel,
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
}

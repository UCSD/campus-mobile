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

  // VoiceOver/TalkBack read "TWOW" as a made-up word instead of spelling it
  // out, so it's spaced into individual letters for the accessibility label only.
  static final RegExp _twowPattern = RegExp(r'\bTWOW\b', caseSensitive: false);

  static String _spellOutForScreenReaders(String text) => text.replaceAll(_twowPattern, 'T W O W');

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
    // The screen reader will read - "image - (text on the image)"
    return Semantics(
      label: _spellOutForScreenReaders(notice.title),
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

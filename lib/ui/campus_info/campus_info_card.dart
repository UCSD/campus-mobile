import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/webview_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CampusInfoCard extends StatefulWidget {
  CampusInfoCard();
  @override
  _CampusInfoCardState createState() => _CampusInfoCardState();
}

class _CampusInfoCardState extends State<CampusInfoCard> {
  String cardId = "campus_info";
  String webCardURL =
      'https://mobile.ucsd.edu/replatform/v1/qa/webview/campus_info-v3.html';

  @override
  Widget build(BuildContext context) {
    return WebViewContainer(
      titleText: CardTitleConstants.titleMap[cardId],
      initialUrl: webCardURL,
      cardId: cardId,
    );
  }
}

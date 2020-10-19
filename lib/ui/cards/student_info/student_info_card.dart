import 'dart:io';

import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/util/webview.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StudentInfoCard extends StatefulWidget {
  StudentInfoCard();
  @override
  _StudentInfoCardState createState() => _StudentInfoCardState();
}

class _StudentInfoCardState extends State<StudentInfoCard> {
  String cardId = "student_info";
  WebViewController _webViewController;
  double _contentHeight = cardContentMinHeight;
  final String webCardURL =
      'https://mobile.ucsd.edu/replatform/v1/qa/webview/student_info.html';

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () {
        _webViewController?.reload();
      },
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget buildCardContent(BuildContext context) {
    return Container(
        height: _contentHeight,
        child: WebView(
          opaque: false,
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: webCardURL,
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          javascriptChannels: <JavascriptChannel>[
            _campusMobileJavascriptChannel(context),
          ].toSet(),
          onPageFinished: (_) {
            _updateContentHeight('');
          },
        ));
  }

  //Channel to obtain links and open them in new browser
  JavascriptChannel _campusMobileJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'CampusMobile',
      onMessageReceived: (JavascriptMessage message) {
        openLink(message.message);
      },
    );
  }

  Future<void> _updateContentHeight(String some) async {
    var newHeight =
        await getNewContentHeight(_webViewController, _contentHeight);
    if (newHeight != _contentHeight) {
      setState(() {
        _contentHeight = newHeight;
      });
    }
  }
}

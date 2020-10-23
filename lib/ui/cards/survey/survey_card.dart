import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/util/webview.dart';
import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SurveyCard extends StatefulWidget {
  SurveyCard();
  @override
  _SurveyCardState createState() => _SurveyCardState();
}

class _SurveyCardState extends State<SurveyCard> {
  String cardId = "student_survey";
  double _contentHeight = cardContentMinHeight;
  WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => null,
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context),
    );
  }

  final _url = "https://eforms.ucsd.edu/view.php?id=537412";

//  final _url =
//      "https://mobile.ucsd.edu/replatform/v1/qa/webview/student_survey.html";

  Widget buildCardContent(BuildContext context) {
    return Container(
      height: _contentHeight + 50,
      child: WebView(
        opaque: false,
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: _url,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        javascriptChannels: <JavascriptChannel>[
          _printJavascriptChannel(context),
        ].toSet(),
        onPageFinished: (_) async {
          await _updateContentHeight('');
        },
      ),
    );
  }

  JavascriptChannel _printJavascriptChannel(BuildContext context) {
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

  openLink(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      //can't launch url, there is some error
    }
  }
}

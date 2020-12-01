import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StaffInfoCard extends StatefulWidget {
  StaffInfoCard();
  @override
  _StaffInfoCardState createState() => _StaffInfoCardState();
}

class _StaffInfoCardState extends State<StaffInfoCard>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  WebViewController _webViewController;
  String cardId = "staff_info";
  double _contentHeight = cardContentMinHeight;
  String webCardURL =
      'https://mobile.ucsd.edu/replatform/v1/qa/webview/staff_info-v3.html';

  @override
  Widget build(BuildContext context) {
    super.build(context);
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

  Widget buildCardContent(context) {
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
          _linksChannel(context),
          _heightChannel(context),
        ].toSet(),
      ),
    );
  }

  JavascriptChannel _linksChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'OpenLink',
      onMessageReceived: (JavascriptMessage message) {
        openLink(message.message);
      },
    );
  }

  JavascriptChannel _heightChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'SetHeight',
      onMessageReceived: (JavascriptMessage message) {
        setState(() {
          _contentHeight =
              validateHeight(context, double.tryParse(message.message));
        });
      },
    );
  }
}

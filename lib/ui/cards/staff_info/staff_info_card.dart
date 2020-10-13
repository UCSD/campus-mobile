import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/util/webview.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StaffInfoCard extends StatefulWidget {
  StaffInfoCard();
  @override
  _StaffInfoCardState createState() => _StaffInfoCardState();
}

class _StaffInfoCardState extends State<StaffInfoCard>
    with WidgetsBindingObserver {
  String cardId = "staff_info";
  WebViewController _webViewController;
  double _contentHeight = cardContentMinHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String webCardURL =
        'https://mobile.ucsd.edu/replatform/v1/qa/webview/staff_info.html';

    reloadWebViewWithTheme(context, webCardURL, _webViewController);

    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () {
        reloadWebViewWithTheme(context, webCardURL, _webViewController);
      },
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context, webCardURL),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget buildCardContent(BuildContext context, String webCardURL) {
    return Container(
        height: _contentHeight,
        child: WebView(
          opaque: false,
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: webCardURL,
          onPageFinished: _updateContentHeight,
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          javascriptChannels: <JavascriptChannel>[
            _campusMobileJavascriptChannel(context),
          ].toSet(),
        ));
  }

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

  openLink(String url) async {
    try {
      launch(url, forceSafariVC: true);
    } catch (e) {
      // an error occurred, do nothing
    }
  }
}

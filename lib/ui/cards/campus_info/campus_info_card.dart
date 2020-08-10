import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CampusInfoCard extends StatefulWidget {
  CampusInfoCard();
  @override
  _CampusInfoCardState createState() => _CampusInfoCardState();
}

class _CampusInfoCardState extends State<CampusInfoCard> {
  String cardId = "campus_info";
  WebViewController _webViewController;
  bool _isDarkMode;
  String _url;

  void initState() {
    super.initState();

    final window = WidgetsBinding.instance.window;
    window.onPlatformBrightnessChanged = () {
      final brightness = window.platformBrightness;
      reloadOnThemeChanged(brightness);
    };
  }



  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () {
        checkTheme(context);
        reloadWebView();
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



   checkTheme(BuildContext context) {
      _url = "https://cwo-test.ucsd.edu/WebCards/campus_info.html";
      if(Theme.of(context).brightness == Brightness.dark) {
        _url += "?darkmode=true";
      }
      else {
        _url += "?darkmode=false";
      }
  }

  Widget buildCardContent(BuildContext context) {
    checkTheme(context);
    return Column(
      children: <Widget>[
        Flexible(
            child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: _url,
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          javascriptChannels: <JavascriptChannel>[
            _printJavascriptChannel(context),
          ].toSet(),
        ))
      ],
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

  openLink(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      //can't launch url, there is some error
    }
  }

  void reloadWebView() {
    checkTheme(context);
    _webViewController?.loadUrl(_url);
  }

  void reloadOnThemeChanged(Brightness brightness) {
    _url = _url.substring(0, _url.indexOf("darkmode")-1);
    _url += "?darkmode=";
    if(brightness == Brightness.dark) {
      _url += "true";
    }
    else {
      _url += "false";
    }
    print(_url);
    _webViewController?.loadUrl(_url);
  }
}

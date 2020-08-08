import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StaffInfoCard extends StatefulWidget {
  StaffInfoCard();
  @override
  _StaffInfoCardState createState() => _StaffInfoCardState();
}

class _StaffInfoCardState extends State<StaffInfoCard> {
  String cardId = "staff_info";
  WebViewController _webViewController;
  bool _isDarkMode;
  String _url;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isDarkMode = false;
  }

  checkTheme(BuildContext context) {
    _url = "https://cwo-test.ucsd.edu/WebCards/staff_info_new.html";
    if (Theme.of(context).brightness == Brightness.dark) {
      _url += "?darkmode=true";
    } else {
      _url += "?darkmode=false";
    }
    print(_url);
  }

  @override
  Widget build(BuildContext context) {
    checkTheme(context);
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

  //String _url = "https://cwo-test.ucsd.edu/WebCards/staff_info_new.html";
  //"file:///Users/mihirgupta/Downloads/staff_info.htm";

  UserDataProvider _userDataProvider;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  Widget buildCardContent(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);

    if (_userDataProvider.isLoggedIn) {
      /// Initialize header
      final Map<String, String> header = {
        'Authorization':
            'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
      };
    }
    var tokenQueryString =
        "token=" + '${_userDataProvider.authenticationModel.accessToken}';
    var url = _url + "?" + tokenQueryString;

    return Column(
      children: <Widget>[
        Flexible(
            child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: url,
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          javascriptChannels: <JavascriptChannel>[
            _printJavascriptChannel(context),
          ].toSet(),
        )),
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
    _webViewController?.reload();
  }
}

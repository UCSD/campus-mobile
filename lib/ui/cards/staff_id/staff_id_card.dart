import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/theme/darkmode_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StaffIdCard extends StatefulWidget {
  StaffIdCard();
  @override
  _StaffIdCardState createState() => _StaffIdCardState();
}

class _StaffIdCardState extends State<StaffIdCard> with WidgetsBindingObserver {
  String cardId = "staff_id";
  WebViewController _webViewController;
  String url;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
        this); // observer for theme change, widget rebuilt on theme change
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () {
        reloadWebViewWithTheme(context, url, _webViewController);
      },
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context),
    );
  }

  String fileURL =
      "https://mobile.ucsd.edu/replatform/v1/qa/webview/staff_id.html";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  UserDataProvider _userDataProvider;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  Widget buildCardContent(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);

    /// Verify that user is logged in
    if (_userDataProvider.isLoggedIn) {
      /// Initialize header
      final Map<String, String> header = {
        'Authorization':
            'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
      };
    }
    var tokenQueryString =
        "token=" + '${_userDataProvider.authenticationModel.accessToken}';
    url = fileURL + "?" + tokenQueryString;

    reloadWebViewWithTheme(context, url, _webViewController);

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
              _myJavascriptChannel(context),
            ].toSet(),
          ),
        ),
      ],
    );
  }

  JavascriptChannel _myJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'CampusMobile',
      onMessageReceived: (JavascriptMessage message) {
        if (message.message == 'refreshToken') {
          _userDataProvider.refreshToken();
          reloadWebView();
        }
      },
    );
  }

  void reloadWebView() {
    _webViewController?.reload();
  }
}

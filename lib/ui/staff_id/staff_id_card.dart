import 'dart:io';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StaffIdCard extends StatefulWidget {
  StaffIdCard();
  @override
  _StaffIdCardState createState() => _StaffIdCardState();
}

class _StaffIdCardState extends State<StaffIdCard> {
  String cardId = "staff_id";
  WebViewController _webViewController;
  double _contentHeight = 194.0;
  final String webCardURL =
      "https://mobile.ucsd.edu/replatform/v1/qa/webview/staff_id-v2.html";

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    String webCardAuthURL = webCardURL +
        "?token=${_userDataProvider.authenticationModel.accessToken}&expiration=${_userDataProvider.authenticationModel.expiration}";

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
      child: () => buildCardContent(context, webCardAuthURL),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  UserDataProvider _userDataProvider;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  Widget buildCardContent(BuildContext context, String webCardAuthURL) {
    return Container(
      height: _contentHeight,
      child: WebView(
        opaque: false,
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: webCardAuthURL,
        // onPageFinished: _updateContentHeight,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        javascriptChannels: <JavascriptChannel>[
          _campusMobileJavascriptChannel(context),
        ].toSet(),
      ),
    );
  }

  JavascriptChannel _campusMobileJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'CampusMobile',
      onMessageReceived: (JavascriptMessage message) async {
        if (message.message == 'refreshToken') {
          if (Provider.of<UserDataProvider>(context, listen: false)
              .isLoggedIn) {
            await _userDataProvider.refreshToken();
            _webViewController?.reload();
          }
        } else if (message.message == 'updateHeight') {
          await _updateContentHeight('');
        }
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

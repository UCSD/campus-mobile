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
  WebViewController _webViewController;
  String cardId = "staff_id";
  double _contentHeight = 194.0;
  String webCardURL =
      "https://mobile.ucsd.edu/replatform/v1/qa/webview/staff_id-v3.html";

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

  Widget buildCardContent(context, webCardAuthURL) {
    return Container(
      height: _contentHeight,
      child: WebView(
        opaque: false,
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: webCardAuthURL,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        javascriptChannels: <JavascriptChannel>[
          _linksChannel(context),
          _heightChannel(context),
          _refreshTokenChannel(context),
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

  JavascriptChannel _refreshTokenChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'RefreshToken',
      onMessageReceived: (JavascriptMessage message) async {
        if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
          await _userDataProvider.silentLogin();
          _webViewController?.reload();
        }
      },
    );
  }
}

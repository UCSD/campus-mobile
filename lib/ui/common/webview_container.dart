import 'dart:io';

import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class WebViewContainer extends StatefulWidget {
  const WebViewContainer({
    Key key,
    @required this.titleText,
    @required this.initialUrl,
    @required this.cardId,
    this.overFlowMenu,
    this.actionButtons,
    this.hideMenu,
  }) : super(key: key);

  /// required parameters
  final String titleText;
  final String initialUrl;
  final String cardId;

  /// optional parameters
  final Map<String, Function> overFlowMenu;
  final bool hideMenu;
  final List<Widget> actionButtons;

  @override
  _CardContainerState createState() => _CardContainerState();
}

class _CardContainerState extends State<WebViewContainer> {
  WebViewController _webViewController;
  double _contentHeight = cardContentMinHeight;
  String webCardUrl;
  bool active;
  Function hide;

  @override
  void initState() {
    super.initState();
    hide = () => Provider.of<CardsDataProvider>(context, listen: false)
        .toggleCard(widget.cardId);
    webCardUrl = widget.initialUrl;
  }

  @override
  Widget build(BuildContext context) {
    active = Provider.of<CardsDataProvider>(context).cardStates[widget.cardId];

    if (active != null && active) {
      return Card(
        margin: EdgeInsets.only(
            top: 0.0, right: 0.0, bottom: cardMargin * 1.5, left: 0.0),
        semanticContainer: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text(
                widget.titleText,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20.0,
                ),
              ),
              trailing: ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildMenu(),
                ],
              ),
            ),
            buildBody(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: widget.actionButtons != null
                  ? Row(
                      children: widget.actionButtons,
                    )
                  : Container(),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget buildBody(context) {
    return Column(
      children: [
        Text(widget.initialUrl),
        Container(
          height: _contentHeight,
          child: WebView(
            opaque: false,
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: webCardUrl,
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            javascriptChannels: <JavascriptChannel>[
              _linksChannel(context),
              _heightChannel(context),
              _refreshTokenChannel(context),
            ].toSet(),
          ),
        ),
      ],
    );
  }

  Widget buildMenu() {
    if (widget.hideMenu ?? false) {
      return null;
    }
    return ButtonBar(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildMenuOptions({
          'reload': _webViewController?.reload,
          'hide': hide,
        }),
      ],
    );
  }

  Widget buildMenuOptions(Map<String, Function> menuOptions) {
    List<DropdownMenuItem<String>> menu = List<DropdownMenuItem<String>>();
    menuOptions.forEach((menuOption, func) {
      Widget item = DropdownMenuItem<String>(
        value: menuOption,
        child: Text(
          menuOption,
          textAlign: TextAlign.center,
        ),
      );
      menu.add(item);
    });
    return DropdownButton(
      items: menu,
      underline: Container(),
      icon: Icon(Icons.more_vert),
      onChanged: (String selectedMenuItem) =>
          onMenuItemPressed(selectedMenuItem),
    );
  }

  void onMenuItemPressed(String selectedMenuItem) {
    switch (selectedMenuItem) {
      case 'reload':
        {
          print("reloading ${widget.titleText}");
          _webViewController?.reload();
        }
        break;
      case 'hide':
        {
          hide();
        }
        break;
      default:
        {
          // do nothing for now
        }
    }
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
          await Provider.of<UserDataProvider>(context, listen: false)
              .refreshToken();

          String token = Provider.of<UserDataProvider>(context, listen: false).authenticationModel.accessToken;
          int expire = Provider.of<UserDataProvider>(context, listen: false).authenticationModel.expiration;

          webCardUrl = widget.initialUrl + "?token=$token&expiration=$expire";

          print(webCardUrl);
          _webViewController?.reload();
        }
      },
    );
  }
}

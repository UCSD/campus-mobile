import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/home/home.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  const WebViewContainer({
    Key? key,
    required this.titleText,
    required this.initialUrl,
    required this.cardId,
    required this.requireAuth,
    this.overFlowMenu,
    this.actionButtons,
    this.hideMenu = false,
  }) : super(key: key);

  /// required parameters
  final String titleText;
  final String initialUrl;
  final String cardId;
  final bool requireAuth;

  /// optional parameters
  final Map<String, Function>? overFlowMenu;
  final bool hideMenu;
  final List<Widget>? actionButtons;

  @override
  _WebViewContainerState createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer>
    with AutomaticKeepAliveClientMixin {
  /// STATES
  bool active = false;
  double _contentHeight = cardContentMinHeight;
  late Function hide;
  late String webCardUrl;

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

  /// SERVICES
  // WebViewController? _webViewController;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    hide = () => Provider.of<CardsDataProvider>(context, listen: false)
        .toggleCard(widget.cardId);
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //open link
      ..addJavaScriptChannel(
        'OpenLink',
        onMessageReceived: (JavaScriptMessage m) {
          openLink(m.message);
        },
      )
      //set height
      ..addJavaScriptChannel(
        'SetHeight',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            _contentHeight =
                validateHeight(context, double.tryParse(message.message));
          });
        },
      )
      // channel for performing a map search based on given query
      ..addJavaScriptChannel(
        'MapSearch',
        onMessageReceived: (JavaScriptMessage message) {
          // navigate to map and search with message.message
          Provider.of<MapsDataProvider>(context, listen: false)
              .searchBarController
              .text = message.message;
          Provider.of<MapsDataProvider>(context, listen: false)
              .fetchLocations();
          Provider.of<BottomNavigationBarProvider>(context, listen: false)
              .currentIndex = NavigatorConstants.MapTab;
          Provider.of<CustomAppBar>(context, listen: false).changeTitle("Maps");
          // Navigator.pushNamed(context, RoutePaths.Map);
        },
      )
      //refresh token
      ..addJavaScriptChannel(
        'RefreshToken',
        onMessageReceived: (JavaScriptMessage message) async {
          if (!Provider.of<UserDataProvider>(context, listen: false)
              .isLoggedIn) {
            if (await _userDataProvider.silentLogin()) {
              _webViewController.reload();
            }
          }
        },
      )
      // javascript channel for redirecting the user to a new webcard URL
      ..addJavaScriptChannel(
        'Redirect',
        onMessageReceived: (JavaScriptMessage message) async {
          webCardUrl = message.message;
          _webViewController.loadRequest(Uri.parse(webCardUrl));
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    active = Provider.of<CardsDataProvider>(context).cardStates[widget.cardId]!;

    // check if this webCard needs an auth token
    if (widget.requireAuth) {
      _userDataProvider = Provider.of<UserDataProvider>(context);
      webCardUrl = widget.initialUrl +
          "?expiration=${_userDataProvider.authenticationModel.expiration}#${_userDataProvider.authenticationModel.accessToken}";
    } else {
      webCardUrl = widget.initialUrl;
    }

    checkWebURL();

    if (active) {
      return Card(
        margin: EdgeInsets.only(
            top: 0.0, right: 0.0, bottom: cardMargin * 1.5, left: 0.0),
        elevation: 4,
        shadowColor: Colors.black,
        semanticContainer: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: dotsUnselectedColor,
            width: 0.5,
          ),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? darkPrimaryBgColor
            : lightAccentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.only(
                  top: 0.0, right: 6.0, bottom: 0.0, left: 12.0),
              visualDensity: VisualDensity(horizontal: 0, vertical: 0),
              title: Text(
                widget.titleText,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              trailing: buildMenu(),
            ),
            buildBody(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: widget.actionButtons != null
                  ? Row(children: widget.actionButtons!)
                  : Container(),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  // builds the actual webview widget
  Widget buildBody(context) {
    print('webview_container:buildBody: ' + webCardUrl);

    _webViewController.loadRequest(Uri.parse(webCardUrl));
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(12.0),
        bottomRight: Radius.circular(12.0),
      ),
      child: SizedBox(
        height: _contentHeight,
        child: WebViewWidget(controller: _webViewController),
      ),
      // child: Container(
      //   height: _contentHeight,
      //   child: WebView(
      //     javaScriptMode: JavaScriptMode.unrestricted,
      //     initialUrl: webCardUrl,
      //     onWebViewCreated: (controller) {
      //       _webViewController = controller;
      //     },
      //     navigationDelegate: null,
      //     javascriptChannels: <JavascriptChannel>[
      //       _linksChannel(context),
      //       _heightChannel(context),
      //       _mapChannel(context),
      //       _refreshTokenChannel(context),
      //       _permanentRedirect(context)
      //     ].toSet(),
      //   ),
      // ),
    );
  }

  Widget buildMenu() {
    if (widget.hideMenu) return Container();
    return ButtonBar(
      buttonPadding: EdgeInsets.all(0),
      mainAxisSize: MainAxisSize.min,
      children: [
        buildMenuOptions({
          CardMenuOptionConstants.reloadCard: _webViewController?.reload,
          CardMenuOptionConstants.hideCard: hide,
        }),
      ],
    );
  }

  Widget buildMenuOptions(Map<String, Function?> menuOptions) {
    List<DropdownMenuItem<String>> menu = [];
    menuOptions.forEach((menuOption, func) {
      Widget item = DropdownMenuItem<String>(
        value: menuOption,
        child: Text(
          menuOption,
          textAlign: TextAlign.center,
          style: TextStyle(color: dotsUnselectedColor),
        ),
      );
      menu.add(item as DropdownMenuItem<String>);
    });
    return DropdownButton(
      items: menu,
      iconSize: 36,
      iconEnabledColor: dotsUnselectedColor,
      underline: Container(),
      icon: Transform.translate(
        offset: Offset(6, -3),
        child: Icon(Icons.more_vert, color: dotsUnselectedColor),
      ),
      onChanged: (String? selectedMenuItem) =>
          onMenuItemPressed(selectedMenuItem),
    );
  }

  void onMenuItemPressed(String? selectedMenuItem) {
    switch (selectedMenuItem) {
      case CardMenuOptionConstants.reloadCard:
        // _webViewController?.loadUrl(webCardUrl);
        _webViewController.loadRequest(Uri.parse(webCardUrl));
        resetCardHeight(widget.cardId);
        break;
      case CardMenuOptionConstants.hideCard:
        hide();
        resetCardHeight(widget.cardId);
        break;
      default:
      // do nothing for now
    }
  }

  // channel for opening links
  // JavascriptChannel _linksChannel(BuildContext context) {
  //   return JavascriptChannel(
  //     name: 'OpenLink',
  //     onMessageReceived: (JavaScriptMessage message) {
  //       openLink(message.message);
  //     },
  //   );
  // }

  // channel for dynamically setting the height of the card
  // JavascriptChannel _heightChannel(BuildContext context) {
  //   return JavascriptChannel(
  //     name: 'SetHeight',
  //     onMessageReceived: (JavaScriptMessage message) {
  //       setState(() {
  //         _contentHeight =
  //             validateHeight(context, double.tryParse(message.message));
  //       });
  //     },
  //   );
  // }

  // channel for performing a map search based on given query
  // JavascriptChannel _mapChannel(BuildContext context) {
  //   return JavascriptChannel(
  //     name: 'MapSearch',
  //     onMessageReceived: (JavaScriptMessage message) {
  //       // navigate to map and search with message.message
  //       Provider.of<MapsDataProvider>(context, listen: false)
  //           .searchBarController
  //           .text = message.message;
  //       Provider.of<MapsDataProvider>(context, listen: false).fetchLocations();
  //       Provider.of<BottomNavigationBarProvider>(context, listen: false)
  //           .currentIndex = NavigatorConstants.MapTab;
  //       Provider.of<CustomAppBar>(context, listen: false).changeTitle("Maps");
  //       // Navigator.pushNamed(context, RoutePaths.Map);
  //     },
  //   );
  // }

  // JavascriptChannel _refreshTokenChannel(BuildContext context) {
  //   return JavascriptChannel(
  //     name: 'RefreshToken',
  //     onMessageReceived: (JavaScriptMessage message) async {
  //       if (!Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
  //         if (await _userDataProvider.silentLogin()) {
  //           _webViewController?.reload();
  //         }
  //       }
  //     },
  //   );
  // }

  // // javascript channel for redirecting the user to a new webcard URL
  // JavascriptChannel _permanentRedirect(BuildContext context) {
  //   return JavascriptChannel(
  //     name: 'Redirect',
  //     onMessageReceived: (JavaScriptMessage message) async {
  //       webCardUrl = message.message;
  //       _webViewController!.loadUrl(message.message);
  //     },
  //   );
  // }

  // this function checks to see if the current url of the state is different
  // to the webViewController's url, and loads in the new url if so
  void checkWebURL() async {
    String? currentUrl = await _webViewController.currentUrl();
    if (_webViewController != null && webCardUrl != currentUrl) {
      // _webViewController?.loadUrl(webCardUrl);
      _webViewController.loadRequest(Uri.parse(webCardUrl));
    }
  }

  /// SIMPLE GETTERS
  bool get wantKeepAlive => true;
}

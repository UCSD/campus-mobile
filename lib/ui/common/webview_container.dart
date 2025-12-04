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
import 'dart:async';

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
    this.isLoaded = true,
    this.onPageFinished,
    this.onWidgetSizeChange,
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
  final bool isLoaded;
  final VoidCallback? onPageFinished;
  final Function(Size)? onWidgetSizeChange;

  @override
  _WebViewContainerState createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> with AutomaticKeepAliveClientMixin {
  /// STATES
  bool active = false;
  double _contentHeight = cardContentMinHeight;
  late Function hide;
  late String webCardUrl;
  String? _lastLoadedUrl;

  /// PERFORMANCE OPTIMIZATION TIMERS
  Timer? _heightUpdateTimer;
  Timer? _mapSearchTimer;

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

  /// SERVICES
  // WebViewController? _webViewController;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    hide = () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(widget.cardId);
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // open link
      ..addJavaScriptChannel(
        'OpenLink',
        onMessageReceived: (JavaScriptMessage m) {
          openLink(m.message);
        },
      )
      // set height (with debouncing for performance)
      ..addJavaScriptChannel(
        'SetHeight',
        onMessageReceived: (JavaScriptMessage message) {
          // Cancel any existing timer to avoid multiple rapid updates
          _heightUpdateTimer?.cancel();

          // Wait 16ms (one frame at 60fps) before updating to batch rapid changes
          _heightUpdateTimer = Timer(Duration(milliseconds: 16), () {
            if (mounted) {
              // Check if widget is still mounted
              final newHeight = double.tryParse(message.message);
              if (newHeight != null && newHeight > 0) {
                final validatedHeight = validateHeight(context, newHeight);
                print('WebView height: requested=${newHeight.toInt()}px, validated=${validatedHeight.toInt()}px');
                setState(() {
                  _contentHeight = validatedHeight;
                  if (widget.onWidgetSizeChange != null)
                    widget.onWidgetSizeChange!(Size(MediaQuery.of(context).size.width, _contentHeight));
                });
              }
            }
          });
        },
      )
      // channel for performing a map search based on given query (with debouncing)
      ..addJavaScriptChannel(
        'MapSearch',
        onMessageReceived: (JavaScriptMessage message) {
          // Cancel any existing timer to avoid multiple rapid searches
          _mapSearchTimer?.cancel();

          // Wait 300ms before executing search to avoid excessive API calls
          _mapSearchTimer = Timer(Duration(milliseconds: 300), () {
            if (mounted) {
              // Check if widget is still mounted
              // Perform heavy operations asynchronously to avoid blocking UI
              Future.microtask(() {
                final mapsProvider = Provider.of<MapsDataProvider>(context, listen: false);
                final navProvider = Provider.of<BottomNavigationBarProvider>(context, listen: false);
                final appBarProvider = Provider.of<CustomAppBar>(context, listen: false);

                mapsProvider.searchBarController.text = message.message;
                mapsProvider.fetchLocations();
                navProvider.currentIndex = NavigatorConstants.MapTab;
                appBarProvider.changeTitle("Maps");
              });
            }
          });
        },
      )
      // refresh token
      ..addJavaScriptChannel(
        'RefreshToken',
        onMessageReceived: (JavaScriptMessage message) async {
          if (!Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) if (await _userDataProvider
              .silentLogin()) _webViewController.reload();
        },
      )
      // javascript channel for redirecting the user to a new webcard URL
      ..addJavaScriptChannel(
        'Redirect',
        onMessageReceived: (JavaScriptMessage message) async {
          webCardUrl = message.message;
          _webViewController.loadRequest(Uri.parse(webCardUrl));
        },
      )
      // navigation delegate for page finished
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (widget.onPageFinished != null) widget.onPageFinished!();
          },
        ),
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
        margin: EdgeInsets.only(top: 0.0, right: 0.0, bottom: cardMargin * 1.5, left: 0.0),
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
        color: Theme.of(context).brightness == Brightness.dark ? darkPrimaryBgColor : lightAccentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.only(top: 0.0, right: 6.0, bottom: 0.0, left: 12.0),
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
              child: widget.actionButtons != null ? Row(children: widget.actionButtons!) : Container(),
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
    if (_lastLoadedUrl != webCardUrl) {
      _webViewController.loadRequest(Uri.parse(webCardUrl));
      _lastLoadedUrl = webCardUrl;
    }
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(12.0),
        bottomRight: Radius.circular(12.0),
      ),
      child: SizedBox(
        height: _contentHeight,
        child: WebViewWidget(
          controller: _webViewController,
        ),
      ),
    );
  }

  Widget buildMenu() {
    if (widget.hideMenu) return Container();
    return ButtonBar(
      buttonPadding: EdgeInsets.all(0),
      mainAxisSize: MainAxisSize.min,
      children: [
        buildMenuOptions({
          CardMenuOptionConstants.reloadCard: _webViewController.reload,
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
      onChanged: (String? selectedMenuItem) => onMenuItemPressed(selectedMenuItem),
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

  // this function checks to see if the current url of the state is different
  // to the webViewController's url, and loads in the new url if so
  void checkWebURL() async {
    String? currentUrl = await _webViewController.currentUrl();
    if (webCardUrl != currentUrl) _webViewController.loadRequest(Uri.parse(webCardUrl));
  }

  @override
  void dispose() {
    // Cancel any pending timers to prevent memory leaks
    _heightUpdateTimer?.cancel();
    _mapSearchTimer?.cancel();
    super.dispose();
  }

  /// SIMPLE GETTERS
  bool get wantKeepAlive => true;
}

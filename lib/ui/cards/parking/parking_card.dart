import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/core/util/webview.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ParkingCard extends StatefulWidget {
  @override
  _ParkingCardState createState() => _ParkingCardState();
}

class _ParkingCardState extends State<ParkingCard> {
  String cardId = 'parking';
  WebViewController _webViewController;
  ParkingDataProvider _parkingDataProvider;
  final _controller = new PageController();
  // double _contentHeight = cardContentMinHeight;
  final String webCardURL =
      "https://mobile.ucsd.edu/replatform/v1/qa/webview/parking/index.html";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingDataProvider = Provider.of<ParkingDataProvider>(context);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    String webCardURLWithTheme = getThemeURL(context, webCardURL);
    reloadWebView(webCardURLWithTheme, _webViewController);

    return CardContainer(
      titleText: CardTitleConstants.titleMap[cardId],
      isLoading: _parkingDataProvider.isLoading,
      reload: () => {_parkingDataProvider.fetchParkingData()},
      errorText: _parkingDataProvider.error,
      child: () => buildParkingCard(context, webCardURLWithTheme),
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildParkingCard(BuildContext context, webCardURLWithTheme) {
    List<WebView> selectedLotsViews = [];
    List<String> selectedSpots = [];

    _parkingDataProvider.spotTypesState.forEach((key, value) {
      if (value) {
        selectedSpots.add(key);
      }
    });

    for (ParkingModel model in _parkingDataProvider.parkingModels) {
      if (model != null) {
        if (_parkingDataProvider.parkingViewState[model.locationName]) {
          final url =
              makeUrl(webCardURLWithTheme, model.locationId, selectedSpots);

          selectedLotsViews.add(WebView(
            opaque: false,
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onPageStarted: (String url) {
              print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              print('Page finished loading: $url');
            },
          ));
        }
      }
    }

    return Column(
      children: <Widget>[
        Flexible(
            child: PageView(
          controller: _controller,
          children: selectedLotsViews,
        )),
        DotsIndicator(
          controller: _controller,
          itemCount: selectedLotsViews.length,
          onPageSelected: (int index) {},
        ),
      ],
    );
  }

  // Future<void> _updateContentHeight(String some) async {
  //   var newHeight =
  //       await getNewContentHeight(_webViewController, _contentHeight);
  //   if (newHeight != _contentHeight) {
  //     setState(() {
  //       _contentHeight = newHeight;
  //     });
  //   }
  // }

  String makeUrl(
      String webCardURLWithTheme, String lotId, List<String> selectedSpots) {
    var spotTypesQueryString = '';
    selectedSpots.forEach(
        (spot) => {spotTypesQueryString = '$spotTypesQueryString$spot,'});
    if (spotTypesQueryString != '') {
      spotTypesQueryString = '&spots=$spotTypesQueryString';
    }
    var lotQueryString = 'lot=$lotId';
    var url = '$webCardURL?$lotQueryString$spotTypesQueryString';

    return url;
  }

  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'Manage Lots',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.ManageParkingView);
      },
    ));
    actionButtons.add(FlatButton(
      child: Text(
        'Manage Spots',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.SpotTypesView);
      },
    ));
    return actionButtons;
  }
}

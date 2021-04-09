import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ParkingCard extends StatefulWidget {
  @override
  _ParkingCardState createState() => _ParkingCardState();
}

class _ParkingCardState extends State<ParkingCard>
    with AutomaticKeepAliveClientMixin {
  ParkingDataProvider _parkingDataProvider;
  bool get wantKeepAlive => true;
  final _controller = new PageController();
  WebViewController _webViewController;
  String cardId = 'parking';
  String webCardURL =
      "https://mobile.ucsd.edu/replatform/v1/qa/webview/parking-v2/index.html";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingDataProvider = Provider.of<ParkingDataProvider>(context);
  }

  // ignore: must_call_super
  Widget build(BuildContext context) {
    //super.build(context);
    return CardContainer(
      titleText: CardTitleConstants.titleMap[cardId],
      isLoading: _parkingDataProvider.isLoading,
      reload: () => {_parkingDataProvider.fetchParkingData()},
      errorText: _parkingDataProvider.error,
      child: () => buildParkingCard(context),
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildParkingCard(BuildContext context) {
    try {
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
            final url = makeUrl(model.locationId, selectedSpots);

            selectedLotsViews.add(WebView(
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) {
                _webViewController = controller;
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
    } catch (e) {
      return Container(
        width: double.infinity,
        child: Center(
          child: Container(
            child: Text('An error occurred, please try again.'),
          ),
        ),
      );
    }
  }

  String makeUrl(String lotId, List<String> selectedSpots) {
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
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      child: Text(
        'Manage Lots',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.ManageParkingView);
      },
    ));
    actionButtons.add(TextButton(
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

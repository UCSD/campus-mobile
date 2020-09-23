import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String cardId = 'parking';
const _url = "https://mobile.ucsd.edu/replatform/v1/qa/webview/parking/";

class ParkingCard extends StatefulWidget {
  @override
  _ParkingCardState createState() => _ParkingCardState();
}

class _ParkingCardState extends State<ParkingCard> {
  ParkingDataProvider _parkingDataProvider;
  final _controller = new PageController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingDataProvider = Provider.of<ParkingDataProvider>(context);
  }

  Widget build(BuildContext context) {
    return CardContainer(
      titleText: CardTitleConstants.titleMap[cardId],
      isLoading: _parkingDataProvider.isLoading,
      reload: () => {_parkingDataProvider.fetchParkingData()},
      errorText: _parkingDataProvider.error,
      child: () => buildParkingCard(),
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildParkingCard() {
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
            onWebViewCreated: (controller) {},
            onPageFinished: (some) async {},
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
          onPageSelected: (int index) {
          },
        ),
      ],
    );
  }

  String makeUrl(String lotId, List<String> selectedSpots) {
    var spotTypesQueryString = '';

    selectedSpots.forEach(
        (spot) => {spotTypesQueryString = '$spotTypesQueryString$spot,'});

    if (spotTypesQueryString != '')
      spotTypesQueryString = '&spots=$spotTypesQueryString';

    var lotQueryString = 'lot=$lotId';

    var url = '$_url?$lotQueryString$spotTypesQueryString';

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

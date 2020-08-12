import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/ui/cards/parking/parking_display.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
// import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String cardId = 'parking';

class ParkingCard extends StatefulWidget {
  ParkingCard();
  @override
  _ParkingCardState createState() => _ParkingCardState();
}

class _ParkingCardState extends State<ParkingCard> {
  _ParkingCardState();
  ParkingDataProvider _parkingDataProvider;
  // final _controller = new PageController();
  WebViewController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    _parkingDataProvider = Provider.of<ParkingDataProvider>(context);
    return CardContainer(
      titleText: CardTitleConstants.titleMap[cardId],
      isLoading: _parkingDataProvider.isLoading,
      reload: () => _parkingDataProvider.fetchParkingLots(),
      errorText: _parkingDataProvider.error,
      child: () => buildParkingCard(_parkingDataProvider.parkingModels,
          _parkingDataProvider.spotTypesState),
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildParkingCard(ParkingDataProvider, Map<String, bool> spots) {
    List<Widget> parkingDisplays = List<Widget>();

    for (ParkingModel model in _parkingDataProvider.parkingModels) {
      if (model != null) {
        if (_parkingDataProvider.parkingViewState[model.locationName]) {
          parkingDisplays.add(ParkingDisplay(
            model: model,
            spotsState: spots,
          ));
        }
      }
    }
    final _url =
        "https://cqeg04fl07.execute-api.us-west-2.amazonaws.com/parking";

    return WebView(
      initialUrl: _url,
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
      },
    );

    //   return Column(
    //     children: <Widget>[
    //       Flexible(
    //           child: PageView(
    //         controller: _controller,
    //         children: parkingDisplays,
    //       )),
    //       DotsIndicator(
    //         controller: _controller,
    //         itemCount: parkingDisplays.length,
    //         onPageSelected: (int index) {
    //           _controller.animateToPage(index,
    //               duration: Duration(seconds: 1), curve: Curves.ease);
    //         },
    //       ),
    //     ],
    //   );
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

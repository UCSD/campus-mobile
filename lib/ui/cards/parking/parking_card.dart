import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/ui/cards/parking/parking_display.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      titleText: "Parking",
      isLoading: _parkingDataProvider.isLoading,
      reload: () => _parkingDataProvider.fetchParkingLots(),
      errorText: _parkingDataProvider.error,
      child: () => buildParkingCard(_parkingDataProvider.parkingModels),
      active: Provider.of<CardsDataProvider>(context).cardStates['parking'],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard('parking'),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildParkingCard(List<ParkingModel> data) {
    List<Widget> parkingDisplays = List<Widget>();
    for (ParkingModel model in data) {
      if (model != null) {
        parkingDisplays.add(ParkingDisplay(model: model));
      }
    }

    return Column(
      children: <Widget>[
        Flexible(
          child: PageView(
            controller: _controller,
            children: parkingDisplays,
          ),
        ),
        DotsIndicator(
          controller: _controller,
          itemCount: parkingDisplays.length,
          onPageSelected: (int index) {
            _controller.animateToPage(index,
                duration: Duration(seconds: 1), curve: Curves.ease);
          },
        ),
      ],
    );
  }

  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.ManageParkingView);
      },
    ));
    return actionButtons;
  }
}

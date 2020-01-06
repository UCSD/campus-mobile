import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/ui/widgets/parking/parking_display.dart';
import 'package:campus_mobile_experimental/ui/widgets/dots_indicator.dart';
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
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _parkingDataProvider = Provider.of<ParkingDataProvider>(context);
  }

  Widget build(BuildContext context) {
    return CardContainer(
      title: Text("Parking"),
      isLoading: _parkingDataProvider.isLoading,
      reload: () => _updateData(),
      errorText: _parkingDataProvider.error,
      child: buildParkingCard(_parkingDataProvider.parkingModels),
      hidden: false,
      overFlowMenu: {'print hi': () => print('hi')},
      actionButtons: buildActionButtons(),
    );
  }

  void _updateData() {
    if (!_parkingDataProvider.isLoading) {
      _parkingDataProvider.fetchParkingLots();
    }
  }

  Widget buildParkingCard(List<DiningModel> data) {
    if (data != null && data.length > 0) {
      List<Widget> parkingDisplays = List<Widget>();
      for (DiningModel model in data) {
        parkingDisplays.add(ParkingDisplay(model: model));
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
    } else {
      return Container();
    }
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

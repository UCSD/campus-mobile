import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/services/parking_service.dart';
import 'package:campus_mobile_experimental/ui/widgets/parking/parking_display.dart';
import 'package:campus_mobile_experimental/ui/widgets/dots_indicator.dart';
import 'package:provider/provider.dart';

class ParkingCard extends StatefulWidget {
  @override
  _ParkingCardState createState() => _ParkingCardState();
}

class _ParkingCardState extends State<ParkingCard> {
  ParkingService _parkingService;
  final _controller = new PageController();

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _parkingService = Provider.of<ParkingService>(context);
  }

  Widget build(BuildContext context) {
    return CardContainer(
      title: Text("Parking"),
      isLoading: false,
      reload: () => _updateData(),
      errorText: _parkingService.error,
      child: buildParkingCard(_parkingService.data),
      hidden: false,
      overFlowMenu: {'print hi': () => print('hi')},
      actionButtons: buildActionButtons(),
    );
  }

  void _updateData() {
    if (!_parkingService.isLoading) {
      _parkingService.fetchData();
    }
  }

  Widget buildParkingCard(List<ParkingModel> data) {
    if (data != null && data.length > 0) {
      List<Widget> parkingDisplays = List<Widget>();
      for (ParkingModel model in data) {
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

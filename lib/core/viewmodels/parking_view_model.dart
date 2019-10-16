import 'package:campus_mobile/core/models/parking_model.dart';
import 'package:campus_mobile/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile/core/constants/app_constants.dart';
import 'package:campus_mobile/core/services/parking_service.dart';
import 'package:campus_mobile/ui/widgets/parking/parking_display.dart';
import 'package:campus_mobile/ui/widgets/dots_indicator.dart';

class ParkingCard extends StatefulWidget {
  @override
  _ParkingCardState createState() => _ParkingCardState();
}

class _ParkingCardState extends State<ParkingCard> {
  final ParkingService _parkingService = ParkingService();
  Future<List<ParkingModel>> _data;
  final _controller = new PageController();
  Widget build(BuildContext context) {
    return FutureBuilder<List<ParkingModel>>(
      future: _data,
      builder: (context, snapshot) {
        return CardContainer(
          title: Text("Parking"),
          isLoading: false,
          reload: () => _updateData(),
          errorText: null,
          child: buildParkingCard(snapshot),
          hidden: false,
          overFlowMenu: {'print hi': () => print('hi')},
          actionButtons: buildActionButtons(),
        );
      },
    );
  }

  void _updateData() {
    if (!_parkingService.isLoading) {
      setState(() {
        _data = _parkingService.fetchData();
      });
    }
  }

  Widget buildParkingCard(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      List<Widget> parkingDisplays = List<Widget>();
      for (ParkingModel model in snapshot.data) {
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

  initState() {
    super.initState();
    _updateData();
  }

  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.BaseLineView);
      },
    ));
    return actionButtons;
  }
}

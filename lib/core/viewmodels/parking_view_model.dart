import 'package:campus_mobile/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile/core/constants/app_constants.dart';

class ParkingCard extends StatefulWidget {
  @override
  _ParkingCardState createState() => _ParkingCardState();
}

class _ParkingCardState extends State<ParkingCard> {
  Widget build(BuildContext context) {
    return CardContainer(
      title: Text("Parking"),
      isLoading: false,
      reload: () => print("reloading"),
      errorText: null,
      child: Text('hello world'),
      hidden: false,
      overFlowMenu: {'print hi': () => print('hi')},
      actionButtons: buildActionButtons(),
    );
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

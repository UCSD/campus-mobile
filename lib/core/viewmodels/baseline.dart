import 'package:campus_mobile/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile/core/constants/app_constants.dart';

class BaselineCard extends StatefulWidget {
  @override
  _BaselineCardState createState() => _BaselineCardState();
}

class _BaselineCardState extends State<BaselineCard> {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      title: Text('Baseline Card Title'),
      isLoading: false,
      reload: () => print('reloading'),
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

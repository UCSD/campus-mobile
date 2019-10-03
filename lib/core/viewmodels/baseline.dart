import 'package:campus_mobile/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';

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
    );
  }
}

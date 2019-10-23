import 'package:campus_mobile_beta/core/models/dining_model.dart';
import 'package:campus_mobile_beta/core/services/dining_service.dart';
import 'package:campus_mobile_beta/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/core/constants/app_constants.dart';
import 'package:campus_mobile_beta/ui/views/dining/dining_list.dart';

class DiningCard extends StatefulWidget {
  @override
  _DiningState createState() => _DiningState();
}

class _DiningState extends State<DiningCard> {
  final DiningService _diningService = DiningService();
  Future<List<DiningModel>> _data;

  initState() {
    super.initState();
    _updateData();
  }

  _updateData() {
    if (!_diningService.isLoading) {
      setState(() {
        _data = _diningService.fetchData();
      });
    }
  }

  Widget buildNewsCard(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return DiningList(
        data: snapshot.data,
        listSize: 3,
      );
    } else {
      return Container();
    }
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.start,
    );
  }

  List<Widget> buildActionButtons(List<DiningModel> data) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.DiningViewAll, arguments: data);
      },
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiningModel>>(
      future: _data,
      builder: (context, snapshot) {
        return CardContainer(
          /// TODO: need to hook up hidden to state using provider
          hidden: false,
          reload: () => _updateData(),
          isLoading: _diningService.isLoading,
          title: buildTitle("Dining"),
          errorText: _diningService.error,
          child: buildNewsCard(snapshot),
          actionButtons: buildActionButtons(snapshot.data),
        );
      },
    );
  }
}

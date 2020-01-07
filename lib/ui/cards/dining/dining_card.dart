import 'package:campus_mobile_experimental/core/data_providers/dining_data_proivder.dart';
import 'package:campus_mobile_experimental/core/models/dining_model.dart';
import 'package:campus_mobile_experimental/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/cards/dining/dining_list.dart';

class DiningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      hidden: false,
      reload: () => Provider.of<DiningDataProvider>(context, listen: false)
          .fetchDiningLocations(),
      isLoading:
          Provider.of<DiningDataProvider>(context, listen: true).isLoading,
      title: buildTitle("Dining"),
      errorText: Provider.of<DiningDataProvider>(context, listen: true).error,
      child: buildDiningCard(
          Provider.of<DiningDataProvider>(context, listen: true).diningModels),
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildDiningCard(List<DiningModel> data) {
    if (data.length > 0) {
      return DiningList(
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

  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.DiningViewAll);
      },
    ));
    return actionButtons;
  }
}

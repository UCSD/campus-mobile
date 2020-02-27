import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/links_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/views/links/links_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LinksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      titleText: 'Links',
      isLoading: Provider.of<LinksDataProvider>(context).isLoading,
      reload: () =>
          Provider.of<LinksDataProvider>(context, listen: false).fetchLinks(),
      errorText: Provider.of<LinksDataProvider>(context).error,
      child: () => buildLinksCard(),
      active: Provider.of<UserDataProvider>(context).cardStates['links'],
      hide: () => Provider.of<UserDataProvider>(context).toggleCard('links'),
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildLinksCard() {
    return LinksList(
      listSize: 4,
    );
  }

  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.LinksViewAll);
      },
    ));
    return actionButtons;
  }
}

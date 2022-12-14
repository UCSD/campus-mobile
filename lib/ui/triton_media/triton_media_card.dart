import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/triton_media.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/triton_media/triton_media_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'events';
//edit these files
class MediaCard extends StatelessWidget {
  Widget buildEventsCard(List<MediaModel>? data) {
    return MediaList(listSize: 3);
  }

  List<Widget> buildActionButtons(
      BuildContext context, List<MediaModel>? data) {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        primary: Theme.of(context).buttonColor,
      ),
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.MediaViewAll, arguments: data);
      },
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () =>
          Provider.of<MediaDataProvider>(context, listen: false).fetchEvents(),
      isLoading: Provider.of<MediaDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: Provider.of<MediaDataProvider>(context).error,
      child: () => buildEventsCard(
          Provider.of<MediaDataProvider>(context).eventsModels),
      actionButtons: buildActionButtons(
          context, Provider.of<MediaDataProvider>(context).eventsModels),
    );
  }
}

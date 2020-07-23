import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/news_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/views/news/news_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'news';

class NewsCard extends StatelessWidget {
  Widget buildNewsCard() {
    return NewsList(
      listSize: 3,
    );
  }

  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.NewsViewAll);
      },
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      /// TODO: need to hook up hidden to state using provider
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () =>
          Provider.of<NewsDataProvider>(context, listen: false).fetchNews(),
      isLoading: Provider.of<NewsDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: Provider.of<NewsDataProvider>(context).error,
      child: () => buildNewsCard(),
      actionButtons: buildActionButtons(context),
    );
  }
}

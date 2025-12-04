import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/news.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/news/news_list.dart';
import 'package:campus_mobile_experimental/ui/common/action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const cardId = 'news';

class NewsCard extends StatelessWidget {
  Widget buildNewsCard() {
    try {
      return NewsList(listSize: 3);
    } catch (e) {
      print(e);
      return Container(
        width: double.infinity,
        child: Center(
          child: Container(
            child: Text('An error occurred, please try again.'),
          ),
        ),
      );
    }
  }

  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = [];
    actionButtons.add(ActionButton(
        buttonText: 'VIEW MORE NEWS STORIES', onPressed: () => Navigator.pushNamed(context, RoutePaths.NewsViewAll)));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      // TODO: need to hook up hidden to state using provider - December 2025
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
      reload: () => Provider.of<NewsDataProvider>(context, listen: false).fetchNews(),
      isLoading: Provider.of<NewsDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId]!,
      errorText: Provider.of<NewsDataProvider>(context).error,
      child: () => buildNewsCard(),
      actionButtons: buildActionButtons(context),
    );
  }
}

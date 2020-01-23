import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/views/news/news_list.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/news_data_provider.dart';

class NewsCard extends StatelessWidget {
  Widget buildNewsCard() {
    return NewsList(
      listSize: 3,
    );
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
        Navigator.pushNamed(context, RoutePaths.NewsViewAll);
      },
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      /// TODO: need to hook up hidden to state using provider
      active: Provider.of<UserDataProvider>(context).cardStates['news'],
      hide: () => Provider.of<UserDataProvider>(context).toggleCard('news'),
      reload: () =>
          Provider.of<NewsDataProvider>(context, listen: false).fetchNews(),
      isLoading: Provider.of<NewsDataProvider>(context).isLoading,
      title: buildTitle("News"),
      errorText: Provider.of<NewsDataProvider>(context).error,
      child: () => buildNewsCard(),
      actionButtons: buildActionButtons(context),
    );
  }
}

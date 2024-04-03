import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/news_getx.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/news/news_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

const String cardId = 'news';

class NewsCard extends StatelessWidget {
  /// Fill the News Card with the fetched news data (from NewsGetX)
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

  /// Create the `View All` button on the News Card
  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        foregroundColor: Theme.of(context).backgroundColor,
      ),
      child: Text(
        'View All',
      ),
      onPressed: () {
        Get.toNamed(RoutePaths.NewsViewAll);
      },
    ));
    return actionButtons;
  }

  /// Create the News Card
  @override
  Widget build(BuildContext context) {
    // Initialize the NewsGetX controller and have it fetch data
    NewsGetX newsController = Get.put(NewsGetX());

    // Return a CardContainer, wrapped in an Obx() widget, which allows CardContainer to listen to observable variables from NewsGetX
    return Obx(() => CardContainer(
          /// TODO: need to hook up hidden to state using provider
          active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
          hide: () => Provider.of<CardsDataProvider>(context, listen: false)
              .toggleCard(cardId),
          reload: () => newsController.fetchNews(),
          isLoading: newsController.isLoading,
          titleText: CardTitleConstants.titleMap[cardId],
          errorText: newsController.error,
          child: () => buildNewsCard(),
          actionButtons: buildActionButtons(context),
        ));
  }
}

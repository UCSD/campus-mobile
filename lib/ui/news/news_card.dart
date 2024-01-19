import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/news.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/news/news_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

const String cardId = 'news';

class NewsCard extends StatelessWidget {
  // final newsProvider = Get.find<NewsController>();
  // final NewsController newsProvider = Get.put(NewsController());
  Widget buildNewsCard() {
    // try {
      return NewsList(
        listSize: 3,
      );
    // } catch (e) {
    //   print(e);
    //   return Container(
    //     width: double.infinity,
    //     child: Center(
    //       child: Container(
    //         child: Text('An error occurred, please try again.'),
    //       ),
    //     ),
    //   );
    // }
  }

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
        Navigator.pushNamed(context, RoutePaths.NewsViewAll);
      },
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    // final isLoading = newsProvider.isLoading;
    // final error = newsProvider.error;
    // print('----------error----------');
    // print(error.value);
    // return CardContainer(
    //   /// TODO: need to hook up hidden to state using provider
    //   active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
    //   hide: () => Provider.of<CardsDataProvider>(context, listen: false)
    //       .toggleCard(cardId),
    //   reload: () =>
    //      Get.find<NewsController>().fetchNews(),
    //   isLoading: isLoading.value,
    //   titleText: CardTitleConstants.titleMap[cardId],
    //   errorText: error.value,
    //   child: () => buildNewsCard(),
    //   actionButtons: buildActionButtons(context),
    // );
    // Get.put(NewsController());
    // Get.put(NewsController());
    final NewsController newsProvider = Get.find<NewsController>();
    final isLoading = newsProvider.isLoading;
    final error = newsProvider.error;
    print("error------new-------"+isLoading.value.toString());
    return Obx(() => CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
      reload: () => newsProvider.fetchNews(),
      isLoading: newsProvider.isLoading.value,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: newsProvider.error.value,
      child: () => buildNewsCard(),
      actionButtons: buildActionButtons(context),
    ));
  }
}

import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';

class CardsView extends StatelessWidget {
  CardsDataProvider _cardsDataProvider;
  @override
  Widget build(BuildContext context) {
    _cardsDataProvider = Provider.of<CardsDataProvider>(context);
    return ContainerView(
      child: buildCardsList(context),
    );
  }

  Widget buildCardsList(BuildContext context) {
    return ReorderableListView(
      children: createList(context),
      onReorder: _onReorder,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    List<String> newOrder = _cardsDataProvider.cardOrder;
    String item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    List<String> orderList = List<String>();
    for (String item in newOrder) {
      orderList.add(item);
    }
    _cardsDataProvider.updateCardOrder(orderList);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (String card in _cardsDataProvider.cardOrder) {
      list.add(ListTile(
        leading: Icon(Icons.reorder),
        key: Key(card),
        title: Text(card),
        trailing: Switch(
          value: _cardsDataProvider.cardStates[card],
          onChanged: (_) {
            _cardsDataProvider.toggleCard(card);
          },
          activeColor: ColorPrimary,
        ),
      ));
    }
    return list;
  }
}

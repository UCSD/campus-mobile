import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    // TODO: Resolve cardOrder issues from 62-808
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
    List<String> toRemove = List<String>();
    if (_cardsDataProvider.cardOrder.contains('QRScanner')) {
      toRemove.add('QRScanner');
    }
    if (_cardsDataProvider.cardOrder.contains('NativeScanner')) {
      toRemove.add('NativeScanner');
    }
    for (String card in newOrder) {
      if (CardTitleConstants.titleMap[card] == null) {
        toRemove.add(card);
      }
    }
    newOrder.removeWhere((element) => toRemove.contains(element));
    String item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    List<String> orderList = List<String>();
    for (String item in newOrder) {
      orderList.add(item);
    }
    orderList.addAll(toRemove.toList());
    _cardsDataProvider.updateCardOrder(orderList);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (String card in _cardsDataProvider.cardOrder) {
      if (card == 'QRScanner') continue;
      if (card == 'NativeScanner') continue;
      if (CardTitleConstants.titleMap[card] == null) continue;
      list.add(ListTile(
        leading: Icon(Icons.reorder),
        key: Key(card),
        title: Text(CardTitleConstants.titleMap[card]),
        trailing: Switch(
          value: _cardsDataProvider.cardStates[card],
          onChanged: (_) {
            _cardsDataProvider.toggleCard(card);
          },
          activeColor: Theme.of(context).textTheme.button.color,
        ),
      ));
    }
    return list;
  }
}

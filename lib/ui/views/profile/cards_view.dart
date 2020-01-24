import 'package:campus_mobile_experimental/core/data_providers/availability_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';

class CardsView extends StatelessWidget {
  UserDataProvider _userDataProvider;
  @override
  Widget build(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);
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
    List<String> newOrder = _userDataProvider.cardOrder;
    String item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    List<String> orderList = List<String>();
    for (String item in newOrder) {
      orderList.add(item);
    }
    _userDataProvider.reorderCards(orderList);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (String card in _userDataProvider.cardOrder) {
      list.add(ListTile(
        leading: Icon(Icons.reorder),
        key: Key(card),
        title: Text(card),
        trailing: Switch(
          value: _userDataProvider.cardStates[card],
          onChanged: (_) {
            _userDataProvider.toggleCard(card);
          },
          activeColor: ColorPrimary,
        ),
      ));
    }
    return list;
  }
}

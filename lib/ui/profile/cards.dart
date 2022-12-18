import 'dart:async';

import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardsView extends StatefulWidget {
  _CardsViewState createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  CardsDataProvider? _cardsDataProvider;

  @override
  void initState() {
    super.initState();
    Provider.of<CardsDataProvider>(context, listen: false).monitorInternet();
  }

  @override
  Widget build(BuildContext context) {
    _cardsDataProvider = Provider.of<CardsDataProvider>(context);
    return ContainerView(child: buildCardsList(context));
  }

  Widget buildCardsList(BuildContext context) {
    var tempView = new ReorderableListView(
      children: createList(context),
      onReorder: _onReorder,
    );

    if (_cardsDataProvider!.noInternet!) {
      Future.delayed(
          Duration.zero,
          () => {
                showDialog(
                    context: context,
                    builder: (BuildContext ctx) => AlertDialog(
                            title: const Text('No Internet'),
                            content: const Text(
                                'Cards requires an internet connection.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Ok'),
                                child: const Text('Ok'),
                              ),
                            ]))
              });
    }

    return tempView;
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    List<String> newOrder = _cardsDataProvider!.cardOrder!;
    List<String> toRemove = [];
    if (_cardsDataProvider!.cardOrder!.contains('NativeScanner')) {
      toRemove.add('NativeScanner');
    }

    newOrder.removeWhere((element) => toRemove.contains(element));
    String item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    List<String> orderList = [];
    for (String item in newOrder) {
      orderList.add(item);
    }
    orderList.addAll(toRemove.toList());
    _cardsDataProvider!.updateCardOrder(orderList);
    setState(() {});
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];
    for (String card in _cardsDataProvider!.cardOrder!) {
      if (card == 'NativeScanner') continue;
      try {
        list.add(ListTile(
          leading: Icon(Icons.reorder),
          key: Key(card),
          title: Text(_cardsDataProvider!.availableCards![card]!.titleText!),
          trailing: Switch(
            value: _cardsDataProvider!.cardStates![card]!,
            onChanged: (_) {
              _cardsDataProvider!.toggleCard(card);
            },
            // activeColor: Theme.of(context).buttonColor,
            activeColor: Theme.of(context).backgroundColor,
          ),
        ));
      } catch (e) {
        FirebaseCrashlytics.instance.log('error getting $card in profile');
        FirebaseCrashlytics.instance.recordError(
            e, StackTrace.fromString(e.toString()),
            reason: "Profile/Cards: Failed to load Cards page", fatal: false);

        _cardsDataProvider!.changeInternetStatus(true);
      }
    }

    return list;
  }
}

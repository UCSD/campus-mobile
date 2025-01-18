import 'dart:async';

import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardsView extends StatefulWidget {
  _CardsViewState createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  /// PROVIDERS
  late CardsDataProvider _cardsDataProvider;

  @override
  void initState() {
    super.initState();
    context.read<CardsDataProvider>().monitorInternet();
  }

  @override
  Widget build(BuildContext context) {
    _cardsDataProvider = Provider.of<CardsDataProvider>(context);
    return ContainerView(child: buildCardsList());
  }

  Widget buildCardsList() {
    var tempView = new ReorderableListView(
        header: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: const Text(
              "Hold and Drag to Reorder",
              textAlign: TextAlign.center,
              style: const TextStyle(color: const Color(0xFF9A9999))
          ),
        ),
        children: createList(),
        onReorder: (int oldIndex, int newIndex) {
          if (newIndex > oldIndex) newIndex -= 1;
          var order = _cardsDataProvider.cardOrder;
          order.insert(newIndex, order.removeAt(oldIndex));
          setState(() { _cardsDataProvider.updateCardOrder(); });
        }
    );

    if (_cardsDataProvider.noInternet) {
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
                        ]
                    )
                )
          }
      );
    }

    return tempView;
  }

  List<Widget> createList() {
    List<Widget> list = [];
    for (String card in _cardsDataProvider.cardOrder) {
      try {
        list.add(Card(
          key: Key(card),
          elevation: 2.0,
          margin: EdgeInsets.all(cardMargin),
          child: Padding(
            padding: EdgeInsets.all(cardPaddingInner),
            child: ListTile(
              leading: Icon(Icons.reorder),
              title: Text(_cardsDataProvider.availableCards[card]!.titleText),
              trailing: Switch(
                value: _cardsDataProvider.cardStates[card]!,
                onChanged: (_) {
                  _cardsDataProvider.toggleCard(card);
                },
                activeColor: Theme.of(context).colorScheme.background,
              ),
            ),
          ),
        ));
      } catch (e) {
        FirebaseCrashlytics.instance.log('error getting $card in profile');
        FirebaseCrashlytics.instance.recordError(
            e, StackTrace.fromString(e.toString()),
            reason: "Profile/Cards: Failed to load Cards page", fatal: false);

        _cardsDataProvider.changeInternetStatus(true);
      }
    }

    return list;
  }
}

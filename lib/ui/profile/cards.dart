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
  List<String> cardsToRemove = ["NativeScanner"];
  List<String> hiddenCards = ["NativeScanner", "ventilation", "student_survey"];

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
    // ?
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // declare variables
    List<String> cardsOrder = _cardsDataProvider!.cardOrder!;
    List<String> addBack = [];

    // remove all unwanted cards from the cards list
    for (String card in cardsToRemove) {
      // if the card was removed, add it back at the end
      if (cardsOrder.remove(card)) {
        addBack.add(card);
      }
    }

    // change the position for the moved card
    String item = cardsOrder.removeAt(oldIndex);
    cardsOrder.insert(newIndex, item);

    // add back all unwanted cards to the end of the list
    cardsOrder.addAll(addBack);

    // update card order
    _cardsDataProvider!.updateCardOrder(cardsOrder);
    setState(() {});
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];
    for (String card in _cardsDataProvider!.cardOrder!) {
      if (hiddenCards.contains(card)) continue;
      try {
        //throw new DeferredLoadException("message");
        list.add(ListTile(
          leading: Icon(Icons.reorder),
          key: Key(card),
          title: Text(_cardsDataProvider!.availableCards![card]!.titleText!),
          trailing: Switch(
            value: _cardsDataProvider!.cardStates![card]!,
            onChanged: (_) {
              _cardsDataProvider!.toggleCard(card);
            },
            activeColor: Theme.of(context).buttonColor,
          ),
        ));
      } catch (e) {
        FirebaseCrashlytics.instance.log('error getting $card in profile');
        FirebaseCrashlytics.instance.recordError(
            e, StackTrace.fromString(e.toString()),
            reason: "Profile/Cards: Failed to load Cards page", fatal: false);
        // temp list tile
        list.add(ListTile(
          leading: Icon(Icons.reorder),
          title: Text('error'),
        ));
      }
    }
    return list;
  }
}

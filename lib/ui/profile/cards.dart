import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/connectivity.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardsView extends StatefulWidget {
  _CardsViewState createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  CardsDataProvider? _cardsDataProvider;
  InternetConnectivityProvider? _connectivityProvider;
  List<String> cardsToRemove = ["NativeScanner"];
  List<String> hiddenCards = ["NativeScanner", "ventilation", "student_survey"];

  @override
  Widget build(BuildContext context) {
    _cardsDataProvider = Provider.of<CardsDataProvider>(context);
    _connectivityProvider = Provider.of<InternetConnectivityProvider>(context);
    return ContainerView(
        child: ChangeNotifierProvider(
      create: (_) => InternetConnectivityProvider(),
      child: buildCardsList(context),
    ));
  }

  Widget buildCardsList(BuildContext context) {
    var tempView = new ReorderableListView(
      children: createList(context),
      onReorder: _onReorder,
    );

    AlertDialog alert = AlertDialog(
      title: Text(ConnectivityConstants.offlineTitle),
      content: Text(ConnectivityConstants.offlineAlert),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'Ok'),
          child: const Text('Ok'),
        ),
      ],
    );

    if (_connectivityProvider!.noInternet) {
      Future.delayed(
          Duration.zero,
          () => {
                showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return alert;
                  },
                  // AlertDialog(
                  // title: const Text('No Internet'),
                  // content:
                  //     const Text('Cards requires an internet connection.'),
                  // actions: <Widget>[
                  //   TextButton(
                  //     onPressed: () => Navigator.pop(context, 'Ok'),
                  //     child: const Text('Ok'),
                  //   ),
                  // ]),
                )
              });
    }

    return tempView;
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
    String movedCard = cardsOrder.removeAt(oldIndex);
    cardsOrder.insert(newIndex, movedCard);

    // add back all unwanted cards to the end of the list
    cardsOrder.addAll(addBack.toList());

    // update card order
    _cardsDataProvider!.updateProfileAndCardOrder(cardsOrder);
    setState(() {});
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];
    for (String card in _cardsDataProvider!.cardOrder!) {
      if (hiddenCards.contains(card)) continue;
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
            activeColor: Theme.of(context).buttonColor,
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

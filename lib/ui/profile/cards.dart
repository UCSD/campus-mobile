import 'dart:async';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';
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
    var tempView = ReorderableListView(
        header: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text("Hold and drag to reorder",
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ),
        children: createList(),
        onReorder: (int oldIndex, int newIndex) {
          if (newIndex > oldIndex) newIndex -= 1;
          var order = _cardsDataProvider.cardOrder;
          order.insert(newIndex, order.removeAt(oldIndex));
          setState(() {
            // Checks against stored user order in remote profile
            _cardsDataProvider.updateCardOrder();
          });
        });

    if (_cardsDataProvider.noInternet) {
      Future.delayed(
          Duration.zero,
          () => {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialogWidget(
                        type: MessageTypeConstants.ERROR,
                        icon: Icons.block_flipped,
                        title: 'No Internet',
                        description: 'Cards requires an internet connection.',
                        onClose: () {
                          Navigator.of(context).pop();
                        },
                      );
                    }),
              });
    }

    return tempView;
  }

  List<Widget> createList() {
    List<Widget> list = [];
    for (String card in _cardsDataProvider.cardOrder) {
      try {
        list.add(
          Card(
            key: Key(card),
            elevation: 2.0,
            margin: EdgeInsets.fromLTRB(cardMargin, 5, cardMargin, 5),
            child: ListTile(
              leading: Icon(Icons.drag_handle,
                  color: Theme.of(context).brightness == Brightness.dark ? linkTextColorDark : linkTextColorLight),
              title: Text(_cardsDataProvider.availableCards[card]!.titleText,
                  style: Theme.of(context).textTheme.bodyMedium),
              trailing: Transform.scale(
                scale: 0.9, // Adjust the scale as needed
                child: Switch.adaptive(
                  value: _cardsDataProvider.cardStates[card]!,
                  onChanged: (_) {
                    _cardsDataProvider.toggleCard(card);
                  },
                  activeColor: toggleActiveColor, // Ensure this is a solid color
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    final bool isSelected = states.contains(WidgetState.selected);
                    if (isSelected) return Colors.white;
                    return null;
                  }),
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        FirebaseCrashlytics.instance.log('error getting $card in profile');
        FirebaseCrashlytics.instance.recordError(e, StackTrace.fromString(e.toString()),
            reason: "Profile/Cards: Failed to load Cards page", fatal: false);

        _cardsDataProvider.changeInternetStatus(true);
      }
    }

    return list;
  }
}

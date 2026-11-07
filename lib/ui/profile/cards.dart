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
  }

  @override
  Widget build(BuildContext context) {
    _cardsDataProvider = Provider.of<CardsDataProvider>(context);
    return ContainerView(child: buildCardsList());
  }

  Widget buildCardsList() {
    bool isAccessibleNavigation = MediaQuery.of(context).accessibleNavigation;
    var tempView = ReorderableListView(
      header: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          isAccessibleNavigation ? "Press up or down to reorder" : "Hold and drag to reorder",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      children: createList(context),
      onReorderItem: (int oldIndex, int newIndex) {
        var order = _cardsDataProvider.cardOrder;
        order.insert(newIndex, order.removeAt(oldIndex));
        setState(() {
          // Checks against stored user order in remote profile
          _cardsDataProvider.updateCardOrder(isUserReorder: true);
        });
      },
    );

    return tempView;
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];
    bool isAccessibleNavigation = MediaQuery.of(context).accessibleNavigation; // is a screen reader on?

    // Check if cards failed to load (likely due to internet issues)
    var hasCardsInOrder = _cardsDataProvider.cardOrder.isNotEmpty;
    var noCardsLoaded = _cardsDataProvider.availableCards.isEmpty;
    if (hasCardsInOrder && noCardsLoaded) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialogWidget(
              type: MessageTypeConstants.ERROR,
              icon: Icons.wifi_off,
              title: 'Cards Not Available',
              description: 'Unable to load cards. Please check your internet connection and try again.',
              onClose: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
      });
      return list;
    }

    for (int i = 0; i < _cardsDataProvider.cardOrder.length; i++) {
      String card = _cardsDataProvider.cardOrder[i];
      try {
        // Skip cards that aren't available
        if (_cardsDataProvider.availableCards[card] == null) continue;

        String title = _cardsDataProvider.availableCards[card]!.titleText;

        list.add(
          Card(
            key: Key(card),
            elevation: 2.0,
            margin: EdgeInsets.fromLTRB(cardMargin, 5, cardMargin, 5),
            child: ListTile(
              leading: isAccessibleNavigation
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          label: i == 0
                              ? 'Disabled since this card is already at the top, cannot move further up'
                              : 'Move $title up',
                          button: true,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            icon: const Icon(Icons.arrow_upward),
                            onPressed: i == 0
                                ? null
                                : () {
                                    var order = _cardsDataProvider.cardOrder;
                                    order.insert(i - 1, order.removeAt(i));
                                    setState(() {
                                      _cardsDataProvider.updateCardOrder(isUserReorder: true);
                                    });
                                  },
                          ),
                        ),
                        Semantics(
                          label: i == _cardsDataProvider.cardOrder.length - 1
                              ? 'Disabled since this card is already at the bottom, cannot move further down'
                              : 'Move $title down',
                          button: true,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            icon: const Icon(Icons.arrow_downward),
                            onPressed: i == _cardsDataProvider.cardOrder.length - 1
                                ? null
                                : () {
                                    var order = _cardsDataProvider.cardOrder;
                                    order.insert(i + 1, order.removeAt(i));
                                    setState(() {
                                      _cardsDataProvider.updateCardOrder(isUserReorder: true);
                                    });
                                  },
                          ),
                        ),
                      ],
                    )
                  : Icon(
                      Icons.drag_handle,
                      color: Theme.of(context).brightness == Brightness.dark ? linkTextColorDark : linkTextColorLight,
                    ),
              title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
              trailing: Transform.scale(
                scale: 0.9, // Adjust the scale as needed
                child: Switch.adaptive(
                  value: _cardsDataProvider.cardStates[card]!,
                  onChanged: (_) {
                    _cardsDataProvider.toggleCard(card);
                  },
                  activeTrackColor: toggleActiveColor, // Ensure this is a solid color
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
        FirebaseCrashlytics.instance.recordError(
          e,
          StackTrace.fromString(e.toString()),
          reason: "Profile/Cards: Failed to load Cards page",
          fatal: false,
        );
      }
    }
    return list;
  }
}

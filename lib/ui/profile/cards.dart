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
    final screenReaderActive = MediaQuery.accessibleNavigationOf(context);
    var tempView = ReorderableListView(
        header: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(screenReaderActive ? "Use the up and down arrows to reorder" : "Hold and drag to reorder",
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ),
        children: createList(),
        onReorder: (int oldIndex, int newIndex) {
          if (newIndex > oldIndex) newIndex -= 1;
          var order = _cardsDataProvider.cardOrder;
          order.insert(newIndex, order.removeAt(oldIndex));
          setState(() {
            // Checks against stored user order in remote profile
            _cardsDataProvider.updateCardOrder(isUserReorder: true);
          });
        });

    return tempView;
  }

  List<Widget> createList() {
    List<Widget> list = [];

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

    // Cards actually rendered, in display order - used to know which card is
    // first/last so the up/down arrows can be disabled at the boundaries.
    final visibleCards =
        _cardsDataProvider.cardOrder.where((card) => _cardsDataProvider.availableCards[card] != null).toList();
    final screenReaderActive = MediaQuery.accessibleNavigationOf(context);

    for (var i = 0; i < visibleCards.length; i++) {
      final card = visibleCards[i];
      try {
        list.add(
          Card(
            key: Key(card),
            elevation: 2.0,
            margin: EdgeInsets.fromLTRB(cardMargin, 5, cardMargin, 5),
            child: ListTile(
              // Dragging to reorder isn't reliably accessible to screen reader
              // users, so up/down arrow buttons are shown instead whenever a
              // screen reader is active.
              leading: screenReaderActive
                  ? _buildReorderArrows(card, visibleCards, isFirst: i == 0, isLast: i == visibleCards.length - 1)
                  : Icon(Icons.drag_handle,
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
      }
    }
    return list;
  }

  Widget _buildReorderArrows(String card, List<String> visibleCards, {required bool isFirst, required bool isLast}) {
    final title = _cardsDataProvider.availableCards[card]!.titleText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_upward),
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Move $title up',
          onPressed: isFirst ? null : () => _moveCard(card, visibleCards, -1),
        ),
        IconButton(
          icon: Icon(Icons.arrow_downward),
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Move $title down',
          onPressed: isLast ? null : () => _moveCard(card, visibleCards, 1),
        ),
      ],
    );
  }

  /// Moves [card] next to the adjacent visible card. The stored order may
  /// contain unavailable cards, so raw list indices cannot drive this action.
  void _moveCard(String card, List<String> visibleCards, int delta) {
    final order = _cardsDataProvider.cardOrder;
    final visibleIndex = visibleCards.indexOf(card);
    final targetVisibleIndex = visibleIndex + delta;
    if (visibleIndex == -1 || targetVisibleIndex < 0 || targetVisibleIndex >= visibleCards.length) return;

    final targetCard = visibleCards[targetVisibleIndex];
    final currentIndex = order.indexOf(card);
    final targetIndex = order.indexOf(targetCard);
    if (currentIndex == -1 || targetIndex == -1) return;

    setState(() {
      order.removeAt(currentIndex);
      order.insert(targetIndex, card);
      // Checks against stored user order in remote profile
      _cardsDataProvider.updateCardOrder(isUserReorder: true);
    });
  }
}

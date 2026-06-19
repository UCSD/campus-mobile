import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({
    Key? key,
    required this.titleText,
    required this.isLoading,
    required this.reload,
    required this.errorText,
    required this.child,
    required bool? active,
    required this.hide,
    this.overFlowMenu,
    this.actionButtons,
    this.footer,
    this.hideMenu = false,
    this.cardId,
  })  : active = active ?? false,
        super(key: key);

  /// required parameters
  final String titleText;
  final bool isLoading;
  final bool active;
  final Function hide;
  final Function reload;
  final Widget Function() child;
  final String? errorText;

  /// optional parameters
  final Map<String, Function>? overFlowMenu;
  final bool hideMenu;
  final List<Widget>? actionButtons;
  final Widget? footer;
  final String? cardId;
  @override
  Widget build(BuildContext context) {
    if (active) {
      return Card(
        margin: EdgeInsets.only(top: 0.0, right: 0.0, bottom: cardMargin * 1.5, left: 0.0),
        elevation: 4,
        shadowColor: Colors.black,
        semanticContainer: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: dotsUnselectedColor,
            width: 0.5,
          ),
        ),
        color: Theme.of(context).brightness == Brightness.dark ? darkPrimaryBgColor : lightAccentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.only(top: 0.0, right: 8.0, bottom: 0.0, left: 8.0),
              visualDensity: VisualDensity(horizontal: 0, vertical: 0),
              // container + explicitChildNodes keep this from being merged with the
              // trailing menu's semantics into one "[title], button" announcement.
              title: Semantics(
                header: true,
                container: true,
                explicitChildNodes: true,
                child: Text(
                  titleText,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              trailing: buildMenu(),
            ),
            buildBody(context),
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 0, bottom: 16, left: 8),
              child: actionButtons != null ? Row(children: actionButtons!) : Container(),
            ),
            footer ?? Container(),
          ],
        ),
      );
    }
    return Container();
  }

  Widget buildBody(context) {
    if (errorText != null) {
      print(errorText);
      if (titleText == 'NEWS') {
        return Text('No articles found.');
      } else if (titleText == 'EVENTS') {
        return Text('No events found.');
      } else if (titleText == 'STUDENT ID') {
        return Padding(
          padding: const EdgeInsets.only(top: 32.0, bottom: 48.0),
          child: Text('An error occurred, please try again.'),
        );
      } else if (titleText == 'FINALS') {
        var customErrorText = '';
        if (errorText!.contains('Exception')) {
          customErrorText =
              'Your finals could not be displayed.\n\nIf the problem persists contact mobilesupport@ucsd.edu';
        } else {
          customErrorText = 'No finals found.';
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 42.0),
          child: Text(customErrorText),
        );
      } else if (titleText == 'CLASSES') {
        var customErrorText = '';
        if (errorText!.contains('Exception')) {
          customErrorText =
              'Your classes could not be displayed.\n\nIf the problem persists contact mobilesupport@ucsd.edu';
        } else {
          customErrorText = 'No classes found.';
        }
        return Text(customErrorText);
      } else {
        return Text('An error occurred, please try again.');
      }
    } else if (isLoading) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: cardContentMinHeight),
        child: Center(
          child: Container(
              height: 32,
              width: 32,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              )),
        ),
      );
    } else if (titleText == "BUSYNESS") {
      // web cards are still sized with static values
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: cardMinHeight, maxHeight: 322),
        child: child(),
      );
    } else if (titleText == "SHUTTLE") {
      // web cards are still sized with static values
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: cardMinHeight, maxHeight: 375),
        child: child(),
      );
    } else if (titleText == "PARKING") {
      double _maxHeight = 320;
      if (MediaQuery.of(context).size.width > 600) _maxHeight = 800;
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 320, maxHeight: _maxHeight),
        child: child(),
      );
    } else {
      return Container(
        width: double.infinity,
        child: child(),
      );
    }
  }

  Widget buildMenu() {
    if (hideMenu) return Container();

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'More options for $titleText',
      child: ButtonBar(
        buttonPadding: const EdgeInsets.all(0),
        mainAxisSize: MainAxisSize.min,
        children: [
          buildMenuOptions(
            {
              CardMenuOptionConstants.RELOAD_CARD: reload,
              CardMenuOptionConstants.HIDE_CARD: hide,
            },
          ),
        ],
      ),
    );
  }

  Widget buildMenuOptions(Map<String, Function> menuOptions) {
    List<DropdownMenuItem<String>> menu = [];

    menuOptions.forEach((menuOption, func) {
      Widget item = DropdownMenuItem<String>(
        value: menuOption,
        child: Text(
          menuOption,
          textAlign: TextAlign.center,
          style: TextStyle(color: dotsUnselectedColor),
        ),
      );
      menu.add(item as DropdownMenuItem<String>);
    });

    return DropdownButton(
      items: menu,
      iconSize: 36,
      iconEnabledColor: dotsUnselectedColor,
      underline: Container(),
      icon: Transform.translate(
        offset: Offset(6, -3),
        child: Icon(Icons.more_vert, color: dotsUnselectedColor),
      ),
      onChanged: (String? selectedMenuItem) => onMenuItemPressed(selectedMenuItem),
    );
  }

  void onMenuItemPressed(String? selectedMenuItem) {
    switch (selectedMenuItem) {
      case CardMenuOptionConstants.RELOAD_CARD:
        if (cardId != null) analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'reload'});
        reload();
        break;
      case CardMenuOptionConstants.HIDE_CARD:
        if (cardId != null) analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'hide'});
        hide();
        break;
      default:
      // do nothing for now
    }
  }
}

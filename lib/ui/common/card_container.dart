import 'package:campus_mobile_experimental/app_constants.dart';
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
  }) : active = active ?? false,
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

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Card(
        margin: const EdgeInsets.only(
            top: 0.0, right: 0.0, bottom: cardMargin * 1.5, left: 0.0),
        semanticContainer: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.only(
                  top: 0.0, right: 6.0, bottom: 0.0, left: 12.0),
              visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
              title: Text(
                titleText,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                ),
              ),
              trailing: buildMenu(),
            ),
            buildBody(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: actionButtons != null
                  ? Row(children: actionButtons!)
                  : Container(),
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
      return switch (titleText) {
        'News' => const Text('No articles found.'),
        'Events' => const Text('No events found.'),
        'Student ID' => const Padding(
          padding: const EdgeInsets.only(top: 32.0, bottom: 48.0),
          child: const Text('An error occurred, please try again.')
        ),
        'Finals' => Padding(
          padding: const EdgeInsets.only(bottom: 42.0),
          child: Text(errorText!.contains('Exception')
            ? 'Your finals could not be displayed.\n\nIf the problem persists contact mobilesupport@ucsd.edu'
            : 'No finals found.'
          )
        ),
        'Classes' => Text(errorText!.contains('Exception')
          ? 'Your classes could not be displayed.\n\nIf the problem persists contact mobilesupport@ucsd.edu'
          : 'No classes found.'
        ),
        _ => Text('An error occurred, please try again.')
      };
    }
    
    if (isLoading) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: cardContentMinHeight),
        child: Center(
          child: Container(
              height: 32,
              width: 32,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              )),
        ),
      );
    }
    
    return switch (titleText) {
      "Busyness" => Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: cardMinHeight, maxHeight: 265),
        child: child(),
      ),
      "Shuttle" => Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: cardMinHeight, maxHeight: 340),
        child: child(),
      ),
      "Parking" => Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 320,
          maxHeight: MediaQuery.of(context).size.width > 600 ? 800 : 320,
        ),
        child: child(),
      ),
      _ => Container(
        width: double.infinity,
        child: child(),
      ),
    };
  }

  Widget buildMenu() {
    if (hideMenu)
      return Container();

    return OverflowBar(
      children: [
        buildMenuOptions({
          CardMenuOptionConstants.reloadCard: reload,
          CardMenuOptionConstants.hideCard: hide,
        }),
      ],
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
        ),
      );
      menu.add(item as DropdownMenuItem<String>);
    });
    return DropdownButton(
      items: menu,
      underline: Container(),
      icon: Icon(Icons.more_vert),
      onChanged: (String? selectedMenuItem) =>
          onMenuItemPressed(selectedMenuItem),
    );
  }

  void onMenuItemPressed(String? selectedMenuItem) {
    switch (selectedMenuItem) {
      case CardMenuOptionConstants.reloadCard:
        reload();
        break;
      case CardMenuOptionConstants.hideCard:
        hide();
        break;
      default:
        // do nothing for now
    }
  }
}

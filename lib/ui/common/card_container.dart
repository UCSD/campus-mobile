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
    required this.active,
    required this.hide,
    this.overFlowMenu,
    this.actionButtons,
    this.hideMenu,
  }) : super(key: key);

  /// required parameters
  final String? titleText;
  final bool? isLoading;
  final bool? active;
  final Function hide;
  final Function reload;
  final Widget Function() child;
  final String? errorText;

  /// optional parameters
  final Map<String, Function>? overFlowMenu;
  final bool? hideMenu;
  final List<Widget>? actionButtons;

  @override
  Widget build(BuildContext context) {
    if (active != null && active!) {
      return Card(
        margin: EdgeInsets.only(
            top: 0.0, right: 0.0, bottom: cardMargin * 1.5, left: 0.0),
        semanticContainer: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text(
                titleText!,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20.0,
                ),
              ),
              trailing: ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildMenu()!,
                ],
              ),
            ),
            buildBody(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: actionButtons != null
                  ? Row(
                      children: actionButtons!,
                    )
                  : Container(),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget buildBody(context) {
    if (errorText != null) {
      if (titleText == 'News') {
        return Text('No articles found.');
      } else if (titleText == 'Events') {
        return Text('No events found.');
      } else if (titleText == 'Student ID') {
        return Padding(
          padding: const EdgeInsets.only(top: 32.0, bottom: 48.0),
          child: Text('An error occurred, please try again.'),
        );
      } else if (titleText == 'Finals') {
        var customErrorText = '';
        if (errorText!.contains('Exception')) {
          customErrorText =
              'Your finals could not be displayed.\n\nIf the problem persists contact mobile@ucsd.edu';
        } else {
          customErrorText = 'No finals found.';
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 42.0),
          child: Text(customErrorText),
        );
      } else if (titleText == 'Classes') {
        var customErrorText = '';
        if (errorText!.contains('Exception')) {
          customErrorText =
              'Your classes could not be displayed.\n\nIf the problem persists contact mobile@ucsd.edu';
        } else {
          customErrorText = 'No classes found.';
        }
        return Text(customErrorText);
      } else {
        return Text('An error occurred, please try again.');
      }
    } else if (isLoading!) {
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
    } else if (titleText == "Availability") {
      // web cards are still sized with static values
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: cardMinHeight, maxHeight: 210),
        child: child(),
      );
    } else if (titleText == "Parking") {
      double _maxHeight = 320;
      if (MediaQuery.of(context).size.width > 600) {
        _maxHeight = 800;
      }
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

  Widget? buildMenu() {
    if (hideMenu ?? false) {
      return null;
    } else if (titleText == "Scanner") {
      return ButtonBar(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildMenuOptions({
            'reload': reload,
          }),
        ],
      );
    }
    return ButtonBar(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildMenuOptions({
          'reload': reload,
          'hide': hide,
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
      case 'reload':
        {
          reload();
        }
        break;
      case 'hide':
        {
          hide();
        }
        break;
      default:
        {
          // do nothing for now
        }
    }
  }
}

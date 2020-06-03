import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({
    Key key,
    @required this.titleText,
    @required this.isLoading,
    @required this.reload,
    @required this.errorText,
    @required this.child,
    @required this.active,
    @required this.hide,
    this.overFlowMenu,
    this.actionButtons,
    this.hideMenu,
  }) : super(key: key);

  /// required parameters
  final String titleText;
  final bool isLoading;
  final bool active;
  final Function hide;
  final Function reload;
  final Widget Function() child;
  final String errorText;

  /// optional parameters
  final Map<String, Function> overFlowMenu;
  final bool hideMenu;
  final List<Widget> actionButtons;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Card(
        margin: EdgeInsets.only(
            top: 0.0, right: 0.0, bottom: cardMargin * 1.5, left: 0.0),
        semanticContainer: false,
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            ListTile(
              title: Text(
                titleText,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20.0,
                ),
              ),
              trailing: ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildMenu(),
                ],
              ),
            ),
            buildBody(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: actionButtons != null
                  ? Row(
                      children: actionButtons,
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
      } else if (titleText == 'Finals') {
        return Text('No finals found.');
      } else if (titleText == 'Classes') {
        return Text('No classes found.');
      } else {
        return Text('An error occurred, please try again.');
      }
    } else if (isLoading) {
      return Container(
        constraints: BoxConstraints(minHeight: cardMinHeight),
        width: double.infinity,
        child: Center(
          child: Container(
              height: 32, width: 32, child: CircularProgressIndicator()),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        child: child(),
      );
    }
  }

  Widget buildMenu() {
    if (hideMenu ?? false) {
      return null;
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
    List<DropdownMenuItem<String>> menu = List<DropdownMenuItem<String>>();
    menuOptions.forEach((menuOption, func) {
      Widget item = DropdownMenuItem<String>(
        value: menuOption,
        child: Text(
          menuOption,
          textAlign: TextAlign.center,
        ),
      );
      menu.add(item);
    });
    return DropdownButton(
      items: menu,
      underline: Container(),
      icon: Icon(Icons.more_vert),
      onChanged: (String selectedMenuItem) =>
          onMenuItemPressed(selectedMenuItem),
    );
  }

  void onMenuItemPressed(String selectedMenuItem) {
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

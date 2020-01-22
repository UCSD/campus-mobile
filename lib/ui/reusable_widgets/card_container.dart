import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  const CardContainer(
      {Key key,
      @required this.title,
      @required this.isLoading,
      @required this.reload,
      @required this.errorText,
      @required this.child,
      @required this.hidden,
      @required this.hide,
      this.overFlowMenu,
      this.actionButtons})
      : super(key: key);

  /// required parameters
  final Widget title;
  final bool isLoading;
  final bool hidden;
  final Function hide;
  final Function reload;
  final Widget Function() child;
  final String errorText;

  /// optional parameters
  final Map<String, Function> overFlowMenu;
  final List<Widget> actionButtons;

  @override
  Widget build(BuildContext context) {
    if (!hidden) {
      return Card(
        semanticContainer: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: title,
              trailing: ButtonTheme.bar(
                // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildMenu({
                      'reload': reload,
                      'hide': hide,
                    }),
                  ],
                ),
              ),
            ),
            buildBody(),
            actionButtons != null
                ? Row(
                    children: actionButtons,
                  )
                : Container()
          ],
        ),
      );
    }
    return Container();
  }

  Widget buildBody() {
    if (errorText != null) {
      return Text(errorText);
    } else if (isLoading) {
      return Container(
          height: 224, width: 224, child: CircularProgressIndicator());
    } else {
      return Container(
        constraints: BoxConstraints(maxHeight: 224, maxWidth: 406),
        child: child(),
      );
    }
  }

  Widget buildMenu(Map<String, Function> menuOptions) {
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

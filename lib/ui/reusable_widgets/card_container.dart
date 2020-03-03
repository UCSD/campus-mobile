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
  final List<Widget> actionButtons;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
        child: Card(
          semanticContainer: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    buildMenu({
                      'reload': reload,
                      'hide': hide,
                    }),
                  ],
                ),
              ),
              buildBody(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: actionButtons != null
                    ? Row(
                        children: actionButtons,
                      )
                    : Container(),
              ),
            ],
          ),
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
        constraints: BoxConstraints(maxHeight: 350, maxWidth: 406),
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

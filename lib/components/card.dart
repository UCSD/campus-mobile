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
      this.overFlowMenu})
      : super(key: key);

  /// required parameters
  final Widget title;
  final bool isLoading;
  final bool hidden;
  final Function reload;
  final Widget child;
  final String errorText;

  /// optional parameters
  final Map<String, Function> overFlowMenu;

  @override
  Widget build(BuildContext context) {
    if (!hidden) {
      return Card(
        child: Column(
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
                      'hide': () {/* insert hide function*/}
                    })
                  ],
                ),
              ),
            ),
            Row(
              children: [buildBody()],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
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
      return Center(child: CircularProgressIndicator());
    } else {
      return child;
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
          //TODO
          //insert code to hide card here
        }
        break;
      default:
        {
          // do nothing for now
        }
    }
  }
}

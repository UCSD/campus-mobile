import 'package:flutter/material.dart';

class CardContainer extends StatefulWidget {
  CardContainer(
      {Key key,
      @required this.title,
      @required this.isLoading,
      @required this.reload,
      @required this.errorText,
      @required this.children,
      this.overFlowMenu})
      : super(key: key);

  /// required parameters
  Widget title;
  bool isLoading;
  Function reload;
  List<Widget> children;
  String errorText;

  /// optional parameters
  Map<String, Function> overFlowMenu;

  @override
  _CardContainerState createState() => _CardContainerState();
}

class _CardContainerState extends State<CardContainer> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: widget.title,
            trailing: ButtonTheme.bar(
              // make buttons use the appropriate styles for cards
              child: ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: buildMenu({
                  'refresh': widget.reload,
                  'hide': () {/* insert hide function*/}
                }),
              ),
            ),
          ),
          Row(
            children: buildBody(),
          ),
        ],
      ),
    );
  }

  List<Widget> buildBody() {
    if (widget.errorText != null) {
      return [Text(widget.errorText)];
    } else if (widget.isLoading) {
      return [Center(child: CircularProgressIndicator())];
    } else {
      return widget.children;
    }
  }

  List<Widget> buildMenu(Map<String, Function> menuOptions) {
    List<Widget> menu = List<Widget>();
    menuOptions.forEach((menuOption, func) {
      Widget item = FlatButton(
        child: Text(
          menuOption,
          textAlign: TextAlign.center,
        ),
        onPressed: func,
      );
      menu.add(item);
    });
    return menu;
  }
}

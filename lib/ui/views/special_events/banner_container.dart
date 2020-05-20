import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BannerContainer extends StatelessWidget {
  const BannerContainer({
    Key key,
    @required this.isLoading,
    @required this.reload,
    @required this.errorText,
    @required this.child,
    @required this.hidden,
  }) : super(key: key);

  /// required parameters
  final bool isLoading;
  final bool hidden;
  final Function reload;
  final Widget child;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    if (!hidden) {
      return Stack(children: <Widget>[
        Card(
          semanticContainer: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildBody(context),
            ],
          ),
        ),
        buildCloseButton(context)
      ]);
    }
    return Container();
  }

  Widget buildBody(BuildContext context) {
    if (errorText != null) {
      return Text(errorText);
    } else if (isLoading) {
      return Container(
          height: 224, width: 224, child: CircularProgressIndicator());
    } else if (Provider.of<CardsDataProvider>(context)
        .cardStates['special_events']) {
      return Container(
        constraints: BoxConstraints(maxHeight: 224, maxWidth: 406),
        child: child,
      );
    } else {
      return Container();
    }
  }

  Widget buildCloseButton(BuildContext context) {
    return Container(
      padding: new EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
      height: 30,
      alignment: Alignment.topRight,
      child: GestureDetector(
          onTap: () {
            Provider.of<CardsDataProvider>(context, listen: false)
                .toggleCard('special_events');
          },
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('Close', style: TextStyle(color: Colors.white)),
                Icon(
                  Icons.highlight_off,
                  color: Colors.white,
                  size: 24,
                  semanticLabel: 'Close banner',
                )
              ])),
    );
  }
}

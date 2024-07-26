import 'package:campus_mobile_experimental/core/providers/notifications_IAmGoing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/notifications.dart';

class IAmGoingNotification extends StatefulWidget {
  /// required parameters
  final MessageElement data;

  const IAmGoingNotification({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  _CheckBoxButtonState createState() => _CheckBoxButtonState(data);
}

class _CheckBoxButtonState extends State<IAmGoingNotification> {
  _CheckBoxButtonState(data) {
    this.data = data;
  }

  late IAmGoingProvider _iAmGoingDataProvider;
  late MessageElement data;

  bool _isLoading = false;
  bool _isGoing = false;
  Color _buttonColor = Colors.white;
  Color _borderColor = Color(0xFF034161);
  Color _textColor = Color(0xFF034161);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _iAmGoingDataProvider = Provider.of<IAmGoingProvider>(context);
    _isLoading = _iAmGoingDataProvider.isLoading(data.messageId);
    _isGoing = _iAmGoingDataProvider.registeredEvents!.contains(data.messageId);
    if (_isGoing) {
      _buttonColor = Colors.green;
      _borderColor = Colors.green;
      _textColor = Colors.white;
    } else {
      _buttonColor = Colors.white;
      _borderColor = Color(0xFF034161);
      _textColor = Color(0xFF034161);
    }
  }

  @override
  Widget build(BuildContext context) {
    var isOverCount = _iAmGoingDataProvider.isOverCount(data.messageId);
    String messageType = data.audience!.topics![0];

    // print('messageId "' + messageId + '" isOverCount: ' + isOverCount.toString());

    var currCount = _iAmGoingDataProvider.count(data.messageId);
    String countText;
    if (messageType == "campusInnovationEvents") {
      if (currCount == 1) {
        countText = '$currCount participant is going';
      } else {
        countText = '$currCount participants are going';
      }
    } else {
      // messageType == "freeFood" or anything else
      if (currCount == 1) {
        countText = '$currCount student is going';
      } else {
        countText = '$currCount students are going';
      }
    }

    return Container(
        margin: EdgeInsets.only(left: 72.0),
        child: Row(
          children: <Widget>[
            Container(
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                crossFadeState: isOverCount
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Column(
                  children: <Widget>[
                    Text(countText,
                        style: TextStyle(fontSize: 10, color: Colors.red)),
                    Container(
                        margin: EdgeInsets.only(top: 4.0),
                        width: 200,
                        child: Row(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(right: 4.0),
                                child: Icon(Icons.report,
                                    color: Colors.grey, size: 10)),
                            Flexible(
                              child: Text(() {
                                if (messageType == "campusInnovationEvents") {
                                  return "The event may not have enough space for all the participants";
                                } else {
                                  // messageType == "freeFood" or anything else
                                  return "There may not be enough food";
                                }
                              }(), style: TextStyle(fontSize: 9)),
                            )
                          ],
                        )),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                secondChild: Align(
                  alignment: Alignment.topLeft,
                  child: Text(countText,
                      style: TextStyle(fontSize: 10, color: Colors.green)),
                ),
              ),
            ),
            _checkBoxButton(),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ));
  }

  Widget _checkBoxButton() {
    return Container(
        height: 23,
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
            color: _borderColor,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(2.0),
          ),
        ),
        margin: EdgeInsets.only(right: 10.0),
        child: _isLoading
            ? Center(
                child: Container(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                      strokeWidth: 1.5,
                    )))
            : Material(
                color: _buttonColor,
                child: InkWell(
                  onTap: () {
                    _toggleGoing();
                  },
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                          height: 10.0,
                          width: 8.0,
                          child: Transform.scale(
                              scale: 0.5,
                              child: Checkbox(
                                checkColor: Colors.green,
                                activeColor: Colors.white,
                                value: _isGoing,
                                onChanged: (bool? val) {
                                  _toggleGoing();
                                },
                              ))),
                      Text("I'm Going!",
                          style: TextStyle(color: _textColor, fontSize: 10)),
                    ],
                  )),
                )));
  }

  void _toggleGoing() {
    setState(() {
      if (_isGoing) {
        _buttonColor = Colors.white;
        _borderColor = Color(0xFF034161);
        _textColor = Color(0xFF034161);
        _iAmGoingDataProvider.decrementCount(data.messageId!);
      } else {
        _buttonColor = Colors.green;
        _borderColor = Colors.green;
        _textColor = Colors.white;
        _iAmGoingDataProvider.incrementCount(data.messageId!);
      }
      _isGoing = !_isGoing;
    });
  }
}

import 'package:campus_mobile_experimental/core/providers/notifications_IAmGoing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IAmGoingNotification extends StatefulWidget {
  /// required parameters
  final String? messageId;

  const IAmGoingNotification({
    Key? key,
    required this.messageId,
  }) : super(key: key);

  @override
  _CheckBoxButtonState createState() => _CheckBoxButtonState(messageId);
}

class _CheckBoxButtonState extends State<IAmGoingNotification> {
  _CheckBoxButtonState(messageId) {
    this.messageId = messageId;
  }

  late IAmGoingProvider _IAmGoingDataProvider;
  String? messageId;

  bool _isLoading = false;
  bool _isGoing = false;
  Color _buttonColor = Colors.white;
  Color _borderColor = Color(0xFF034161);
  Color _textColor = Color(0xFF034161);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _IAmGoingDataProvider = Provider.of<IAmGoingProvider>(context);
    _isLoading = _IAmGoingDataProvider.isLoading(messageId);
    _isGoing = _IAmGoingDataProvider.registeredEvents!.contains(messageId);
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
    var isOverCount = _IAmGoingDataProvider.isOverCount(messageId);

    // print('messageId "' + messageId + '" isOverCount: ' + isOverCount.toString());

    var currCount = _IAmGoingDataProvider.count(messageId);
    var countText = currCount == 1
        ? '$currCount student is going'
        : '$currCount students are going';

    return Container(
        margin: EdgeInsets.only(top: 10.0),
        child: Row(
          children: <Widget>[
            Container(
              height: 25,
              width: 150,
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
                        margin: EdgeInsets.only(top: 2.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.report, color: Colors.grey, size: 10),
                            Text("There may not be enough food",
                                style: TextStyle(fontSize: 9))
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
            _checkBoxButton()
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
        _IAmGoingDataProvider.decrementCount(messageId!);
      } else {
        _buttonColor = Colors.green;
        _borderColor = Colors.green;
        _textColor = Colors.white;
        _IAmGoingDataProvider.incrementCount(messageId!);
      }
      _isGoing = !_isGoing;
    });
  }
}

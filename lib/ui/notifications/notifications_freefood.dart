import 'package:campus_mobile_experimental/core/providers/notifications_freefood.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FreeFoodNotification extends StatefulWidget {
  /// required parameters
  final String messageId;

  const FreeFoodNotification({
    Key key,
    @required this.messageId,
  }) : super(key: key);

  @override
  _CheckBoxButtonState createState() => _CheckBoxButtonState(messageId);
}

class _CheckBoxButtonState extends State<FreeFoodNotification> {
  _CheckBoxButtonState(messageId) {
    this.messageId = messageId;
  }

  FreeFoodDataProvider _freeFoodDataProvider;
  String messageId;

  bool _isLoading = false;
  bool _isGoing = false;
  Color _buttonColor = Colors.white;
  Color _borderColor = Color(0xFF034161);
  Color _textColor = Color(0xFF034161);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _freeFoodDataProvider = Provider.of<FreeFoodDataProvider>(context);
    _isLoading = _freeFoodDataProvider.isLoading(messageId);
    _isGoing = _freeFoodDataProvider.registeredEvents.contains(messageId);
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
    var isOverCount = _freeFoodDataProvider.isOverCount(messageId);

    // print('messageId "' + messageId + '" isOverCount: ' + isOverCount.toString());

    var currCount = _freeFoodDataProvider.count(messageId);
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
                                onChanged: (bool val) {
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
        _freeFoodDataProvider.decrementCount(messageId);
      } else {
        _buttonColor = Colors.green;
        _borderColor = Colors.green;
        _textColor = Colors.white;
        _freeFoodDataProvider.incrementCount(messageId);
      }
      _isGoing = !_isGoing;
    });
  }
}

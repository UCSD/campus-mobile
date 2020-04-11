import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/models/free_food_model.dart';
import 'package:campus_mobile_experimental/core/data_providers/free_food_data_provider.dart';
import 'dart:developer';
import 'package:provider/provider.dart';

class FreeFoodNotification extends StatefulWidget {
  @override
  _CheckBoxButtonState createState() => _CheckBoxButtonState();
}

class _CheckBoxButtonState extends State<FreeFoodNotification> {
  FreeFoodDataProvider _freeFoodDataProvider;

  bool _isGoing = false;
  Color _buttonColor = Colors.white;
  Color _borderColor = Color(0xFF034161);
  Color _textColor = Color(0xFF034161);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _freeFoodDataProvider = Provider.of<FreeFoodDataProvider>(context);
        print(_freeFoodDataProvider.freeFoodModel.body.count);
  }

  @override
  Widget build(BuildContext context) {
    FreeFoodModel model = _freeFoodDataProvider.freeFoodModel;
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                '${model.body.count} students are going',
                style: TextStyle(fontSize: 10, color: Colors.green)),
              Container(
                margin: EdgeInsets.only(top: 2.0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.report, color: Colors.grey, size: 10),
                    Text(
                      "There may not be enough food",
                      style: TextStyle(fontSize: 9)
                    )
                  ],
                )
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          _checkBoxButton()
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      )
    );
  }

  Widget _checkBoxButton() {
    return Container(
      height: 20,
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
      child: Material(
        color: _buttonColor,
        child: InkWell(
          onTap: () {
            print("im going");
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
                    )
                  )
                ),
                Text(
                  "I'm Going!",
                  style: TextStyle(color: _textColor, fontSize: 10)
                ),
              ],
            )
          ),
        )
      )
    );
  }

  void _toggleGoing() {
    setState(() {
      _isGoing = !_isGoing;
      if (_isGoing) {
        _buttonColor = Colors.green;
        _borderColor = Colors.green;
        _textColor = Colors.white;
        _freeFoodDataProvider.decrementCount("1");
        _freeFoodDataProvider.fetchCount();
      } else {
        _buttonColor = Colors.white;
        _borderColor = Color(0xFF034161);
        _textColor = Color(0xFF034161);
        _freeFoodDataProvider.incrementCount("1");
        _freeFoodDataProvider.fetchCount();
      }
    });
  }
}
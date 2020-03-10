import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

class NotificationsListView extends StatelessWidget {
  void _updateData(BuildContext context) {
    if (!Provider.of<MessagesDataProvider>(context).isLoading) {
      if (Provider.of<UserDataProvider>(context) != null &&
          Provider.of<UserDataProvider>(context).isLoggedIn) {
        Provider.of<MessagesDataProvider>(context).retrieveMoreMyMessages();
        print("pagination here");
      } else {
        Provider.of<MessagesDataProvider>(context).retrieveMoreTopicMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        //double previousMaxScroll = _scrollController.position.pixels;
        _updateData(context);
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    //print(_data);
    return RefreshIndicator(
        child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount:
                Provider.of<MessagesDataProvider>(context).messages.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                  children: _buildMessage(
                      context,
                      Provider.of<MessagesDataProvider>(context)
                          .messages[index]));
            }),
        onRefresh: () => _handleRefresh(context));
  }

  List<Widget> _buildMessage(BuildContext context, MessageElement data) {
    bool _isFreeFood = data.message.message.contains('Free'); 
    return [
      ListTile(
        leading: Icon(Icons.info, color: Colors.grey, size: 30),
        title: Column(
          children: <Widget>[
            Text(_readTimestamp(data.timestamp),
                style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text(data.message.title),
            Padding(padding: const EdgeInsets.all(3.5))
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        subtitle: Column(
          children: <Widget>[
            Linkify(
              text: data.message.message,
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                    await launch(link.url);
                } else {
                    throw 'Could not launch $link';
                }
              },
              options: LinkifyOptions(humanize: false),
              style: TextStyle(fontSize: 12.5)
            ),
            _isFreeFood ? _freeFoodNotification() : SizedBox()
          ]
        )
      ),
      Divider()
    ];
  }

  String _readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if(diff.inSeconds < 60){
      if(diff.inSeconds.floor() == 1){
        time = diff.inMinutes.toString() + ' SECOND AGO';
      }
      else{
        time = diff.inMinutes.toString() + ' SECONDS AGO';
      }
    }
    else if(diff.inMinutes < 60) {
      if (diff.inMinutes.floor() == 1) {
        time = diff.inMinutes.toString() + ' MINUTE AGO';
      } else {
        time = diff.inMinutes.toString() + ' MINUTES AGO';
      }
    } else if (diff.inHours < 24) {
      if (diff.inHours.floor() == 1) {
        time = diff.inHours.toString() + ' HOUR AGO';
      } else {
        time = diff.inHours.toString() + ' HOURS AGO';
      }
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else if (diff.inDays >= 7 && diff.inDays < 365) {
      if (diff.inDays.floor() == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    } else {
      time = ((diff.inDays / 7).floor() / 52).floor().toString() + ' YEAR AGO';
    }

    return time;
  }

  Future<Null> _handleRefresh(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3), () {
      Provider.of<MessagesDataProvider>(context).fetchMessages();
    });
  }

  Widget _freeFoodNotification() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                "45 students are going",
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
          CheckBoxButton()
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      )
    );
  }
}

class CheckBoxButton extends StatefulWidget {
  @override
  _CheckBoxButtonState createState() => _CheckBoxButtonState();
}

class _CheckBoxButtonState extends State<CheckBoxButton> {
  bool _isGoing = false;
  Color _buttonColor = Colors.white;
  Color _borderColor = Color(0xFF034161);
  Color _focusColor = Colors.grey;
  Color _textColor = Color(0xFF034161);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 110,
      padding: EdgeInsets.only(right: 10.0),
      child: FlatButton(
        color: _buttonColor,
        focusColor: _focusColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _borderColor),
          borderRadius: BorderRadius.circular(3.0),
        ),
        onPressed: (){
          _toggleGoing();
        }, 
        child: Row(
          children: <Widget>[
            _isGoing ? 
            Stack(
              children: <Widget>[
                Center(
                child: Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(1.0)),
                    color: Colors.white,
                  ),
                )),
                Center(
                  child: Icon(
                    Icons.check,
                    size: 10.0,
                    color: Colors.green,
                ))
              ]
            ):  
            Icon(
              Icons.check_box_outline_blank,
              size: 13.0,
              color: _borderColor,
            ),
            Text(
              "I'm Going!",
              style: TextStyle(color: _textColor, fontSize: 10)
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        _focusColor = Color(0x00468b);
        _textColor = Colors.white;
      } else {
        log(_isGoing.toString());
        _buttonColor = Colors.white;
        _borderColor = Color(0xFF034161);
        _focusColor = Colors.grey;
        _textColor = Color(0xFF034161);
        log(_textColor.toString());
      }
    });
  }
}

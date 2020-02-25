import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'dart:async';

class NotificationsListView extends StatelessWidget {
  void _updateData(BuildContext context) {
    if (!Provider.of<MessagesDataProvider>(context).isLoading) {
      if (Provider.of<UserDataProvider>(context) != null &&
          Provider.of<UserDataProvider>(context).isLoggedIn) {
        Provider.of<MessagesDataProvider>(context).retrieveMoreMyMessages();
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
        _updateData(context);
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
        subtitle: Text(data.message.message, style: TextStyle(fontSize: 12.5)),
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
}

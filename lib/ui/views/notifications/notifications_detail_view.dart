import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:intl/intl.dart';

class NotificationsDetailView extends StatelessWidget{
  MessagesDataProvider _messagesDataProvider;
  
  @override
  Widget build(BuildContext context) {
    _messagesDataProvider = Provider.of<MessagesDataProvider>(context);
    List<MessageElement> data = _messagesDataProvider.messages;

    return RefreshIndicator(
      child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(children: _buildMessage(context, data[index]));
          }
      ), 
      onRefresh: _handleRefresh);
  }

  List<Widget> _buildMessage(BuildContext context, MessageElement data){
    return [
      ListTile(
        leading: FlutterLogo(size: 20),
        title: Column(children: <Widget>[
          Text(
            readTimestamp(data.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey)
          ),
          Text(data.message.title),
          Padding(padding: const EdgeInsets.all(3.5))
        ],
        crossAxisAlignment: CrossAxisAlignment.start,),
        subtitle: Text(
          data.message.message,
          style: TextStyle(
            fontSize: 12.5
          )),
      ),
      Divider()
    ];
  }

  String readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inHours < 24) {
      time = diff.inHours.toString() + ' HOURS AGO';
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else if (diff.inDays >= 7 && diff.inDays < 365) {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    } else{
      time = ((diff.inDays / 7).floor() / 52).floor().toString() + ' YEAR AGO';
    }

    return time;
  }

  Future<Null> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 5), () {
      _messagesDataProvider.fetchMessages();
    });
  }

}
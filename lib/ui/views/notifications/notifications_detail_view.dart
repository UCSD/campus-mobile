import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';

class NotificationsDetailView extends StatelessWidget{
  NotificationsDetailView(List<MessageElement> data,Function reload){
    _data = data;
    _reload = reload;
    //print(_data);
  }

  List<MessageElement> _data;
  Function _reload;
  
  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
        _scrollController.position.pixels) {
        _reload();
      }
    });

    //print(_data);
    return RefreshIndicator(
      child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _data.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(children: _buildMessage(context, _data[index]));
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
            _readTimestamp(data.timestamp),
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

  String _readTimestamp(int timestamp) {
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
    print("called");
    _reload();
  }

}
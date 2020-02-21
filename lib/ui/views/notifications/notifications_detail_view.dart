import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'dart:async';

class NotificationsDetailView extends StatelessWidget{
  NotificationsDetailView(List<MessageElement> data){
    _data = data;
  }

  List<MessageElement> _data;
  MessagesDataProvider _messagesDataProvider;
  UserDataProvider _userDataProvider;

  void _updateData(){
    if(!_messagesDataProvider.isLoading){
      print("called");
      if(_userDataProvider != null && _userDataProvider.isLoggedIn){
        _messagesDataProvider.retrieveMoreMyMessages();
      }
      else{
        _messagesDataProvider.retrieveMoreTopicMessages();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    _messagesDataProvider = Provider.of<MessagesDataProvider>(context);
    _userDataProvider = Provider.of<UserDataProvider>(context);
    ScrollController _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
        _scrollController.position.pixels) {
        _updateData();
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
        leading: Icon(
          Icons.info,
          color: Colors.grey,
          size: 30
        ),
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


    if(diff.inMinutes < 60){
      if(diff.inMinutes.floor() == 1){
        time = diff.inMinutes.toString() + ' MINUTE AGO';
      }
      else{
        time = diff.inMinutes.toString() + ' MINUTES AGO';
      }
    }
    else if (diff.inHours < 24) {
      if(diff.inHours.floor() == 1){
        time = diff.inHours.toString() + ' HOUR AGO';
      }
      else{
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
    } else{
      time = ((diff.inDays / 7).floor() / 52).floor().toString() + ' YEAR AGO';
    }

    return time;
  }

  Future<Null> _handleRefresh() async {
    print("called handleRefresh");
    await Future.delayed(const Duration(seconds: 2),(){
      _messagesDataProvider.refreshMessages();
    });
  }

}
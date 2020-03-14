import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class NotificationsListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationsListViewState();
}

class _NotificationsListViewState extends State<NotificationsListView>{

  @override
  void initState(){
    super.initState();

    _scrollController.addListener((){
      if(_scrollController.position.maxScrollExtent <= _scrollController.offset){
        _updateData(context);
      }
    });
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }

  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false;

  void _updateData (BuildContext context) async {
    if (!Provider.of<MessagesDataProvider>(context).isLoading) {
      if (Provider.of<UserDataProvider>(context) != null &&
          Provider.of<UserDataProvider>(context).isLoggedIn) {
        setState(() => isPerformingRequest = true);
        Provider.of<MessagesDataProvider>(context).retrieveMoreMyMessages();
        setState(() => isPerformingRequest = false);
      } else {
        setState(() => isPerformingRequest = true);
        Provider.of<MessagesDataProvider>(context).retrieveMoreTopicMessages();
        setState(() => isPerformingRequest = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Provider.of<MessagesDataProvider>(context).messages[index]
                  )
              );
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
        subtitle: Linkify(
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
}

import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';

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
            "1 hr ago",
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey)
          ),
          Text("Test Message"),
          Padding(padding: const EdgeInsets.all(3.5))
        ],
        crossAxisAlignment: CrossAxisAlignment.start,),
        subtitle: Text(
          "test 1",
          style: TextStyle(
            fontSize: 12.5
          )),
      ),
      Divider()
    ];
  }

  Future<Null> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 10), () {
      _messagesDataProvider.fetchMessages();
      print("in here");
    });
  }

}
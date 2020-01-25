import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Notifications extends StatelessWidget {
  Future<Null> _handleRefresh() async {
        await Future.delayed(Duration(seconds: 0), () {
          print('refresh');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(flex: 1, child: RefreshIndicator(
        child:
     ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
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
      Divider(),
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
          "test 2",
          style: TextStyle(
            fontSize: 12.5
          )),
      ),
      Divider(),
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
          "test 3",
          style: TextStyle(
            fontSize: 12.5
          )),
      ),
      Divider()
    ],), onRefresh: _handleRefresh,))],);
  }
}

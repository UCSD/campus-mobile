import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Notifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider.of<MessagesDataProvider>(context).isLoading
      ? Center() : 

    return Container(
      child: Messages()
    );
  }
}

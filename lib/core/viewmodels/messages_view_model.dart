import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/services/message_service.dart';
import 'package:campus_mobile_experimental/ui/views/messages/messages_list_view.dart';

class Messages extends StatefulWidget{
  @override
  _MessagesState createState() => _MessagesState();

}

class _MessagesState extends State<Messages>{
  final MessageService _messageService = MessageService();
  //Future<MessageModel> _data;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // _updateMessageData();
  }

  /*_updateMessageData() {
    if(!_messageService.isLoading){
      setState((){
        _data = _messageService.fetchData();
      });
    }
  }*/
  



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Text('yo');
  }

}
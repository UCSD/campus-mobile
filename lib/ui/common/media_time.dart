import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MediaTime extends StatelessWidget {
  final MediaModel? data;
  const MediaTime({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Separate dates from times
      String eventDate = DateFormat.yMd().format(data!.eventDate!.toLocal());
      return Text(eventDate);
    } catch (e) {
      print(e);
      return Container();
    }
  }
}

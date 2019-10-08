import 'package:campus_mobile/core/models/events_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile/ui/widgets/container_view.dart';
import 'package:campus_mobile/ui/widgets/image_loader.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({Key key, @required this.data}) : super(key: key);
  final EventModel data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: Column(
        children: buildDetailView(),
      ),
    );
  }

  List<Widget> buildDetailView() {
    return [
      Center(
        child: ImageLoader(
          url: data.imageHQ,
          fullSize: true,
        ),
      ),
      Text(data.title),
      Text(data.startTime + "-" + data.endTime),
      Text(data.description)
    ];
  }
}

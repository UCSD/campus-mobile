import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:campus_mobile_experimental/ui/common/linkify_with_catch.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({Key key, @required this.data}) : super(key: key);
  final EventModel data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: ListView(
        children: buildDetailView(context),
      ),
    );
  }

  List<Widget> buildDetailView(BuildContext context) {
    return [
      Center(
        child: ImageLoader(
          url: data.imageHQ,
          fullSize: true,
        ),
      ),
      Divider(),
      Text(
        data.title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.title,
      ),
      Divider(),
      LinkifyWithCatch(
        text: data.location,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      Center(
          child: TimeRangeWidget(time: data.startTime + ' - ' + data.endTime)),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: LinkifyWithCatch(
          text: data.description,
          style: TextStyle(fontSize: 16),
        ),
      ),
      data.url != null && data.url.isNotEmpty
          ? LearnMoreButton(link: data.url)
          : Container(),
    ];
  }
}

class LearnMoreButton extends StatelessWidget {
  const LearnMoreButton({Key key, @required this.link}) : super(key: key);
  final String link;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FlatButton(
          child: Text(
            'Learn More',
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).textTheme.button.color),
          ),
          color: Theme.of(context).buttonColor,
          onPressed: () async {
            try {
              if (await canLaunch(link)) {
                await launch(link);
              } else {
                throw 'Could not launch $link';
              }
            } catch (e) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Could not open.'),
              ));
            }
          }),
    );
  }
}

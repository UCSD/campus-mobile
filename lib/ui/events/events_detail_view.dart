

import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/event_time.dart';
import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:campus_mobile_experimental/ui/common/linkify_with_catch.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({Key? key, required this.data}) : super(key: key);
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
        data.title!,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline6,
      ),
      Divider(),
      data.location != null && data.location!.isNotEmpty
          ? LinkifyWithCatch(
              text: data.location,
              looseUrl: true,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            )
          : Container(),
      Center(child: EventTime(data: data)),
      Divider(),
      data.description != null && data.description!.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinkifyWithCatch(
                text: data.description,
                style: TextStyle(fontSize: 16),
              ),
            )
          : Container(),
      data.link != null && data.link!.isNotEmpty
          ? LearnMoreButton(link: data.link)
          : Container(),
    ];
  }
}

class LearnMoreButton extends StatelessWidget {
  const LearnMoreButton({Key? key, required this.link}) : super(key: key);
  final String? link;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
          child: Text(
            'Learn More',
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).textTheme.button!.color),
          ),
          style: TextButton.styleFrom(
            primary: Theme.of(context).buttonColor,
          ),
          onPressed: () async {
            try {
              await launch(link!, forceSafariVC: true);
            } catch (e) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Could not open.'),
              ));
            }
          }),
    );
  }
}

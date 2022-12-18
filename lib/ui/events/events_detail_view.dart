import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/event_time.dart';
import 'package:campus_mobile_experimental/ui/common/linkify_with_catch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({Key? key, required this.data}) : super(key: key);
  final EventModel data;
  @override
  Widget build(BuildContext context) {
    return Provider.of<EventsDataProvider>(context).isLoading!
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : ContainerView(
            child: buildDetailView(context),
          );
  }

  Widget buildDetailView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ListView(
      children: [
        Container(
          width: width,
          height: height * 0.33,
          decoration: BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.fill,
            image: (data.imageHQ!.isEmpty)
                ? AssetImage('assets/images/UCSDMobile_banner.png')
                    as ImageProvider
                : NetworkImage(data.imageHQ!),
          )),
        ),
        Container(
          child: Center(
            child: Container(
              width: width * 0.8,
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    data.title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  data.location != null && data.location!.isNotEmpty
                      ? LinkifyWithCatch(
                          text: "Where: " + data.location!,
                          looseUrl: true,
                          style: TextStyle(
                              fontSize: 16,
                              height: 1.3,
                              color: Theme.of(context).primaryColor),
                          textAlign: TextAlign.center,
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  Center(child: EventTime(data: data)),
                  data.description != null && data.description!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            data.description!,
                            style: TextStyle(fontSize: 16, height: 1.3),
                          ),
                        )
                      : Container(),
                  data.link != null && data.link!.isNotEmpty
                      ? LearnMoreButton(link: data.link)
                      : Container(),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class LearnMoreButton extends StatelessWidget {
  const LearnMoreButton({Key? key, required this.link}) : super(key: key);
  final String? link;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            onPrimary: Theme.of(context).primaryColor, // foreground
            // primary: Theme.of(context).buttonColor,
            primary: Theme.of(context).backgroundColor,
          ),
          child: Text(
            'Learn More',
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).textTheme.button!.color),
          ),
          onPressed: () async {
            try {
              await launch(link!, forceSafariVC: true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Could not open.'),
              ));
            }
          }),
    );
  }
}

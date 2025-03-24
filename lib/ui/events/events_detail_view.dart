import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/linkify_with_catch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_styles.dart';
import '../common/event_time.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({Key? key, required this.data}) : super(key: key);

  /// MODELS
  final EventModel data;

  @override
  Widget build(BuildContext context) {
    return Provider.of<EventsDataProvider>(context).isLoading? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : ContainerView(child: buildDetailView(context));
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
            image: (data.imageHQ.isEmpty)
                ? AssetImage('assets/images/UCSDMobile_banner.png')
                    as ImageProvider
                : NetworkImage(data.imageHQ),
          )),
        ),
        Container(
          child: Center(
            child: Container(
              width: width * 0.9,
              child: Column(
                children: [
                  // THIS ICON IS NOT USED
                  // Icon(
                  //   Icons.keyboard_arrow_down,
                  //   size: 30,
                  //   color: Theme.of(context).primaryColor,
                  // ),
                  // IT WORKED AS A PADDING OF SIZE 30
                  // INCLUDED A SizedBox OF HEIGHT 30 INSTEAD
                  SizedBox(height: 30),
                  // Event Title
                  Padding(
                    padding: const EdgeInsets.only(left: 65.0), // Adjust the left padding as needed
                    child: Text(
                      data.title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Event Location
                  data.location != null && data.location!.isNotEmpty
                      ? LinkifyWithCatch(
                          text: data.location!,
                          looseUrl: true,
                          style: TextStyle(
                              fontSize: 16,
                              height: 1.3,
                              color: Theme.of(context).primaryColor),
                          textAlign: TextAlign.left,
                        )
                      : Container(),
                  SizedBox(height: 10),
                  // Event Time and Date
                  Center(child: EventTime(data: data)),
                  // Horizontal Division
                  Divider(
                    color: listTileDividerColorDark,
                    thickness: 0.6
                  ),
                  // Event Description
                  data.description != null && data.description!.isNotEmpty
                      ? Text(
                            data.description!,
                            style: TextStyle(
                                fontSize: 16, height: 1.4,
                                fontWeight: FontWeight.w400
                            ),
                          )
                      : Container(),
                  // "GO TO EVENT PAGE" Button
                  data.link != null && data.link!.isNotEmpty
                      ? LearnMoreButton(link: data.link!)
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
  final String link;
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 18,
      color: lightPrimaryColor,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: actionButtonBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GO TO EVENT PAGE', style: textStyle),
              SizedBox(width: 4),
              Icon(
                Icons.open_in_new, size: textStyle.fontSize,
                color: textStyle.color
              )
            ],
          ),
          onPressed: () async {
            try {
              await launch(link, forceSafariVC: true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Could not open.'),
              ));
            }
          }),
    );
  }
}

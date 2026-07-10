import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/linkify_with_catch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/ui/events/event_tile.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({Key? key, required this.data}) : super(key: key);

  /// MODELS
  final EventModel data;

  @override
  Widget build(BuildContext context) {
    return Provider.of<EventsDataProvider>(context).isLoading
        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary))
        : ContainerView(child: buildDetailView(context));
  }

  Widget buildDetailView(BuildContext context) {
    return ListView(
      children: [
        // Event Image
        EventImage(data: data),
        // Event Content
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Event Date
              Builder(builder: (context) {
                final df = DateFormat("MMM d y");
                final localStart = data.startDate.toLocal();
                final localEnd = data.endDate.toLocal();
                final startDate = df.format(localStart);
                final endDate = df.format(localEnd);
                final dateDisplay = startDate == endDate ? startDate : '$startDate - $endDate';
                return StartEndDateContainer(date: dateDisplay);
              }),

              // Event Title
              Expanded(child: EventTitle(title: data.title)),
            ],
          ),
        ),
        Container(
            padding: const EdgeInsets.only(left: 17.0),
            child: Row(children: [
              // Event Location
              Icon(
                Icons.location_on_sharp,
                size: 36,
                color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
              ),
              SizedBox(width: 5),
              Expanded(
                child: data.location != null && data.location!.isNotEmpty
                    ? Semantics(
                        label: 'Location: ',
                        child: LinkifyWithCatch(
                          text: data.location!,
                          looseUrl: true,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    : Container(),
              ),
              SizedBox(width: 5),
              // Event Time
              Builder(builder: (context) {
                final timeString = data.startDate.toLocal().hour == 0 && data.endDate.toLocal().hour == 23
                    ? '    All day     '
                    : DateFormat.jm().format(data.startDate.toLocal()) +
                        ' - ' +
                        DateFormat.jm().format(data.endDate.toLocal());
                final semanticTime = 'From: ' + timeString.replaceAll('-', 'to').trim();
                return Semantics(
                  container: true,
                  child: Text(
                    timeString,
                    semanticsLabel: semanticTime,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }),
              SizedBox(width: 16),
            ])),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ///////////////// Horizontal Division ///////////////////
                Divider(color: listTileDividerColorDark, thickness: 0.6),
                // Event Description
                data.description != null && data.description!.isNotEmpty
                    ? Text(
                        data.description!,
                        semanticsLabel: 'Event Description and Details: ${data.description}',
                        style: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w400),
                      )
                    : Container(),
              ],
            )),
        Container(
          padding: EdgeInsets.only(left: 15, top: 5, right: 248, bottom: 20),
          // "GO TO EVENT PAGE" Button
          child: data.link != null && data.link!.isNotEmpty ? GoToEventPageButton(link: data.link!) : Container(),
        )
      ],
    );
  }
}

// CREATE EVENT IMAGE
class EventImage extends StatelessWidget {
  final EventModel data;
  const EventImage({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String fallbackTitle = data.title;
    if (fallbackTitle.length > 40) fallbackTitle = fallbackTitle.substring(0, 40) + '...';
    String semanticLabel = data.imageAltText ?? fallbackTitle;

    // Add spaces between consecutive uppercase letters so TalkBack spells acronyms out
    semanticLabel = semanticLabel.replaceAllMapped(
      RegExp(r'[A-Z]{2,}'),
      (match) => match.group(0)!.split('').join(' '),
    );

    return Semantics(
      image: true,
      label: semanticLabel,
      child: Container(
        height: MediaQuery.of(context).size.width / 2.1,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover, // Ensure the image fills the container
            image: (data.imageHQ.isEmpty)
                ? AssetImage('assets/images/UCSDMobile_banner.png') as ImageProvider
                : NetworkImage(data.imageHQ),
          ),
        ),
      ),
    );
  }
}

// CREATE EVENT TITLE
class EventTitle extends StatelessWidget {
  final String title;
  const EventTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text(
              title,
              semanticsLabel: 'Event: $title',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CREATE GO TO EVENT PAGE BUTTON
class GoToEventPageButton extends StatelessWidget {
  const GoToEventPageButton({Key? key, required this.link}) : super(key: key);
  final String link;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: actionButtonBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            try {
              await launch(link, forceSafariVC: true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open.')));
            }
          },
          child: FittedBox(
            child: Row(
              children: [
                Text('GO TO EVENT PAGE', style: TextStyle(fontSize: 18, color: lightPrimaryColor)),
                SizedBox(width: 4),
                Icon(Icons.open_in_new, size: 18, color: lightPrimaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

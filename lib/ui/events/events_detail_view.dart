import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/linkify_with_catch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_styles.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({Key? key, required this.data}) : super(key: key);

  /// MODELS
  final EventModel data;

  @override
  Widget build(BuildContext context) {
    return Provider.of<EventsDataProvider>(context).isLoading
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : ContainerView(child: buildDetailView(context));
  }

  /// TODO: What color to use for dark theme?
  Widget buildDetailView(BuildContext context) {
    return ListView(
      children: [
        // Event Image
        EventImage(imageUrl: data.imageHQ),
        // Event Content
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Event Start Date
              StartDateContainer(
                  date: DateFormat("MMM d y").format(data.startDate.toLocal())),
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
                color: Theme.of(context).brightness == Brightness.light
                    ? lightPrimaryColor
                    : Colors.white,
              ),
              SizedBox(width: 5),
              Expanded(
                child: data.location != null && data.location!.isNotEmpty
                    ? LinkifyWithCatch(
                        text: data.location!,
                        looseUrl: true,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? lightPrimaryColor
                                  : Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : Container(),
              ),
              SizedBox(width: 5),
              // Event Time
              Text(
                DateFormat.jm().format(data.startDate.toLocal()) +
                    ' - ' +
                    DateFormat.jm().format(data.endDate.toLocal()),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.light
                      ? lightPrimaryColor
                      : Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
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
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w400),
                      )
                    : Container(),
              ],
            )),
        Container(
          padding: EdgeInsets.only(left: 15, top: 5, right: 248, bottom: 20),
          // "GO TO EVENT PAGE" Button
          child: data.link != null && data.link!.isNotEmpty
              ? GoToEventPageButton(link: data.link!)
              : Container(),
        )
      ],
    );
  }
}

// CREATE EVENT IMAGE
class EventImage extends StatelessWidget {
  final String imageUrl;
  const EventImage({Key? key, required this.imageUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width / 2.1,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover, // Ensure the image fills the container
          image: (imageUrl.isEmpty)
              ? AssetImage('assets/images/UCSDMobile_banner.png')
                  as ImageProvider
              : NetworkImage(imageUrl),
        ),
      ),
    );
  }
}

// CREATE START DATE CONTAINER
class StartDateContainer extends StatelessWidget {
  final String date;
  const StartDateContainer({Key? key, required this.date}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Month
        Text(date.split(' ')[0].toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).brightness == Brightness.light
                  ? lightPrimaryColor
                  : Colors.white,
              fontWeight: FontWeight.w400,
            )),
        // Day
        Text(date.split(' ')[1].toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).brightness == Brightness.light
                  ? lightPrimaryColor
                  : Colors.white,
              fontWeight: FontWeight.w500,
            )),
        // Year
        Text(date.split(' ')[2].toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).brightness == Brightness.light
                  ? lightPrimaryColor
                  : Colors.white,
              fontWeight: FontWeight.w400,
            )),
      ],
    );
  }
}

// CREATE EVENT TITLE
class EventTitle extends StatelessWidget {
  final String title;
  const EventTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.light
                  ? lightPrimaryColor
                  : Colors.white,
            ),
          ),
        ),
      ],
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            try {
              await launch(link, forceSafariVC: true);
            } catch (e) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Could not open.')));
            }
          },
          child: FittedBox(
            child: Row(
              children: [
                Text('GO TO EVENT PAGE',
                    style: TextStyle(fontSize: 18, color: lightPrimaryColor)),
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

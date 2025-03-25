import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/event_time.dart';

class EventTile extends StatelessWidget {
  const EventTile({Key? key, required this.data}) : super(key: key);

  final EventModel data;

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is loading
    if (Provider.of<EventsDataProvider>(context).isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }

    return _buildEventTile(context);
  }

  Widget _buildEventTile(BuildContext context) {
    return Container(
      width: 190,
      height: 300,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            RoutePaths.EventDetailView,
            arguments: data,
          );
        },
        child: Column(
          children: [
            _eventImageLoader(data.imageThumb),
            _eventDetailsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _eventImageLoader(String? url) {
    // Load either network image or a default image if URL is empty
    return url?.isEmpty ?? true
        ? Image.asset(
      'assets/images/UCSDMobile_sharp.png',
      height: 150,
      width: 190,
      fit: BoxFit.fill,
    )
        : Image.network(
      url!,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      height: 150,
      width: 190,
      fit: BoxFit.fill,
    );
  }

  Widget _eventDetailsCard(BuildContext context) {
    return SizedBox(
      height: 145,
      width: 190,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(width: 0.3),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 5)),
                EventTileDateTime(data: data),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

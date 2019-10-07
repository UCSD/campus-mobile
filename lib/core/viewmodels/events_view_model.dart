import 'package:campus_mobile/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile/core/models/events_model.dart';
import 'package:campus_mobile/core/services/event_service.dart';
import 'package:campus_mobile/ui/widgets/image_loader.dart';

class EventsViewModel extends StatefulWidget {
  @override
  _EventsViewModelState createState() => _EventsViewModelState();
}

class _EventsViewModelState extends State<EventsViewModel> {
  final EventsService _eventsService = EventsService();
  Future<List<EventModel>> _data;

  initState() {
    super.initState();
    _updateData();
  }

  _updateData() {
    if (!_eventsService.isLoading) {
      setState(() {
        _data = _eventsService.fetchData();
      });
    }
  }

  Widget buildEventsCard(AsyncSnapshot snapshot) {
    return buildEventsList(snapshot, 3);
  }

  Widget buildEventsList(AsyncSnapshot snapshot, int listSize) {
    if (snapshot.hasData) {
      final List<EventModel> data = snapshot.data;
      final List<Widget> eventTiles = List<Widget>();
      //data.length instead of 3
      for (int i = 0; i < listSize; i++) {
        final EventModel item = data[i];
        final tile = buildEventTile(
            item.shortDescription, item.description, item.imageThumb);
        eventTiles.add(tile);
      }
      return Flexible(
        child: Column(
          children: ListTile.divideTiles(tiles: eventTiles, context: context)
              .toList(),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.start,
    );
  }

  Widget buildEventTile(String title, String subtitle, String imageURL) {
    return ListTile(
      title: Text(
        title,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: ImageLoader(url: imageURL),
    );
  }

  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {/*TODO navigate to view with full news list*/},
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventModel>>(
      future: _data,
      builder: (context, snapshot) {
        return CardContainer(
          /// TODO: need to hook up hidden to state using provider
          hidden: false,
          reload: () => _updateData(),
          isLoading: _eventsService.isLoading,
          title: buildTitle("Events"),
          errorText: _eventsService.error,
          child: buildEventsCard(snapshot),
          actionButtons: buildActionButtons(),
        );
      },
    );
  }
}

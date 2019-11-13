import 'package:campus_mobile_beta/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/core/models/events_model.dart';
import 'package:campus_mobile_beta/core/services/event_service.dart';
import 'package:campus_mobile_beta/core/constants/app_constants.dart';
import 'package:campus_mobile_beta/ui/views/events/events_list.dart';
import 'package:provider/provider.dart';

class EventsViewModel extends StatefulWidget {
  @override
  _EventsViewModelState createState() => _EventsViewModelState();
}

class _EventsViewModelState extends State<EventsViewModel> {
  EventsService _eventsService;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _eventsService = Provider.of<EventsService>(context);
  }

  _updateData() {
    if (!_eventsService.isLoading) {
      _eventsService.fetchData();
    }
  }

  Widget buildEventsCard(List<EventModel> data) {
    if (data != null && data.length > 0) {
      return EventsList(data: data, listSize: 3);
    } else {
      /// no news could be fetched here
      return Container();
    }
  }

  List<Widget> buildActionButtons(List<EventModel> data) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.EventsViewAll, arguments: data);
      },
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      /// TODO: need to hook up hidden to state using provider
      hidden: false,
      reload: () => _updateData(),
      isLoading: _eventsService.isLoading,
      title: Text("Events"),
      errorText: _eventsService.error,
      child: buildEventsCard(_eventsService.data),
      actionButtons: buildActionButtons(_eventsService.data),
    );
  }
}

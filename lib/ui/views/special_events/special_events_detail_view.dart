import 'package:campus_mobile_beta/core/models/special_events_model.dart';
import 'package:campus_mobile_beta/core/services/special_events_service.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/ui/widgets/container_view.dart';

class SpecialEventsViewModel extends StatefulWidget {
  @override
  _SpecialEventsViewModelState createState() => _SpecialEventsViewModelState();
}

class _SpecialEventsViewModelState extends State<SpecialEventsViewModel> {
  final SpecialEventsService _specialEventsService = SpecialEventsService();
  Future<SpecialEventsModel> _data;

  initState() {
    super.initState();
    _updateData();
  }

  _updateData() {
    if (!_specialEventsService.isLoading) {
      setState(() {
        _data = _specialEventsService.fetchData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContainerView(
        child: Column(children: <Widget>[buildDetailView(context)]));
  }

  Widget buildDetailView(BuildContext context) {
    return FutureBuilder<SpecialEventsModel>(
      future: _data,
      builder: (context, specEventsSnap) {
        if (specEventsSnap.connectionState == ConnectionState.none ||
            specEventsSnap.hasData == null) {
          return Container();
        }
        return buildEventsCard(specEventsSnap);
      },
    );
  }

  Widget buildEventsCard(AsyncSnapshot<SpecialEventsModel> snapshot) {
    if (snapshot.hasData) {
      final SpecialEventsModel data = snapshot.data;
      List<String> uids = selectEvents(data);
      return new Expanded(
          child: ListView.builder(
              itemCount: uids.length,
              itemBuilder: (BuildContext ctxt, int index) =>
                  buildEventWidget(ctxt, index, data, uids)));
    } else {
      return Container();
    }
  }

  List<String> selectEvents(SpecialEventsModel data) {
    String dateSelected = "2018-09-23"; //TODO v2 make this dynamic
    return data.dateItems[dateSelected];
  }

  Widget buildEventWidget(BuildContext ctxt, int index, SpecialEventsModel data,
      List<String> uids) {
    return Text("Hello from " + uids[index]);
  }
}

import 'package:campus_mobile_beta/core/models/special_events_model.dart';
import 'package:campus_mobile_beta/core/services/special_events_service.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/ui/widgets/container_view.dart';
import 'package:intl/intl.dart';

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
                  buildEventWidget(ctxt, data, uids[index])));
    } else {
      return Container();
    }
  }

  List<String> selectEvents(SpecialEventsModel data) {
    String dateSelected = "2018-09-23"; //TODO v2 make this dynamic
    return data.dateItems[dateSelected];
  }

  Widget buildEventWidget(
      BuildContext ctxt, SpecialEventsModel data, String uid) {
    Schedule event = data.schedule[uid];
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      //dense: true,
      leading: timeWidget(event),
      title: titleWidget(event),
      subtitle: buildSubtitle(event),
      trailing: buildTrailing(event),
    );
  }

  // Container(
  //             width: 1,
  //             height: 50,
  //             color: Colors.grey,
  //           ),

  Widget timeWidget(Schedule event) {
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(event.startTime);
    return Text(new DateFormat.jm().format(dateTime));
  }

  Widget titleWidget(Schedule event){
    return Text(event.talkTitle);
  }

  Widget buildSubtitle(Schedule event) {
    Color labelTheme = HexColor(event.labelTheme);
    return Text(
      event.label,
      style: TextStyle(color: labelTheme),
    );
  }

  Widget buildTrailing(Schedule event){
    bool isGoing = true; //TODO add personal event list after state management is done
    if(isGoing){
      return Icon(Icons.star, color: Colors.yellow , size: 54, semanticLabel: 'Starred' );
    }
    else
    return Icon(Icons.star_border, color: Colors.yellow , size: 54, semanticLabel: 'Not Starred' );
  }
}

//Helper class to convert RGB to ARGB for flutter
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

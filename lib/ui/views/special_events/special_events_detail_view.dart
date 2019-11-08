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
  String currentDateSelection = "2018-09-22";

  bool isFull = true;
  
  //This will need to be stored in state so that its not reset everytime!
  Map<String,bool> myEventList;
  
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
      
      //initialize myEvents list if its null
      if (myEventList == null) {
        myEventList = new Map<String,bool>();
        data.uids.forEach((f) => myEventList[f] = false);
      }

      List<String> uids = selectEvents(data);
      return new Column(children: <Widget>[
        SizedBox(
            height: 50,
            child: ListView(
                scrollDirection: Axis.horizontal,
                children: buildDateWidgets(data.dates))),
        SizedBox(
          height: 500,
          child: ListView.builder(
              itemCount: uids.length,
              itemBuilder: (BuildContext ctxt, int index) =>
                  buildEventWidget(ctxt, data, uids[index])),
        ),
        buildBottomBar(context),
      ]);
    } else {
      return Container();
    }
  }

  List<Widget> dateButtonList;
  List<Widget> buildDateWidgets(List<DateTime> dates) {
    dateButtonList = new List<Widget>();
    dates.forEach((f) => dateButtonList.add(FlatButton(
          color: Colors.white,
          textColor: Colors.black,
          disabledColor: Colors.grey,
          disabledTextColor: Colors.black,
          padding: EdgeInsets.all(8.0),
          splashColor: Colors.blueAccent,
          focusColor: Colors.blue,
          onPressed: () {
            String newDateKey = f
                .toIso8601String()
                .substring(0, f.toIso8601String().indexOf("T"));
            currentDateSelection = newDateKey;
            _updateData();
          },
          child: Text(
            new DateFormat("MMMd").format(f),
          ),
        )));
    return dateButtonList;
  }

  List<String> selectEvents(SpecialEventsModel data) {
    return data.dateItems[currentDateSelection];
  }

  Widget buildEventWidget(
      BuildContext ctxt, SpecialEventsModel data, String uid) {
    Schedule event = data.schedule[uid];
    return ListTile(
      contentPadding: EdgeInsets.all(0),
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
  //           ), TODO Add line ?

  Widget timeWidget(Schedule event) {
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(event.startTime);
    return Text(new DateFormat.jm().format(dateTime));
  }

  Widget titleWidget(Schedule event) {
    return Text(event.talkTitle);
  }

  Widget buildSubtitle(Schedule event) {
    Color labelTheme = HexColor(event.labelTheme);
    return Text(
      event.label,
      style: TextStyle(color: labelTheme),
    );
  }

  //Add event from myList
  void isGoing(String uid){
    myEventList[uid] = true;
    _updateData();
    //return false;
  }

  //Remove event from myList
  void notGoing(String uid){
    myEventList[uid] = false;
    _updateData();
  }

  Widget buildTrailing(Schedule event) {
    if (myEventList[event.id]) {
      return GestureDetector(
          onTap: () {
            notGoing(event.id);
          },
          child: Icon(Icons.star,
              color: Colors.yellow, size: 54, semanticLabel: 'Going'));
    } else
      return GestureDetector(
          onTap: () {
            isGoing(event.id);
          },
          child: Icon(Icons.star_border,
              color: Colors.yellow, size: 54, semanticLabel: 'Not Going'));
  }

  Widget buildBottomBar(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
            height: 67,
            width: MediaQuery.of(context).size.width / 2,
            child: FlatButton(
              color: Colors.white,
              textColor: Colors.black,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              //padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              focusColor: Colors.blue,
              child: Text('Full Schedule'),
              onPressed: () {
                isFull = true;
                _updateData();
              },
            )),
        Container(
            height: 67,
            width: MediaQuery.of(context).size.width / 2,
            child: FlatButton(
              color: Colors.white,
              textColor: Colors.black,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              focusColor: Colors.blue,
              child: Text('My Schedule'),
              onPressed: () {
                isFull = false;
                _updateData();
              },
            ))
      ],
    );
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

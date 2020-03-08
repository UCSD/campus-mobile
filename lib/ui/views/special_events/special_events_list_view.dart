import 'package:campus_mobile_experimental/core/data_providers/special_events_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/special_events_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/HexColor.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SpecialEventsListView extends StatefulWidget {
  @override
  _SpecialEventsListViewState createState() => _SpecialEventsListViewState();
}

class _SpecialEventsListViewState extends State<SpecialEventsListView> {
  SpecialEventsDataProvider dataProvider;

  Map<String, bool> myEventList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    myEventList = Provider.of<SpecialEventsDataProvider>(context).myEventsList;
  }

  @override
  Widget build(BuildContext context) {
    dataProvider = Provider.of<SpecialEventsDataProvider>(context);
    if (dataProvider.error != null) {
      return Center(child: ContainerView(child: Text(dataProvider.error)));
    } else if (dataProvider.isLoading) {
      return ContainerView(child: Center(child: CircularProgressIndicator()));
    }
    return buildDetailView(context);
  }

  Widget buildDetailView(BuildContext context) {
    return buildEventsCard(dataProvider.specialEventsModel);
  }

  // Helper function that adds dynamic scaffold and filter button
  Widget addScaffoldToChild(Widget child) {
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
            title: Center(
                child: dataProvider.appBarTitleText), // Dynamically changed
            actions: <Widget>[
              dataProvider.isFull ? filterButtonEnabled() : Container()
            ]),
      ),
      body: child,
    );
  }

  Widget filterButtonEnabled() {
    return FlatButton(
      child: Text(
        "Filter",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.SpecialEventsFilterView);
      },
    );
  }

  Widget filterButtonDisabled() {
    return Container(child: Opacity(opacity: 0.0, child: Text("Filter")));
  }

  Widget buildEventsCard(SpecialEventsModel data) {
    dataProvider.setTitleText(data.name);

    List<String> uids = dataProvider.selectEvents();
    return addScaffoldToChild(Column(children: <Widget>[
      SizedBox(
          height: 50,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: buildDateWidgets(data.dates))),
      dataProvider.isFull
          ? (dataProvider.filtersApplied ? addFiltersWidget() : Container())
          : Container(),
      SizedBox(
        height: dataProvider.filtersApplied ? 475 : 500,
        child: ListView.builder(
            itemCount: uids.length,
            itemBuilder: (BuildContext ctxt, int index) =>
                buildEventWidget(ctxt, data, uids[index])),
      ),
      buildBottomBar(context),
    ]));
  }

  Widget addFiltersWidget() {
    String filters;
    Map<String, bool> filterMap = dataProvider.filters;
    filterMap.forEach((String key, bool val) {
      if (val) {
        if (filters == null) {
          filters = "Filters: " + key;
        } else {
          filters = filters + "," + key;
        }
      }
    });
    return SizedBox(
        height: 25,
        child: new SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              filters,
              style: TextStyle(color: Colors.blue),
            )));
  }

  List<Widget> dateButtonList;
  List<Widget> buildDateWidgets(List<DateTime> dates) {
    dateButtonList = new List<Widget>();
    dates.forEach((f) => dateButtonList.add(FlatButton(
          color: dataProvider.isSelectedDate(f) ? Colors.blue : Colors.white,
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
            setState(() {
              dataProvider.setDateString(newDateKey);
            });
          },
          child: Text(
            new DateFormat("MMMd").format(f),
          ),
        )));
    return dateButtonList;
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
      onTap: () {
        Navigator.pushNamed(context, RoutePaths.SpecialEventsDetailView,
            arguments: uid);
      },
    );
  }

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

  Widget buildTrailing(Schedule event) {
    if (myEventList[event.id] != null && myEventList[event.id]) {
      return GestureDetector(
          onTap: () {
            dataProvider.removeFromMyEvents(event.id);
          },
          child: Icon(Icons.star,
              color: Colors.yellow, size: 54, semanticLabel: 'Going'));
    } else
      return GestureDetector(
          onTap: () {
            dataProvider.addToMyEvents(event.id);
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
              color: dataProvider.isFull ? Colors.blue : Colors.white,
              textColor: Colors.black,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              //padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              focusColor: Colors.blue,
              child: Text('Full Schedule'),
              onPressed: () {
                setState(() {
                  dataProvider.switchToFullSchedule();
                });
              },
            )),
        Container(
            height: 67,
            width: MediaQuery.of(context).size.width / 2,
            child: FlatButton(
              color: dataProvider.isFull ? Colors.white : Colors.blue,
              textColor: Colors.black,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              focusColor: Colors.blue,
              child: Text('My Schedule'),
              onPressed: () {
                setState(() {
                  dataProvider.switchToMySchedule();
                });
              },
            ))
      ],
    );
  }
}

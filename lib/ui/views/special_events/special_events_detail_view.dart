import 'package:campus_mobile_experimental/core/data_providers/special_events_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/special_events_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SpecialEventsViewModel extends StatefulWidget {
  @override
  _SpecialEventsViewModelState createState() => _SpecialEventsViewModelState();
}

class _SpecialEventsViewModelState extends State<SpecialEventsViewModel> {
  String currentDateSelection = "2018-09-22";
  var appBarTitleText = new Text("LOADING");
  bool isFull = true; // Toggle true for full schedule / false for my Schedule

  Map<String, bool> myEventList;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    myEventList = Provider.of<SpecialEventsDataProvider>(context).myEventsList;
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<SpecialEventsDataProvider>(context).error != null) {
      return Center(
          child: ContainerView(
              child:
                  Text(Provider.of<SpecialEventsDataProvider>(context).error)));
    } else if (Provider.of<SpecialEventsDataProvider>(context).isLoading) {
      return ContainerView(child: Center(child: CircularProgressIndicator()));
    }
    return buildDetailView(context);
  }

  Widget buildDetailView(BuildContext context) {
    return buildEventsCard(
        Provider.of<SpecialEventsDataProvider>(context).specialEventsModel);
  }

// Helper function that adds dynamic scaffold and filter button
  Widget addScaffoldToChild(Widget child) {
    //appBarTitleText = new Text(name);
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
            title: Center(child: appBarTitleText), // Dynamically changed
            actions: <Widget>[isFull ? filterButtonEnabled() : Container()]),
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
    appBarTitleText = new Text(data.name);

    List<String> uids = selectEvents(data);
    return addScaffoldToChild(Column(children: <Widget>[
      SizedBox(
          height: 50,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: buildDateWidgets(data.dates))),
      isFull
          ? (filtersApplied() ? addFiltersWidget() : Container())
          : Container(),
      SizedBox(
        height: filtersApplied() ? 475 : 500,
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
    Map<String, bool> filterMap =
        Provider.of<SpecialEventsDataProvider>(context).filters;
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
          color: isSelectedDate(f) ? Colors.blue : Colors.white,
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
              currentDateSelection = newDateKey;
            });
          },
          child: Text(
            new DateFormat("MMMd").format(f),
          ),
        )));
    return dateButtonList;
  }

//Helper function to check which date button is active while re rendering
  bool isSelectedDate(DateTime dateTime) {
    String newDateKey = dateTime
        .toIso8601String()
        .substring(0, dateTime.toIso8601String().indexOf("T"));
    return (newDateKey == currentDateSelection);
  }

// Helper method that selects events to display based on filters and myschedule selection
  List<String> selectEvents(SpecialEventsModel data) {
    List<String> itemsForDate = data.dateItems[currentDateSelection];

    if (isFull) {
      if (filtersApplied())
        return applyFilters(itemsForDate, data);
      else
        return itemsForDate; // No filters applied
    } else {
      List<String> myItemsForDate = new List<String>();
      itemsForDate.forEach((f) => {
            if (myEventList[f] == true) {myItemsForDate.add(f)}
          });
      return myItemsForDate;
    }
  }

  // Helper method to check if any filters have been apllied
  bool filtersApplied() {
    Map<String, bool> filterMap =
        Provider.of<SpecialEventsDataProvider>(context).filters;
    return filterMap.containsValue(true);
  }

  // Makes new list of event UIDs after appliying fliters and maintains order
  List<String> applyFilters(List<String> events, SpecialEventsModel data) {
    List<String> filteredEvents = new List<String>();
    Map<String, bool> filterMap =
        Provider.of<SpecialEventsDataProvider>(context).filters;
    for (int i = 0; i < events.length; i++) {
      String filter = getLabel(events[i], data);
      if (filterMap[filter]) {
        filteredEvents.add(events[i]);
      }
    }
    return filteredEvents;
  }

  //Helper function to get label given UID as string
  String getLabel(String uid, SpecialEventsModel data) {
    for (int i = 0; i < data.labels.length; i++) {
      if (data.labelItems[data.labels[i]].contains(uid)) return data.labels[i];
    }
    return null;
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
        Navigator.pushNamed(context, RoutePaths.SpecialEventsInfoView);
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

  //Add event from myList
  void isGoing(String uid) {
    Provider.of<SpecialEventsDataProvider>(context, listen: false)
        .addToMyEvents(uid);
  }

  //Remove event from myList
  void notGoing(String uid) {
    Provider.of<SpecialEventsDataProvider>(context, listen: false)
        .removeFromMyEvents(uid);
  }

  Widget buildTrailing(Schedule event) {
    if (myEventList[event.id] != null && myEventList[event.id]) {
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
              color: isFull ? Colors.blue : Colors.white,
              textColor: Colors.black,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              //padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              focusColor: Colors.blue,
              child: Text('Full Schedule'),
              onPressed: () {
                setState(() {
                  isFull = true;
                });
              },
            )),
        Container(
            height: 67,
            width: MediaQuery.of(context).size.width / 2,
            child: FlatButton(
              color: isFull ? Colors.white : Colors.blue,
              textColor: Colors.black,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              focusColor: Colors.blue,
              child: Text('My Schedule'),
              onPressed: () {
                setState(() {
                  isFull = false;
                });
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

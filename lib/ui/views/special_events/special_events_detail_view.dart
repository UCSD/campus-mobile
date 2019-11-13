import 'package:campus_mobile_beta/core/constants/app_constants.dart';
import 'package:campus_mobile_beta/core/models/special_events_model.dart';
import 'package:campus_mobile_beta/core/services/special_events_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpecialEventsViewModel extends StatefulWidget {
  @override
  _SpecialEventsViewModelState createState() => _SpecialEventsViewModelState();
}

// Variables map to pass data between filter page and this page
class FilterArguments {
  Map<int, bool> selected;
  List<String> filters;
  String title;
  Map<String, String> labelThemes;

  FilterArguments(this.selected, this.filters, this.title, this.labelThemes);
}

class _SpecialEventsViewModelState extends State<SpecialEventsViewModel> {
  final SpecialEventsService _specialEventsService = SpecialEventsService();
  Future<SpecialEventsModel> _data;
  String currentDateSelection = "2018-09-22";
  var appBarTitleText = new Text("LOADING");

  FilterArguments filterArguments;
  bool isFull = true; // Toggle true for full schedule / false for my Schedule

  //This will need to be stored in state so that its not reset everytime!
  Map<String, bool> myEventList;

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
    return buildDetailView(context);
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
        Navigator.pushNamed(context, RoutePaths.SpecialEventsFilterView,
            arguments: {
              "selectFilter": _selectFilter,
              "filterArguments": filterArguments
            });
      },
    );
  }

  Widget filterButtonDisabled() {
    return Container(child: Opacity(opacity: 0.0, child: Text("Filter")));
  }

  _selectFilter() {
    _updateData();
  }

  Widget buildEventsCard(AsyncSnapshot<SpecialEventsModel> snapshot) {
    if (snapshot.hasData) {
      final SpecialEventsModel data = snapshot.data;
      appBarTitleText = new Text(data.name);

      //Initialized filters if not yet initialized
      if (filterArguments == null) {
        Map<int, bool> selected = new Map<int, bool>();
        int filtersLength = data.labels.length;
        for (int i = 0; i < filtersLength; i++) selected[i] = false;
        filterArguments = new FilterArguments(
            selected, data.labels, data.name, data.labelThemes);
      }

      //Initialize myEvents list if its null
      if (myEventList == null) {
        myEventList = new Map<String, bool>();
        data.uids.forEach((f) => myEventList[f] = false);
      }

      List<String> uids = selectEvents(data);
      return addScaffoldToChild(Column(children: <Widget>[
        SizedBox(
            height: 50,
            child: ListView(
                scrollDirection: Axis.horizontal,
                children: buildDateWidgets(data.dates))),
        isFull? (filtersApplied() ? addFiltersWidget() : Container()): Container(),
        SizedBox(
          height: filtersApplied()
              ? 475
              : 500, //TODO probably a better way to do this ...
          child: ListView.builder(
              itemCount: uids.length,
              itemBuilder: (BuildContext ctxt, int index) =>
                  buildEventWidget(ctxt, data, uids[index])),
        ),
        buildBottomBar(context),
      ]));
    } else {
      return Container();
    }
  }

  Widget addFiltersWidget() {
    String filters;
    for (int i = 0; i < filterArguments.filters.length; i++) {
      if (filterArguments.selected[i]) {
        if (filters == null)
          filters = "Filters: " + filterArguments.filters[i];
        else
          filters = filters + "," + filterArguments.filters[i];
      }
    }
    return SizedBox(
        height: 25,
        child: new SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: Text(filters,style: TextStyle(color: Colors.blue),)));
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
            currentDateSelection = newDateKey;
            _updateData();
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
            if (myEventList[f]) {myItemsForDate.add(f)}
          });
      return myItemsForDate;
    }
  }

  // Helper method to check if any filters have been apllied
  bool filtersApplied() {
    for (int i = 0; i < filterArguments.filters.length; i++) {
      if (filterArguments.selected[i]) return true;
    }
    return false;
  }

  // Makes new list of event UIDs after appliying fliters and maintains order
  List<String> applyFilters(List<String> events, SpecialEventsModel data) {
    List<String> filteredEvents = new List<String>();
    for (int i = 0; i < events.length; i++) {
      String filter = getLabel(events[i], data);
      int filterKey = data.labels.indexOf(filter);
      if (filterArguments.selected[filterKey]) {
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
  void isGoing(String uid) {
    myEventList[uid] = true;
    _updateData();
    //return false;
  }

  //Remove event from myList
  void notGoing(String uid) {
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
              color: isFull ? Colors.blue : Colors.white,
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
              color: isFull ? Colors.white : Colors.blue,
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

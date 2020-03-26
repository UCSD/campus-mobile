import 'package:campus_mobile_experimental/core/data_providers/special_events_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/special_events_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/HexColor.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SpecialEventsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SpecialEventsDataProvider dataProvider =
        Provider.of<SpecialEventsDataProvider>(context);
    if (dataProvider.error != null) {
      return Center(child: ContainerView(child: Text(dataProvider.error)));
    } else if (dataProvider.isLoading) {
      return ContainerView(child: Center(child: CircularProgressIndicator()));
    }
    return buildEventsCard(context);
  }

  // Helper function that adds dynamic scaffold and filter button
  Widget addScaffoldToChild(Widget child, BuildContext context) {
    SpecialEventsDataProvider dataProvider =
        Provider.of<SpecialEventsDataProvider>(context);
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
            title: Center(
                child: dataProvider.appBarTitleText), // Dynamically changed
            actions: <Widget>[
              dataProvider.isFull ? filterButtonEnabled(context) : Container()
            ]),
      ),
      body: child,
    );
  }

  Widget filterButtonEnabled(BuildContext context) {
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

  Widget buildEventsCard(BuildContext context) {
    SpecialEventsDataProvider dataProvider =
        Provider.of<SpecialEventsDataProvider>(context);
    SpecialEventsModel data = dataProvider.specialEventsModel;

    List<String> uids = dataProvider.selectEvents();
    return addScaffoldToChild(
        Column(
          children: <Widget>[
            SizedBox(
                height: 50,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: buildDateWidgets(data.dates, context))),
            dataProvider.isFull
                ? (dataProvider.filtersApplied
                    ? addFiltersWidget(context)
                    : Container())
                : Container(),
            SizedBox(
              height: dataProvider.filtersApplied ? 475 : 500,
              child: ListView.builder(
                  itemCount: uids.length,
                  itemBuilder: (BuildContext ctxt, int index) =>
                      buildEventWidget(ctxt, data, uids[index])),
            ),
            buildBottomBar(context),
          ],
        ),
        context);
  }

  Widget addFiltersWidget(BuildContext context) {
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

  List<Widget> buildDateWidgets(List<DateTime> dates, BuildContext context) {
    SpecialEventsDataProvider dataProvider =
        Provider.of<SpecialEventsDataProvider>(context);
    List<Widget> dateButtonList = new List<Widget>();
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
            dataProvider.setDateString(newDateKey);
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
      trailing: buildTrailing(event, ctxt),
      onTap: () {
        Navigator.pushNamed(ctxt, RoutePaths.SpecialEventsDetailView,
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

  Widget buildTrailing(Schedule event, BuildContext context) {
    SpecialEventsDataProvider dataProvider =
        Provider.of<SpecialEventsDataProvider>(context);
    Map<String, bool> myEventList = dataProvider.myEventsList;
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
    SpecialEventsDataProvider dataProvider =
        Provider.of<SpecialEventsDataProvider>(context);
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
            onPressed: () => dataProvider.switchToFullSchedule(),
          ),
        ),
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
            onPressed: () => dataProvider.switchToMySchedule(),
          ),
        )
      ],
    );
  }
}

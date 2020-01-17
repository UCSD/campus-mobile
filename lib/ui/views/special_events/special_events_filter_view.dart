import 'package:campus_mobile_experimental/core/data_providers/special_events_data_provider.dart';
import 'package:campus_mobile_experimental/ui/views/special_events/special_events_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SpecialEventsFilterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return addScaffold(
        context,
        Provider.of<SpecialEventsDataProvider>(context)
            .specialEventsModel
            .name);
  }

  Widget addScaffold(context, String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: new ListView.builder(
          itemCount:
              Provider.of<SpecialEventsDataProvider>(context).filters.length,
          itemBuilder: (BuildContext ctxt, int index) =>
              makeFiltersList(ctxt, index),
        ),
      ),
    );
  }

  Widget makeFiltersList(BuildContext context, int index) {
    List<String> filtersList =
        Provider.of<SpecialEventsDataProvider>(context).filters.keys.toList();
    Color labelTheme = HexColor(Provider.of<SpecialEventsDataProvider>(context)
        .specialEventsModel
        .labelThemes[filtersList[index]]);
    return new Card(
        child: GestureDetector(
      onTap: () {
        if (Provider.of<SpecialEventsDataProvider>(context)
            .filters[filtersList[index]]) {
          Provider.of<SpecialEventsDataProvider>(context)
              .removeFilter(filtersList[index]);
        } else {
          Provider.of<SpecialEventsDataProvider>(context)
              .addFilter(filtersList[index]);
        }
      },
      child: ListTile(
        leading: Provider.of<SpecialEventsDataProvider>(context)
                .filters[filtersList[index]]
            ? selectedCircle(labelTheme)
            : unselectedCircle(labelTheme),
        title: Text(filtersList[index]),
      ),
    ));
  }

  Widget selectedCircle(Color labelTheme) {
    return new Container(
        padding: new EdgeInsets.all(2.0),
        width: 25.0,
        height: 25.0,
        decoration: new BoxDecoration(
          border: Border.all(color: labelTheme, width: 2),
          shape: BoxShape.circle,
        ),
        child: new Container(
          decoration: new BoxDecoration(
            color: labelTheme,
            shape: BoxShape.circle,
          ),
        ));
  }

  Widget unselectedCircle(Color labelTheme) {
    return new Container(
        width: 25.0,
        height: 25.0,
        decoration: new BoxDecoration(
          border: Border.all(color: labelTheme, width: 2),
          shape: BoxShape.circle,
        ));
  }
}

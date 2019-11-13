import 'package:campus_mobile_experimental/ui/views/special_events/special_events_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SpecialEventsFilterView extends StatefulWidget {
  @override
  _SpecialEventsFilterViewState createState() =>
      _SpecialEventsFilterViewState();

  const SpecialEventsFilterView(
      {Key key, @required this.selectFilter, this.filterArguments})
      : super(key: key);
  final Function selectFilter;
  final FilterArguments filterArguments;
}

class _SpecialEventsFilterViewState extends State<SpecialEventsFilterView> {
  FilterArguments filterArguments;
  Function selectFilter;

  @override
  Widget build(BuildContext context) {
    final String title = widget.filterArguments.title;
    filterArguments = widget.filterArguments;
    selectFilter = widget.selectFilter;

    return addScaffold(context, title);
  }

  initState() {
    super.initState();
    _updateData(-1);
  }

  _updateData(int index) {
    if (index != -1)
      setState(() {
        filterArguments.selected[index] = !filterArguments.selected[index];
      });
  }

  Widget addScaffold(context, String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: new ListView.builder(
          itemCount: filterArguments.filters.length,
          itemBuilder: (BuildContext ctxt, int index) =>
              makeFiltersList(ctxt, index),
        ),
      ),
    );
  }

  Widget makeFiltersList(BuildContext ctxt, int index) {
    List<String> filtersList = filterArguments.filters;
    return new Card(
        child: GestureDetector(
      onTap: () {
        _updateData(index);
      },
      child: ListTile(
        leading:
            isSelected(index) ? selectedCircle(index) : unselectedCircle(index),
        title: Text(filtersList[index]),
      ),
    ));
  }

  bool isSelected(int index) {
    return filterArguments.selected[index];
  }

  Widget selectedCircle(int index) {
    Color labelTheme =
        HexColor(filterArguments.labelThemes[filterArguments.filters[index]]);
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

  Widget unselectedCircle(int index) {
    Color labelTheme =
        HexColor(filterArguments.labelThemes[filterArguments.filters[index]]);
    return new Container(
        width: 25.0,
        height: 25.0,
        decoration: new BoxDecoration(
          border: Border.all(color: labelTheme, width: 2),
          shape: BoxShape.circle,
        ));
  }
}

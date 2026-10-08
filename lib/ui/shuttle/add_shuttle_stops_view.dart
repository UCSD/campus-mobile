import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';

class AddShuttleStopsView extends StatefulWidget {
  @override
  _AddShuttleStopsViewState createState() => _AddShuttleStopsViewState();
}

class _AddShuttleStopsViewState extends State<AddShuttleStopsView> {
  /// STATES
  var isAddingStop = false;
  var _searchQuery = '';

  /// PROVIDERS
  late ShuttleDataProvider _shuttleDataProvider;

  @override
  Widget build(BuildContext context) {
    _shuttleDataProvider = Provider.of<ShuttleDataProvider>(context);

    if (isAddingStop) {
      return Stack(children: <Widget>[
        ContainerView(
            child: Container(
          width: double.infinity,
          height: 200.0,
          child: Center(
            child: Container(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
          ),
        )),
      ]);
    } else {
      return Stack(children: <Widget>[
        ContainerView(
          child: buildAllLocationsList(context),
        ),
      ]);
    }
  }

  Widget buildAllLocationsList(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              onChanged: (text) => setState(() => _searchQuery = text),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search stops',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Expanded(child: CustomScrollView(slivers: createSections(context))),
        ],
      );

  List<Widget> createSections(BuildContext context) {
    List<Widget> sections = [];

    _shuttleDataProvider.stopsNotSelectedByDistrict(query: _searchQuery).forEach((district, stops) {
      sections.add(SliverStickyHeader(
        header: buildDistrictHeader(context, district),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildStopTile(context, stops[index]),
            childCount: stops.length,
          ),
        ),
      ));
    });

    return sections;
  }

  Widget buildDistrictHeader(BuildContext context, String district) => Container(
        width: double.infinity,
        color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : descriptiveTextColorLight,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(district, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
        ),
      );

  Widget buildStopTile(BuildContext context, ShuttleStopModel model) => ListTile(
        key: Key(model.id.toString()),
        title: Text(
          model.name,
        ),
        onTap: () async {
          setState(() {
            isAddingStop = true;
          });
          await _shuttleDataProvider.addStop(model.id);
          isAddingStop = false;
          Navigator.pop(context);
        },
      );
}

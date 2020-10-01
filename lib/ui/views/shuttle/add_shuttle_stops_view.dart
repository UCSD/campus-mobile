import 'package:campus_mobile_experimental/core/data_providers/shuttle_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddShuttleStopsView extends StatefulWidget {

  @override
  _AddShuttleStopsViewState createState() => _AddShuttleStopsViewState();
}

class _AddShuttleStopsViewState extends State<AddShuttleStopsView> {
  ShuttleDataProvider _shuttleDataProvider;
  bool isAddingStop = false;

  @override
  Widget build(BuildContext context) {
    _shuttleDataProvider = Provider.of<ShuttleDataProvider>(context);

    if (isAddingStop) {
      return Stack(children: <Widget>[
        ContainerView(
          child: Center(child: Text("Adding stop...")),
        ),
      ]);
    } else {
      return Stack(children: <Widget>[
        ContainerView(
          child: buildAllLocationsList(context),
        ),
      ]);
    }
  }

  Widget buildAllLocationsList(BuildContext context) {
    return ListView(
      children: createList(context),
    );
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();

    _shuttleDataProvider.stopsNotSelected.forEach((key, value) {
      ShuttleStopModel model = value;
      if (model != null) {
        list.add(ListTile(
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
        ));
      }
    });

    return list;
  }
}

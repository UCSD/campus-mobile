import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddShuttleStopsView extends StatefulWidget {
  @override
  _AddShuttleStopsViewState createState() => _AddShuttleStopsViewState();
}

class _AddShuttleStopsViewState extends State<AddShuttleStopsView> {
  late ShuttleDataProvider _shuttleDataProvider;
  bool isAddingStop = false;

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
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary)),
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

  Widget buildAllLocationsList(BuildContext context) {
    return ListView(
      children: createList(context),
    );
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];

    _shuttleDataProvider.stopsNotSelected.forEach((key, value) {
      ShuttleStopModel model = value;
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
    });

    return list;
  }
}
